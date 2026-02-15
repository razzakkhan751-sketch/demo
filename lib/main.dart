// ──────────────────────────────────────────────────────────
// main.dart — Application Entry Point
// ──────────────────────────────────────────────────────────
// Tech Stack: Dart/Flutter (Frontend) + Firebase (Backend & Database)
// Flow: main() → Firebase Init → AuthWrapper → Role-Based Screen
// ──────────────────────────────────────────────────────────

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Screens ───
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/courses_screen.dart';

import 'screens/verification_pending_screen.dart';
import 'screens/chat/chat_list_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/teacher/teacher_dashboard_screen.dart';

// ─── Services & Providers ───
import 'services/auth_service.dart';
import 'services/seed_courses.dart';
import 'core/theme_provider.dart';
import 'firebase_options.dart';

// ──────────────────────────────────────────────────────────
// ENTRY POINT
// ──────────────────────────────────────────────────────────
Future<void> main() async {
  // Ensure Flutter widgets binding is initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Global error handlers to prevent white screen crashes
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint("🛑 [Global Error] ${details.exception}");
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint("🛑 [Async Error] $error");
    return true; // Handled — prevent crash
  };

  debugPrint("🚀 [Main] App Starting...");

  // Initialize SharedPreferences before running the app
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  // Launch the app immediately (Firebase loads via FutureBuilder)
  runApp(MyApp(isDarkMode: isDarkMode));
}

// ──────────────────────────────────────────────────────────
// FIREBASE INITIALIZATION (runs once on startup)
// Use `late` so initialization occurs after `main()` calls
// `WidgetsFlutterBinding.ensureInitialized()` to avoid early
// binding access errors when Firebase initializes.
// ──────────────────────────────────────────────────────────
final Future<void> _firebaseInit = _initializeFirebase();

Future<void> _initializeFirebase() async {
  try {
    if (Firebase.apps.isEmpty) {
      // Stage 1: Initialize Firebase with platform-specific config
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint("✅ [Main] Firebase Initialized");

      // Stage 2: Configure Firestore for offline persistence
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      debugPrint("✅ [Main] Firestore settings applied");
    }
    // NOTE: We do NOT sign out on startup anymore.
    // Sessions are preserved so users don't have to re-login every time.
    debugPrint("✅ [Main] Firebase ready — session preserved");

    // Non-blocking seed: runs in background, never stalls UI
    SeedCourses.seedIfEmpty();
  } catch (e, stack) {
    debugPrint("🔴 [Main] Firebase Init Error: $e\n$stack");
    rethrow;
  }
}

// ──────────────────────────────────────────────────────────
// ROOT WIDGET — MyApp
// Waits for Firebase, then provides theme and auth state
// ──────────────────────────────────────────────────────────
class MyApp extends StatelessWidget {
  final bool isDarkMode;

  const MyApp({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _firebaseInit,
      builder: (context, snapshot) {
        // Show loading spinner while Firebase initializes
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      "Initializing...",
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Show error screen if Firebase failed to initialize
        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off, size: 60, color: Colors.red),
                      const SizedBox(height: 24),
                      Text(
                        "Connection Failed",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Could not connect to the server.\nPlease check your internet and try again.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // ─── Firebase Ready → Build the real app ───
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeProvider>(
              create: (_) => ThemeProvider(isDarkMode: isDarkMode),
            ),
            ChangeNotifierProvider(create: (_) => AuthService()),
          ],
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                title: 'SketchLearn',
                debugShowCheckedModeBanner: false,
                themeMode: themeProvider.themeMode,

                // ─── LIGHT THEME ───
                theme: _buildLightTheme(),

                // ─── DARK THEME ───
                darkTheme: _buildDarkTheme(),

                // Entry point: AuthWrapper decides which screen to show
                home: const AuthWrapper(),

                // Named routes for navigation
                routes: {
                  '/login': (context) => const LoginScreen(),
                  '/signup': (context) => const SignupScreen(),
                  '/home': (context) => const HomeScreen(),
                  '/courses': (context) => const CoursesScreen(),
                  '/chat': (context) => const ChatListScreen(),

                  '/teacher-dashboard': (context) =>
                      const TeacherDashboardScreen(),
                },
              );
            },
          ),
        );
      },
    );
  }

  // ─── Light Theme Configuration ───
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6C63FF),
        primary: const Color(0xFF6C63FF),
        secondary: const Color(0xFFFF6584),
        tertiary: const Color(0xFF00C9A7),
        surface: Colors.white,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Color(0xFF6C63FF),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
    );
  }

  // ─── Dark Theme Configuration ───
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6C63FF),
        primary: const Color(0xFF9B93FF),
        secondary: const Color(0xFFFF8FA3),
        tertiary: const Color(0xFF00E5C3),
        surface: const Color(0xFF1E1E2E),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF121220),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF1E1E2E),
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        color: const Color(0xFF252540),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E2E),
        selectedItemColor: Color(0xFF9B93FF),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF252540),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// AUTH WRAPPER — Decides which screen to show based on auth state
// Flow: No User → Login | Loading → LoadingScreen | Loaded → Role Screen
// ──────────────────────────────────────────────────────────
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        final user = authService.currentUser;
        final model = authService.userModel;

        // Step 1: No Firebase user → show Login
        if (user == null) {
          return const LoginScreen();
        }

        // Step 2: User exists but profile not loaded yet → Loading
        if (model == null) {
          return const _LoadingScreen();
        }

        // Step 3: Check if user is banned
        if (model.isBanned) {
          // Sign out banned users immediately
          WidgetsBinding.instance.addPostFrameCallback((_) {
            authService.signOut();
          });
          return const LoginScreen();
        }

        // Step 4: User loaded → route based on role
        switch (model.role) {
          case 'admin':
            return const AdminDashboardScreen();
          case 'teacher':
            return const TeacherDashboardScreen();
          case 'student':
            return const HomeScreen();
          case 'pending':
            // If user requested a specific role, show pending screen
            return const VerificationPendingScreen();
          default:
            // Unknown role — sign out to prevent stuck state
            WidgetsBinding.instance.addPostFrameCallback((_) {
              authService.signOut();
            });
            return const LoginScreen();
        }
      },
    );
  }
}

// ──────────────────────────────────────────────────────────
// LOADING SCREEN — Shown while user profile is being fetched
// Features: Manual cancel (5s), Auto-timeout (30s)
// ──────────────────────────────────────────────────────────
class _LoadingScreen extends StatefulWidget {
  const _LoadingScreen();

  @override
  State<_LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<_LoadingScreen> {
  bool _showManualButton = false;

  @override
  void initState() {
    super.initState();

    // Show manual "Go Back" button after 3 seconds (was 5)
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showManualButton = true);
    });

    // Auto-timeout: if profile doesn't load in 10s, force logout
    // User requested this to prevent getting stuck on "Firebase ready"
    Future.delayed(const Duration(seconds: 10), () {
      if (!mounted) return;
      // Only sign out if we're still stuck (model not loaded)
      final auth = Provider.of<AuthService>(context, listen: false);
      if (auth.userModel != null) return; // Already loaded, skip timeout

      debugPrint("⏰ [LoadingScreen] Auto-timeout (10s). Signing out.");
      auth.signOut();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Connection timed out. Reseting session..."),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Branded loading indicator
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  color: theme.primaryColor,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Setting up your session...",
                style: TextStyle(
                  fontSize: 16,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              if (_showManualButton) ...[
                const SizedBox(height: 32),
                const Text(
                  "Taking longer than expected...",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    Provider.of<AuthService>(context, listen: false).signOut();
                  },
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text("Back to Login"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
