import 'package:flutter/foundation.dart';
import 'services/database_service.dart';

// Standalone script to help debug or fix database issues
// You can run this by calling debugCheckUsers() from anywhere in the app for debugging.

Future<void> debugCheckUsers() async {
  try {
    debugPrint("🔍 [DEBUG] Checking 'users' table in Local DB...");
    final db = DatabaseService();
    final List<Map<String, dynamic>> data = await db.query('users');

    if (data.isEmpty) {
      debugPrint("⚠️ [DEBUG] No profiles found in Local DB!");
    } else {
      debugPrint("✅ [DEBUG] Found ${data.length} profiles:");
      for (var item in data) {
        debugPrint(
          "   - ID: ${item['id']}, Email: ${item['email']}, Role: ${item['role']}",
        );
      }
    }
  } catch (e) {
    debugPrint("🔴 [DEBUG] Error checking users in Local DB: $e");
  }
}
