import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/courses_screen.dart';
import 'screens/ai_tutor_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/teacher/teacher_dashboard_screen.dart';
import 'services/auth_service.dart';
import 'core/theme_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Ensure Flutter is ready
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Global Flutter Error Handling
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint("🛑 [Global Error] ${details.exception}");
  };

  // 2. Background/Async Error Handling (Smooth background work)
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint("🛑 [Async Error] $error");
    debugPrint("🛑 [Stacktrace] $stack");
    return true; // Handle error and prevent crash
  };

  debugPrint("🚀 [Main] App Starting...");

  // Run the app immediately to prove the engine is moving
  runApp(const MyApp());
}

// Global state for initialization
final Future<void> _firebaseInit = _initializeFirebase();

Future<void> _initializeFirebase() async {
  try {
    debugPrint("🔍 [Main] Stage 1: Initializing Firebase...");
    if (Firebase.apps.isEmpty) {
      final options = DefaultFirebaseOptions.currentPlatform;
      debugPrint("🔍 [Main] Using Project ID: ${options.projectId}");

      await Firebase.initializeApp(options: options);
      debugPrint("✅ [Main] Stage 1 Complete: Firebase Initialized");

      debugPrint("🔍 [Main] Stage 2: Configuring Firestore settings...");
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      debugPrint("✅ [Main] Stage 2 Complete: Firestore Settings Applied");
    }
  } catch (e, stack) {
    debugPrint("🔴 [Main] BOOT ERROR during Firebase Init: $e");
    debugPrint("🔴 [Stacktrace] $stack");
    rethrow;
  }
}

// Moving initialization logic to a managed place or keeping it simple in MyApp
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _firebaseInit,
      builder: (context, snapshot) {
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
                      "Initializing System...",
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

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
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Backend Connection Failed",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // In a real app, this might restart the init
                          debugPrint("Manual Retry Triggered");
                        },
                        child: const Text("Retry Connection"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => AuthService()),
          ],
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                title: 'E-Learning App',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  useMaterial3: true,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: const Color(0xFF6C63FF),
                    primary: const Color(0xFF6C63FF),
                    secondary: const Color(0xFFFF6584),
                    surface: Colors.white,
                  ),
                  textTheme: GoogleFonts.poppinsTextTheme(),
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                ),
                home: const AuthWrapper(),
                routes: {
                  '/login': (context) => const LoginScreen(),
                  '/signup': (context) => const SignupScreen(),
                  '/home': (context) => const HomeScreen(),
                  '/courses': (context) => const CoursesScreen(),
                  '/ai-tutor': (context) => const AITutorScreen(),
                  '/role-selection': (context) => const RoleSelectionScreen(),
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
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showFallback = false;

  @override
  void initState() {
    super.initState();
    // Reduce fallback timer for faster perceived loading
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _showFallback == false) {
        setState(() => _showFallback = true);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        final user = authService.currentUser;
        final model = authService.userModel;
        final loading = authService.isLoading;

        debugPrint(
          "🏗️ [AuthWrapper] Building: FirebaseUser=${user?.email ?? 'NULL'}, Model=${model != null ? 'READY' : 'NULL'}, Loading=$loading",
        );

        // 1. ABSOLUTE PRIORITY: If no Firebase user, we MUST show login
        if (user == null) {
          return const LoginScreen();
        }

        // If not loading anymore and we have state, cancel retry timer
        // User is loaded, proceed to role routing

        // 2. LOADING STATE: With safety fallback
        // We only show the global "Optimizing..." screen if we don't have a model yet (initial boot).
        if (model == null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (authService.authError != null) ...[
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Session Error",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        authService.authError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          authService.signOut();
                        },
                        child: const Text("Go to Login Page"),
                      ),
                    ] else ...[
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      const Text("Optimizing Session..."),
                      if (_showFallback) ...[
                        const SizedBox(height: 30),
                        const Text(
                          "Taking longer than expected...",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            debugPrint(
                              "🆘 [AuthWrapper] Fallback triggered. Forcing Sign Out.",
                            );
                            authService.signOut();
                          },
                          child: const Text("Go to Login Page"),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          );
        }

        // Role-based routing
        final role = model.role;

        if (role == 'admin') {
          return const AdminDashboardScreen();
        } else if (role == 'teacher') {
          return const TeacherDashboardScreen();
        } else if (role == 'student') {
          return const HomeScreen();
        } else if (role == 'pending') {
          // New user who hasn't picked a role yet
          return const RoleSelectionScreen();
        }

        // Fallback to RoleSelection only if role is explicitly identified as 'pending'
        // or unknown, but we should have a model here.
        return const Scaffold(
          body: Center(
            child: Text("Unknown user role. Please contact support."),
          ),
        );
      },
    );
  }
}
