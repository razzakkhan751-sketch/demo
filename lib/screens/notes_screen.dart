// ──────────────────────────────────────────────────────────
// notes_screen.dart — Study Notes Browser
// ──────────────────────────────────────────────────────────
// Displays: Notes from Firestore with content preview
// Supports: Language-specific notes with formatted content
// ──────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../services/note_service.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final noteService = NoteService();

    return Scaffold(
      appBar: AppBar(title: const Text('Study Notes')),
      body: StreamBuilder<List<Note>>(
        stream: noteService.getNotesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notes = snapshot.data ?? [];
          if (notes.isEmpty) {
            return const Center(child: Text('No notes available yet.'));
          }

          // Group notes by category
          final Map<String, List<Note>> groupedNotes = {};
          for (var note in notes) {
            final category = note.category.isNotEmpty
                ? note.category
                : 'General';
            if (!groupedNotes.containsKey(category)) {
              groupedNotes[category] = [];
            }
            groupedNotes[category]!.add(note);
          }

          final sortedCategories = groupedNotes.keys.toList()..sort();

          // Flatten categories and notes into a single list for efficient rendering
          final List<dynamic> flattenedList = [];
          for (var category in sortedCategories) {
            flattenedList.add(category); // String for category header
            flattenedList.addAll(groupedNotes[category]!); // Note objects
          }

          return ListView.builder(
            itemCount: flattenedList.length,
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final item = flattenedList[index];

              if (item is String) {
                // Category Header
                return Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Text(
                    item,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                );
              }

              final note = item as Note;
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              note.title,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (note.authorName.isNotEmpty)
                            Text(
                              "by ${note.authorName}",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat.yMMMd().add_jm().format(note.createdAt),
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(height: 1),
                      ),
                      Text(
                        note.content,
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      if (note.pdfUrl != null && note.pdfUrl!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildNoteAction(
                                  context,
                                  icon: Icons.visibility,
                                  label: "View PDF",
                                  color: Colors.red,
                                  onTap: () async {
                                    final uri = Uri.parse(note.pdfUrl!);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildNoteAction(
                                  context,
                                  icon: Icons.download,
                                  label: "Download",
                                  color: Colors.blue,
                                  onTap: () => _downloadFile(
                                    context,
                                    note.pdfUrl!,
                                    note.fileName ?? "note.pdf",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNoteAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadFile(
    BuildContext context,
    String url,
    String fileName,
  ) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final savePath = "${dir.path}/$fileName";
      final dio = Dio();
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      await dio.download(url, savePath);
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Downloaded to $savePath"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }
}
