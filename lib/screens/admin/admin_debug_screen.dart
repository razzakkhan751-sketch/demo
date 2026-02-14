import 'package:flutter/material.dart';

import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import 'package:provider/provider.dart';

class AdminDebugScreen extends StatefulWidget {
  const AdminDebugScreen({super.key});

  @override
  State<AdminDebugScreen> createState() => _AdminDebugScreenState();
}

class _AdminDebugScreenState extends State<AdminDebugScreen> {
  String _debugLog = 'Tap a button to run diagnostics...\n';
  bool _isLoading = false;
  final _db = DatabaseService();

  void _addLog(String message) {
    setState(() {
      _debugLog += '\n$message';
    });
    debugPrint(message);
  }

  Future<void> _checkDatabaseConnection() async {
    setState(() {
      _isLoading = true;
      _debugLog = '🔍 Testing Local Database Connection...\n';
    });

    try {
      _addLog('✅ Attempting to fetch profiles count...');
      final response = await _db.query('users', limit: 1);
      _addLog('✅ Fetch successful! Data: $response');
      _addLog('✅ Firestore connection is working perfectly!');
    } catch (e) {
      _addLog('❌ ERROR: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkProfilesTable() async {
    setState(() {
      _isLoading = true;
      _debugLog = '🔍 Checking Local Profiles Table...\n';
    });

    try {
      _addLog('📊 Querying all profiles...');
      final List<Map<String, dynamic>> data = await _db.query('users');

      _addLog('📊 Profiles returned: ${data.length}');

      if (data.isEmpty) {
        _addLog('⚠️ WARNING: No users exist in the profiles table.');
      } else {
        _addLog('✅ Profiles found:');
        for (var item in data) {
          _addLog('   📌 ID: ${item['id']}');
          _addLog('      Email: ${item['email'] ?? 'NO EMAIL'}');
          _addLog('      Name: ${item['name'] ?? 'NO NAME'}');
          _addLog('      Role: ${item['role'] ?? 'NO ROLE'}');
          _addLog('   ---');
        }
      }
    } catch (e) {
      _addLog('❌ ERROR querying profiles: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkAuthSession() async {
    setState(() {
      _isLoading = true;
      _debugLog = '🔍 Checking Firebase Auth Session...\n';
    });

    try {
      final userModel = Provider.of<AuthService>(
        context,
        listen: false,
      ).userModel;
      if (userModel == null) {
        _addLog('❌ No active auth session or user model found!');
      } else {
        _addLog('✅ Current Firebase User:');
        _addLog('   UID: ${userModel.uid}');
        _addLog('   Email: ${userModel.email}');
        _addLog('\n📊 Checking local profiles table for this UID...');
        final profile = await _db.query(
          'users',
          where: 'id = ?',
          whereArgs: [userModel.uid],
          limit: 1,
        );

        if (profile.isNotEmpty) {
          _addLog('✅ Profile exists in local database!');
          _addLog('   Data: ${profile.first}');
        } else {
          _addLog(
            '❌ WARNING: User has active session but NO profile in local database!',
          );
        }
      }
    } catch (e) {
      _addLog('❌ ERROR: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Diagnostics'),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.storage),
                  label: const Text('Test Local DB Connection'),
                  onPressed: _isLoading ? null : _checkDatabaseConnection,
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.people),
                  label: const Text('Check Profiles Table'),
                  onPressed: _isLoading ? null : _checkProfilesTable,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.account_circle),
                  label: const Text('Check Firebase Session'),
                  onPressed: _isLoading ? null : _checkAuthSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: Container(
              color: Colors.black87,
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Text(
                  _debugLog,
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    color: Colors.greenAccent,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            const LinearProgressIndicator(
              backgroundColor: Colors.black12,
              color: Colors.blue,
            ),
        ],
      ),
    );
  }
}
