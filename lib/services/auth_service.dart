// ──────────────────────────────────────────────────────────
// auth_service.dart — Authentication & User Management
// ──────────────────────────────────────────────────────────
// Backend: Firebase Auth + Firestore (users collection)
// Caching: SharedPreferences for instant profile loads
// Pattern: ChangeNotifier (used with Provider in main.dart)
// ──────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService with ChangeNotifier {
  // ─── Firebase & Google instances ───
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DatabaseService _db = DatabaseService();

  // ─── State ───
  UserModel? _userModel;
  UserModel? get userModel => _userModel;

  User? get currentUser => _auth.currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSigningUp = false;
  bool get isSigningUp => _isSigningUp;

  // ─── Internal tracking ───
  final String _userCacheKey = 'cached_user_profile';
  int _syncIteration = 0; // Prevents stale callbacks after sign-out
  StreamSubscription<Map<String, dynamic>?>? _userSubscription;

  // ──────────────────────────────────────────────────────────
  // CONSTRUCTOR — listens to Firebase auth state changes
  // ──────────────────────────────────────────────────────────
  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // ──────────────────────────────────────────────────────────
  // AUTH STATE CHANGE HANDLER
  // Called whenever user logs in, logs out, or app restarts
  // ──────────────────────────────────────────────────────────
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    final int currentIteration = ++_syncIteration;

    // Cancel any existing Firestore listener
    await _userSubscription?.cancel();
    _userSubscription = null;

    debugPrint(
      "🔄 [Auth] State Changed ($currentIteration): "
      "${firebaseUser?.email ?? 'SIGNED OUT'}",
    );

    // User signed out → clear everything
    if (firebaseUser == null) {
      _userModel = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    // User signed in → load profile
    _isLoading = true;
    notifyListeners();

    try {
      // Step 1: Load from local cache for instant display
      // This makes the app feel "instant" even if offline
      await _loadCachedProfile(firebaseUser.uid);

      // Step 2: Start real-time Firestore listener
      // This will update the UI with fresh data when available
      await _startUserStream(firebaseUser);
    } catch (e) {
      debugPrint("🔴 [Auth] Setup Error: $e");
      // DO NOT force sign out here. Allow retry or offline usage.
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Try loading user profile from SharedPreferences cache
  Future<void> _loadCachedProfile(String uid) async {
    // If we already have memory state, don't overwrite with old cache
    if (_userModel != null && _userModel!.uid == uid) return;

    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_userCacheKey)) return;

    try {
      final cachedData = jsonDecode(prefs.getString(_userCacheKey)!);
      if (cachedData['uid'] == uid || cachedData['id'] == uid) {
        _userModel = UserModel.fromMap(cachedData, uid);
        debugPrint("⚡ [Auth] Profile loaded from cache");
        notifyListeners();
      }
    } catch (e) {
      debugPrint("⚠️ [Auth] Cache read error: $e");
    }
  }

  // ──────────────────────────────────────────────────────────
  // SIGN IN — Email & Password
  // ──────────────────────────────────────────────────────────
  Future<void> signIn(String email, String password) async {
    // Validate inputs
    if (email.isEmpty || password.isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-input',
        message: 'Email and password cannot be empty',
      );
    }

    try {
      debugPrint("🔍 [Auth] Sign In: $email");
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      debugPrint("✅ [Auth] Sign In Success");
    } catch (e) {
      debugPrint("🔴 [Auth] Sign In Error: $e");
      notifyListeners();
      rethrow;
    }
  }

  // ──────────────────────────────────────────────────────────
  // SIGN UP — Create new user account
  // Creates Firebase Auth user + Firestore profile document
  // ──────────────────────────────────────────────────────────
  Future<void> signUp(
    String email,
    String password,
    String name,
    String selectedRole,
  ) async {
    // Input validation
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-input',
        message: 'All fields are required',
      );
    }
    if (password.length < 6) {
      throw FirebaseAuthException(
        code: 'weak-password',
        message: 'Password must be at least 6 characters',
      );
    }

    _isSigningUp = true;
    notifyListeners();

    try {
      debugPrint("🔍 [Auth] Sign Up: $email as $selectedRole");

      // 1. Create Firebase Auth account
      // This usually succeeds unless email is taken
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw FirebaseAuthException(
          code: 'unknown',
          message: 'User creation failed without error.',
        );
      }

      // 2. Set display name on Firebase Auth profile (fast)
      await credential.user!.updateDisplayName(name);

      // 3. Create Firestore User Model
      final bool isAdmin = (email == 'admin@admin.com');
      final newUser = UserModel(
        uid: credential.user!.uid,
        email: email,
        name: name,
        // If user is admin, force admin role.
        // Otherwise, use the selected role directly (no pending state requested)
        role: isAdmin ? 'admin' : selectedRole.toLowerCase(),
        // Clear requestedRole since we are granting it immediately
        requestedRole: null,
      );

      debugPrint("📝 [Auth] Writing to Firestore: users/${newUser.uid}");

      // 4. Save profile to Firestore with extensive error handling
      try {
        await _db.insert('users', newUser.toMap(), docId: newUser.uid);
        debugPrint("✅ [Auth] Firestore write success");
      } catch (dbError) {
        // Critical: If database write fails, we should still allow login?
        // No, because app relies on role. We must report this.
        debugPrint("🔴 [Auth] Firestore Write FAILED: $dbError");
        throw FirebaseAuthException(
          code: 'database-error',
          message: 'Account created but profile failed to save: $dbError',
        );
      }

      // 5. Update local state immediately
      _userModel = newUser;

      // 6. Cache profile locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userCacheKey, jsonEncode(newUser.toMap()));

      // 7. Start listener for future updates
      await _startUserStream(credential.user!);

      notifyListeners();
    } catch (e) {
      debugPrint("🔴 [Auth] Sign Up Generic Error: $e");
      // If we failed after auth creation, maybe we should sign out?
      // Yes, cleaner start.
      if (_auth.currentUser != null) {
        await _auth.signOut();
      }
      rethrow;
    } finally {
      _isSigningUp = false;
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────────────────
  // SIGN OUT — Clear all state and redirect to login
  // ──────────────────────────────────────────────────────────
  Future<void> signOut() async {
    debugPrint("🚪 [Auth] Signing out...");

    // Invalidate stale callbacks
    _syncIteration++;

    // Clear local state immediately
    _userModel = null;
    _isLoading = false;
    await _userSubscription?.cancel();
    _userSubscription = null;

    // Clear cached profile
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userCacheKey);

    // Notify UI immediately (shows login screen)
    notifyListeners();

    // Then perform actual Firebase sign-out
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
      debugPrint("✅ [Auth] Sign-out complete");
    } catch (e) {
      debugPrint("🔴 [Auth] Sign-out error: $e");
    }
  }

  // ──────────────────────────────────────────────────────────
  // SIGN IN WITH GOOGLE
  // ──────────────────────────────────────────────────────────
  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // User cancelled

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      // Profile sync handled automatically by _onAuthStateChanged
    } catch (e) {
      notifyListeners();
      rethrow;
    }
  }

  // ──────────────────────────────────────────────────────────
  // PASSWORD MANAGEMENT
  // ──────────────────────────────────────────────────────────
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> changePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');
    await user.updatePassword(newPassword);
  }

  // ──────────────────────────────────────────────────────────
  // ACCOUNT MANAGEMENT
  // ──────────────────────────────────────────────────────────
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    final uid = user.uid;
    try {
      await user.delete();
    } catch (e) {
      rethrow;
    } finally {
      try {
        await _db.delete('users', docId: uid);
      } catch (_) {}
    }
  }

  // ──────────────────────────────────────────────────────────
  // PROFILE UPDATES
  // ──────────────────────────────────────────────────────────
  Future<void> updateProfile({String? name, String? photoUrl}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (photoUrl != null) updates['photo_url'] = photoUrl;

      if (updates.isNotEmpty) {
        await _db.update('users', updates, docId: user.uid);
        if (_userModel != null) {
          _userModel = UserModel(
            uid: _userModel!.uid,
            email: _userModel!.email,
            name: name ?? _userModel!.name,
            role: _userModel!.role,
            photoUrl: photoUrl ?? _userModel!.photoUrl,
            isBanned: _userModel!.isBanned,
          );
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("🔴 [Auth] Profile update error: $e");
      rethrow;
    }
  }

  Future<void> init() async {}

  // ──────────────────────────────────────────────────────────
  // REAL-TIME USER STREAM
  // Listens to Firestore for profile changes in real-time
  // ──────────────────────────────────────────────────────────
  Future<void> _startUserStream(User firebaseUser) async {
    final int myIteration = ++_syncIteration;
    final prefs = await SharedPreferences.getInstance();

    await _userSubscription?.cancel();
    _userSubscription = _db
        .streamDocument('users', firebaseUser.uid)
        .listen(
          (data) async {
            // Stale callback check — ignore if user signed out
            if (myIteration != _syncIteration) return;

            if (data != null) {
              // ─── Profile found → update local state ───
              _userModel = UserModel.fromMap(data, firebaseUser.uid);

              // Cache profile for offline/instant loads
              await prefs.setString(
                _userCacheKey,
                jsonEncode(_userModel!.toMap()),
              );

              debugPrint("✅ [Auth] Profile synced (${_userModel!.role})");
              _isLoading = false;
              notifyListeners();
            } else {
              // ─── Profile not found ───
              if (_isSigningUp) return; // Ignore during creation

              debugPrint(
                "⚠️ [Auth] Profile doc missing for ${firebaseUser.uid}",
              );

              // If this is the built-in master admin account, attempt to
              // create a minimal admin profile automatically so the app
              // doesn't get stuck on the loading screen while waiting for
              // a Firestore document that doesn't exist yet.
              try {
                final email = firebaseUser.email ?? '';
                if (email == 'admin@admin.com') {
                  debugPrint('🔧 [Auth] Creating missing admin profile for $email');
                  final Map<String, dynamic> adminProfile = {
                    'id': firebaseUser.uid,
                    'email': email,
                    'name': firebaseUser.displayName ?? 'Administrator',
                    'photo_url': firebaseUser.photoURL ?? '',
                    'role': 'admin',
                    'requested_role': null,
                    'is_banned': false,
                  };
                  await _db.insert('users', adminProfile, docId: firebaseUser.uid);
                  debugPrint('✅ [Auth] Admin profile created: ${firebaseUser.uid}');
                  return; // Wait for the stream to emit the newly created doc
                }
              } catch (e) {
                debugPrint('🔴 [Auth] Failed auto-create admin profile: $e');
                // Do not sign out — allow manual retry and show error elsewhere
              }

              // Do NOT sign out automatically. Flaky networks can cause this.
              // Just wait or let the user hit retry.
            }
          },
          onError: (e) {
            debugPrint("🔴 [Auth] Stream error: $e");
            // Do NOT sign out. Just log it.
          },
        );
  }

  // ──────────────────────────────────────────────────────────
  // ADMIN USER MANAGEMENT
  // ──────────────────────────────────────────────────────────
  Future<void> banUser(String uid) async {
    await _db.update('users', {'is_banned': true}, docId: uid);
  }

  Future<void> unbanUser(String uid) async {
    await _db.update('users', {'is_banned': false}, docId: uid);
  }

  Future<void> deleteUser(String uid) async {
    await _db.delete('users', docId: uid);
  }

  Future<void> promoteToAdmin(String uid) async {
    await _db.update('users', {'role': 'admin'}, docId: uid);
  }

  Future<void> promoteToTeacher(String uid) async {
    await _db.update('users', {'role': 'teacher'}, docId: uid);
  }

  Future<void> demoteToStudent(String uid) async {
    await _db.update('users', {'role': 'student'}, docId: uid);
  }

  // ──────────────────────────────────────────────────────────
  // ERROR MESSAGE HELPER
  // ──────────────────────────────────────────────────────────
  static String getAuthErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No account found with this email.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'weak-password':
          return 'Password must be at least 6 characters.';
        case 'database-error':
          return 'Database error. Please check your internet.';
        default:
          return error.message ?? 'Authentication failed.';
      }
    }
    return error.toString().replaceAll('Exception: ', '');
  }
}
