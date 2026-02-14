import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'database_service.dart';
import '../seeding/seeding_coordinator.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DatabaseService _db = DatabaseService();

  UserModel? _userModel;
  UserModel? get userModel => _userModel;

  int _syncIteration = 0;

  User? get currentUser => _auth.currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSigningUp = false;
  bool get isSigningUp => _isSigningUp;

  String? _authError;
  String? get authError => _authError;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _onAuthStateChanged(user);
    });
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    final int currentIteration = ++_syncIteration;
    final startTime = DateTime.now();

    debugPrint(
      "🔄 [AuthService] Auth State Changed ($currentIteration): ${firebaseUser?.email ?? 'NULL'}",
    );

    if (firebaseUser == null) {
      _userModel = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Direct fetch with internal DatabaseService timeout
      final profileData = await _db.getDocument('users', firebaseUser.uid);

      // If a newer auth event happened while we were waiting, ignore this result
      if (currentIteration != _syncIteration) return;

      if (profileData != null) {
        _userModel = UserModel.fromMap(profileData, firebaseUser.uid);
        debugPrint(
          "✅ [AuthService] Profile synced in ${DateTime.now().difference(startTime).inMilliseconds}ms",
        );

        // Trigger Seeding only if Admin
        if (_userModel!.role == 'admin') {
          unawaited(SeedingCoordinator().init());
        }
      } else {
        debugPrint(
          "🔍 [AuthService] Profile not found, creating/recovering...",
        );

        // Safety: Don't try to auto-create a profile if it's already taking too long
        if (DateTime.now().difference(startTime).inSeconds > 60) {
          throw TimeoutException(
            "Initial sync took too long, skipping auto-recovery",
          );
        }

        _userModel = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name:
              firebaseUser.displayName ??
              firebaseUser.email?.split('@')[0] ??
              'User',
          photoUrl: firebaseUser.photoURL ?? '',
          role: (firebaseUser.email == 'admin@admin.com') ? 'admin' : 'pending',
        );

        await _db.insert('users', _userModel!.toMap(), docId: _userModel!.uid);

        // Trigger Seeding if it was the admin who just got auto-created
        if (_userModel!.role == 'admin') {
          unawaited(SeedingCoordinator().init());
        }
      }

      _isLoading = false;
      if (currentIteration == _syncIteration) notifyListeners();
    } catch (e) {
      if (currentIteration != _syncIteration) return;

      debugPrint("🔴 [AuthService] Sync Error ($currentIteration): $e");

      // Specific handling for Offline/Unavailable errors
      if (e.toString().contains('unavailable') ||
          e.toString().contains('offline')) {
        _authError =
            "Connection Error: Please check your internet or disable AdBlock.";
      } else {
        _authError = e.toString();
      }

      _userModel = null;
      _isLoading = false;

      // CRITICAL FALLBACK: If it's the master admin, let them in even if DB is failing.
      // This allows them to reach the dashboard to trigger seeding/repairs.
      if (firebaseUser.email == 'admin@admin.com') {
        debugPrint(
          "🟢 [AuthService] EMERGENCY FALLBACK: Local Admin Profile created.",
        );
        _userModel = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email!,
          name: "Local Admin",
          role: "admin",
        );
        unawaited(SeedingCoordinator().init());
      }
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      debugPrint("🔍 [AuthService] Attempting Sign In for: $email");
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      debugPrint("✅ [AuthService] Firebase Auth Sign In Success");
    } catch (e) {
      debugPrint("🔴 [AuthService] Firebase Auth Sign In Error: $e");
      _authError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    _isSigningUp = true;
    notifyListeners();
    try {
      debugPrint("🔍 [AuthService] Attempting Sign Up for: $email");
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        debugPrint(
          "✅ [AuthService] Firebase Auth Sign Up Success for UID: ${credential.user!.uid}",
        );
        // Default role is 'user' which triggers role selection, unless it's the master admin
        final newUser = UserModel(
          uid: credential.user!.uid,
          email: email,
          name: name,
          role: (email == 'admin@admin.com') ? 'admin' : 'pending',
        );
        debugPrint("🔍 [AuthService] Inserting profile to Firestore...");
        await _db.insert('users', newUser.toMap(), docId: newUser.uid);
        _userModel = newUser;
        debugPrint(
          "✅ [AuthService] Firestore Profile Created with role: ${newUser.role}",
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("🔴 [AuthService] Sign Up Error: $e");
      _authError = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isSigningUp = false;
      notifyListeners();
    }
  }

  Future<void> updateUserRole(String role) async {
    final user = _auth.currentUser;
    if (user == null || _userModel == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      debugPrint("🔍 [AuthService] Updating user role to: $role (45s timeout)");
      await _db.update(
        'users',
        {'role': role},
        docId: user.uid,
        timeout: const Duration(seconds: 60),
      );

      _userModel = UserModel(
        uid: _userModel!.uid,
        email: _userModel!.email,
        name: _userModel!.name,
        role: role,
        photoUrl: _userModel!.photoUrl,
        isBanned: _userModel!.isBanned,
      );

      debugPrint("✅ [AuthService] Local and Remote role updated");
    } catch (e) {
      debugPrint("🔴 [AuthService] Error updating role: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> changePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');
    await user.updatePassword(newPassword);
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    final uid = user.uid;
    try {
      await user.delete();
    } catch (e) {
      // Re-throw so callers can handle re-auth requirement
      rethrow;
    } finally {
      // Ensure local profile is removed from Firestore
      try {
        await _db.delete('users', docId: uid);
      } catch (_) {}
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      if (result.user != null) {
        // Sync to Firestore is handled by _onAuthStateChanged listener
      }
    } catch (e) {
      _authError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    debugPrint("🚪 [AuthService] Sign-Out Initiated. Clearing State...");

    // 1. Immediately invalidate background syncs
    _syncIteration++;

    // 2. Clear local session state immediately
    _userModel = null;
    _isLoading = false;
    _authError = null;

    // 3. Notify listeners so UI updates instantly
    notifyListeners();

    try {
      // 4. Perform actual sign-out in background
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
      debugPrint("✅ [AuthService] Firebase/Google Sign-Out Complete");
    } catch (e) {
      debugPrint("🔴 [AuthService] Error during sign-out: $e");
    }
  }

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
      debugPrint("Error updating local profile: $e");
      rethrow;
    }
  }

  Future<void> banUser(String uid) async {
    await _db.update('users', {'is_banned': 1}, docId: uid);
  }

  Future<void> unbanUser(String uid) async {
    await _db.update('users', {'is_banned': 0}, docId: uid);
  }

  Future<void> promoteToAdmin(String uid) async {
    await _db.update('users', {'role': 'admin'}, docId: uid);
  }

  Future<void> demoteFromAdmin(String uid) async {
    await _db.update('users', {'role': 'student'}, docId: uid);
  }

  Future<void> deleteUser(String uid) async {
    // Note: Firestore delete only removes the profile doc.
    // Full user deletion would require Firebase Admin SDK or Cloud Functions.
    await _db.delete('users', docId: uid);
  }

  void clearAuthError() {
    _authError = null;
    notifyListeners();
  }

  Future<void> init() async {}
}
