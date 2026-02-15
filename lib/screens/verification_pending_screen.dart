// ──────────────────────────────────────────────────────────
// verification_pending_screen.dart
// Shown when a user has signed up and is waiting for admin approval
// ──────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class VerificationPendingScreen extends StatelessWidget {
  const VerificationPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).userModel;
    final requestedRole = user?.requestedRole ?? 'User';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // Use theme background instead of hardcoded white
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated hourglass icon with gradient container
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: isDark ? 0.15 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  size: 64,
                  color: Colors.orange,
                ),
              ),

              const SizedBox(height: 32),

              // Title — uses theme text color
              Text(
                "Verification Pending",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description — explains what's happening
              Text(
                "You have signed up as a ${requestedRole.toUpperCase()}.\n"
                "Your account is currently under review by the administrator.",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Helpful info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.blue.withValues(alpha: 0.1)
                      : Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: isDark ? Colors.blue[300] : Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "You will get access once the admin approves your request.",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: isDark ? Colors.blue[300] : Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Sign out button
              OutlinedButton.icon(
                onPressed: () {
                  Provider.of<AuthService>(context, listen: false).signOut();
                },
                icon: const Icon(Icons.logout),
                label: const Text("Sign Out"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
