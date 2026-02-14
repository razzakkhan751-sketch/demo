import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course.dart';
import '../../models/note.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../course_detail_screen.dart';

class GlobalSearchDelegate extends SearchDelegate {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Beginner', 'Intermediate', 'Advanced'];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchContent(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchContent(context);
  }

  Widget _buildSearchContent(BuildContext context) {
    final db = DatabaseService();
    final user = Provider.of<AuthService>(context, listen: false).userModel;

    return Column(
      children: [
        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: _filters.map((filter) {
              final isSelected = _selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      _selectedFilter = filter;
                      query = query;
                      showSuggestions(context);
                    }
                  },
                  selectedColor: Colors.blue.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.blue : Colors.black87,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Results
        Expanded(
          child: FutureBuilder(
            future: Future.wait([
              db.query('courses'),
              if (user != null)
                db.query('notes', where: 'author_id = ?', whereArgs: [user.uid])
              else
                Future.value([]),
            ]),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              final rawCourses =
                  snapshot.data?[0] as List<Map<String, dynamic>>? ?? [];
              final rawNotes =
                  snapshot.data?[1] as List<Map<String, dynamic>>? ?? [];

              final allCourses = rawCourses
                  .map((d) => Course.fromMap(d, d['id']))
                  .toList();
              final allNotes = rawNotes
                  .map((d) => Note.fromMap(d, d['id']))
                  .toList();

              final lowerQuery = query.toLowerCase();

              // 1. Filter Courses
              final matchedCourses = allCourses.where((c) {
                final matchesQuery =
                    c.title.toLowerCase().contains(lowerQuery) ||
                    c.category.toLowerCase().contains(lowerQuery);
                final matchesFilter =
                    _selectedFilter == 'All' || c.level == _selectedFilter;
                return matchesQuery && matchesFilter;
              }).toList();

              // 2. Filter Lessons
              final List<Map<String, dynamic>> matchedLessons = [];
              for (var course in allCourses) {
                if (_selectedFilter != 'All' &&
                    course.level != _selectedFilter) {
                  continue;
                }
                for (int i = 0; i < course.lessons.length; i++) {
                  if (course.lessons[i].title.toLowerCase().contains(
                    lowerQuery,
                  )) {
                    matchedLessons.add({
                      'course': course,
                      'lessonIndex': i,
                      'lesson': course.lessons[i],
                    });
                  }
                }
              }

              // 3. Filter Notes
              final matchedNotes = (_selectedFilter == 'All')
                  ? allNotes
                        .where(
                          (n) =>
                              n.title.toLowerCase().contains(lowerQuery) ||
                              n.content.toLowerCase().contains(lowerQuery),
                        )
                        .toList()
                  : <Note>[];

              if (matchedCourses.isEmpty &&
                  matchedLessons.isEmpty &&
                  matchedNotes.isEmpty) {
                return const Center(child: Text("No results found."));
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (matchedCourses.isNotEmpty) ...[
                    const Text(
                      "Courses",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...matchedCourses.map(
                      (course) => ListTile(
                        leading: SizedBox(
                          width: 50,
                          height: 50,
                          child: course.thumbnail.isNotEmpty
                              ? Image.network(
                                  course.thumbnail,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.school),
                        ),
                        title: Text(course.title),
                        subtitle: Text("${course.category} • ${course.level}"),
                        onTap: () {
                          close(context, null);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CourseDetailScreen(course: course),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(),
                  ],
                  if (matchedLessons.isNotEmpty) ...[
                    const Text(
                      "Lessons",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...matchedLessons.map((item) {
                      final Course course = item['course'];
                      final int index = item['lessonIndex'];
                      final lesson = item['lesson'];
                      return ListTile(
                        leading: const Icon(
                          Icons.play_circle_fill,
                          color: Colors.red,
                        ),
                        title: Text(lesson.title),
                        subtitle: Text("In: ${course.title} (${course.level})"),
                        onTap: () {
                          close(context, null);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CourseDetailScreen(
                                course: course,
                                initialLessonIndex: index,
                              ),
                            ),
                          );
                        },
                      );
                    }),
                    const Divider(),
                  ],
                  if (matchedNotes.isNotEmpty) ...[
                    const Text(
                      "Notes",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...matchedNotes.map(
                      (note) => ListTile(
                        leading: const Icon(Icons.note, color: Colors.orange),
                        title: Text(note.title),
                        subtitle: Text(
                          note.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          close(context, null);
                          _showNoteDialog(context, note);
                        },
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  void _showNoteDialog(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note.title),
        content: SingleChildScrollView(child: Text(note.content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}
