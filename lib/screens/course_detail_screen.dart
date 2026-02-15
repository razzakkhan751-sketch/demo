// ──────────────────────────────────────────────────────────
// course_detail_screen.dart — Individual Course View
// ──────────────────────────────────────────────────────────
// Shows: Course info, lessons list, video playback, quiz
// Data: Firestore (lessons, questions) + CacheService
// Supports: YouTube, direct URLs, and embedded video
// ──────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../services/progress_service.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/cache_service.dart';
import '../widgets/video_player_widget.dart';
import 'chat/chat_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;
  final int initialLessonIndex;

  const CourseDetailScreen({
    super.key,
    required this.course,
    this.initialLessonIndex = -1,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  int _currentLessonIndex = -1;
  final ProgressService _progressService = ProgressService();
  final DatabaseService _db = DatabaseService();
  final CacheService _cache = CacheService();
  String? _userId;

  List<Lesson> _lessons = [];
  List<Question> _questions = [];
  bool _isLoadingContent = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Get current user ID
    final authService = Provider.of<AuthService>(context, listen: false);
    _userId = authService.currentUser?.uid;

    if (_userId != null) {
      _loadContentAndRestore();
    } else {
      _loadContentOnly();
    }
  }

  Future<void> _loadContentOnly() async {
    await _loadSubCollections();
    _initializePlayer(widget.initialLessonIndex);
  }

  Future<void> _loadContentAndRestore() async {
    await _loadSubCollections();
    await _restoreProgress();
  }

  Future<void> _loadSubCollections() async {
    if (!mounted) return;
    setState(() => _isLoadingContent = true);

    final courseId = widget.course.id;

    try {
      // 1. Try loading from cache first for instant display
      final cachedLessons = await _cache.getCachedLessons(courseId);
      final cachedQuestions = await _cache.getCachedQuestions(courseId);

      if (cachedLessons != null && cachedQuestions != null && mounted) {
        setState(() {
          _lessons = cachedLessons.map((e) => Lesson.fromMap(e)).toList();
          _questions = cachedQuestions.map((e) => Question.fromMap(e)).toList();
          _isLoadingContent = false;
        });
        debugPrint('⚡ [CourseDetail] Loaded from cache');
      }

      // 2. Always fetch fresh data from Firebase in background
      final lessonsData = await _db.query(
        'courses/$courseId/lessons',
        orderBy: 'title ASC',
      );
      final questionsData = await _db.query('courses/$courseId/questions');

      // 3. Cache for next time
      await _cache.cacheLessons(courseId, lessonsData);
      await _cache.cacheQuestions(courseId, questionsData);

      if (mounted) {
        setState(() {
          _lessons = lessonsData.map((e) => Lesson.fromMap(e)).toList();
          _questions = questionsData.map((e) => Question.fromMap(e)).toList();
          _isLoadingContent = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading sub-collections: $e");
      if (mounted) setState(() => _isLoadingContent = false);
    }
  }

  Future<void> _restoreProgress() async {
    // 1. Check if we were passed an initial index (e.g. from Home Screen "Continue")
    if (widget.initialLessonIndex != -1) {
      _initializePlayer(widget.initialLessonIndex);
      return;
    }

    // 2. Otherwise, fetch from Firestore
    try {
      final db = DatabaseService();
      final response = await db.query(
        'user_progress',
        where: 'user_id = ? AND course_id = ?',
        whereArgs: [_userId!, widget.course.id],
        limit: 1,
      );

      if (response.isNotEmpty) {
        final lastIndex =
            int.tryParse(response.first['last_lesson_id'] ?? '-1') ?? -1;
        if (lastIndex != -1 && lastIndex < _lessons.length) {
          if (mounted) {
            _initializePlayer(lastIndex);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Resuming from lesson ${lastIndex + 1}")),
            );
          }
          return;
        }
      }
    } catch (e) {
      debugPrint("Error restoring progress: $e");
    }

    // 3. Fallback to start
    if (mounted) _initializePlayer(-1);
  }

  void _initializePlayer(int index) {
    if (!mounted) return;
    setState(() {
      _currentLessonIndex = index;
      String currentUrl = index == -1
          ? widget.course.videoUrl
          : (index < _lessons.length ? _lessons[index].videoUrl : "");

      _errorMessage = currentUrl.isEmpty ? "No video URL provided" : null;
    });
  }

  void _playLesson(int index) {
    String url = index >= 0 && index < _lessons.length
        ? _lessons[index].videoUrl
        : widget.course.videoUrl;

    setState(() {
      _currentLessonIndex = index;
      _errorMessage = url.isEmpty ? "No video URL provided" : null;
    });

    if (_userId != null && index >= 0 && _lessons.isNotEmpty) {
      _progressService.saveProgress(
        userId: _userId!,
        courseId: widget.course.id,
        lastLessonIndex: index,
        percentComplete: (index + 1) / _lessons.length,
      );
    }
  }

  void _playNext() {
    if (_currentLessonIndex < _lessons.length - 1) {
      _playLesson(_currentLessonIndex + 1);
    }
  }

  void _playPrevious() {
    if (_currentLessonIndex > -1) {
      _playLesson(_currentLessonIndex - 1);
    }
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  void _showReviewDialog(BuildContext context, String courseId) {
    final TextEditingController commentController = TextEditingController();
    double rating = 5.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Write a Review"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Rate this course:"),
                  Slider(
                    value: rating,
                    min: 1.0,
                    max: 5.0,
                    divisions: 4,
                    label: rating.toString(),
                    onChanged: (val) => setState(() => rating = val),
                  ),
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      labelText: "Your Review",
                      hintText: "What did you like?",
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_userId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please login to review")),
                      );
                      return;
                    }
                    Navigator.pop(context);

                    final user = Provider.of<AuthService>(
                      context,
                      listen: false,
                    ).userModel;
                    try {
                      final db = DatabaseService();
                      await db.insert('course_reviews', {
                        'course_id': courseId,
                        'user_id': _userId,
                        'user_name': user?.name ?? "Student",
                        'rating': rating,
                        'comment': commentController.text.trim(),
                      });

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Review submitted locally!"),
                        ),
                      );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                    }
                  },
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String courseId = widget.course.id;
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: DatabaseService().streamCollection(
        'courses',
        where: 'id = ?',
        whereArgs: [courseId],
      ),
      builder: (context, snapshot) {
        Course displayCourse = widget.course;
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          displayCourse = Course.fromMap(
            snapshot.data!.first,
            snapshot.data!.first['id'],
          );
        }

        String currentVideoUrl = displayCourse.videoUrl;
        if (_currentLessonIndex >= 0 && _currentLessonIndex < _lessons.length) {
          currentVideoUrl = _lessons[_currentLessonIndex].videoUrl;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(displayCourse.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.forum),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        roomId: courseId,
                        otherUserName: displayCourse.title,
                        otherUserRole: 'course',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (currentVideoUrl.isNotEmpty)
                  _buildVideoPlayer(currentVideoUrl),
                if (_isLoadingContent)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildCourseInfo(displayCourse),
                  ),
                  if (_questions.isNotEmpty) _buildQuizButton(displayCourse),
                  _buildNotesSection(displayCourse.category),
                  const Divider(),
                  _buildReviewsSection(courseId),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotesSection(String category) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Study Materials",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: DatabaseService().streamCollection(
              'notes',
              where: 'category = ?',
              whereArgs: [category],
            ),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text("Error: ${snapshot.error}");
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final notes = snapshot.data ?? [];
              if (notes.isEmpty) {
                return const Text(
                  "No supplementary notes available for this category.",
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                );
              }
              return Column(
                children: notes.map((data) {
                  final title = data['title'] ?? 'Untitled Note';
                  final pdfUrl = data['pdf_url'] ?? data['pdfUrl'];
                  final fileName =
                      data['file_name'] ?? data['fileName'] ?? "Download PDF";

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(
                        Icons.description,
                        color: Colors.blue,
                      ),
                      title: Text(title),
                      subtitle: Text(fileName),
                      trailing: pdfUrl != null
                          ? IconButton(
                              icon: const Icon(
                                Icons.download,
                                color: Colors.green,
                              ),
                              onPressed: () => launchUrl(
                                Uri.parse(pdfUrl),
                                mode: LaunchMode.externalApplication,
                              ),
                            )
                          : null,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(String currentVideoUrl) {
    if (_errorMessage != null) {
      return Container(
        height: 250,
        width: double.infinity,
        color: Colors.black87,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _initializePlayer(_currentLessonIndex),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        VideoPlayerWidget(
          videoUrl: currentVideoUrl,
          key: ValueKey(currentVideoUrl),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: _currentLessonIndex > -1 ? _playPrevious : null,
                icon: const Icon(Icons.skip_previous),
                tooltip: "Previous Lesson",
              ),
              IconButton(
                onPressed: _currentLessonIndex < _lessons.length - 1
                    ? _playNext
                    : null,
                icon: const Icon(Icons.skip_next),
                tooltip: "Next Lesson",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCourseInfo(Course displayCourse) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayCourse.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(displayCourse.description, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 24),
        const Text(
          "Lessons",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_lessons.isEmpty)
          const Text("No lessons yet.")
        else
          ..._lessons.asMap().entries.map((entry) {
            int idx = entry.key;
            var lesson = entry.value;
            bool isPlaying = _currentLessonIndex == idx;
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: isPlaying
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                    : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: Icon(
                  isPlaying
                      ? Icons.play_circle_filled
                      : Icons.play_circle_outline,
                  color: isPlaying
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                title: Text(
                  lesson.title,
                  style: TextStyle(
                    fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                    color: isPlaying ? Theme.of(context).primaryColor : null,
                  ),
                ),
                subtitle: Text(lesson.duration),
                onTap: () => _playLesson(idx),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildQuizButton(Course displayCourse) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.quiz),
          label: Text(
            "Start Coding Knowledge Check (${_questions.length} Questions)",
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CourseQuizScreen(course: displayCourse),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsSection(String courseId) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Reviews",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () => _showReviewDialog(context, courseId),
                icon: const Icon(Icons.rate_review),
                label: const Text("Write a Review"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: DatabaseService().query(
              'course_reviews',
              where: 'course_id = ?',
              whereArgs: [courseId],
              orderBy: 'created_at DESC',
            ),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final reviews = snapshot.data!;
              if (reviews.isEmpty) {
                return const Center(
                  child: Text(
                    "No reviews yet. Be the first to review!",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              return Column(
                children: reviews.map((data) {
                  final rating = (data['rating'] as num?)?.toDouble() ?? 0.0;
                  final comment = data['comment'] as String? ?? "";
                  final userName = data['user_name'] as String? ?? "Anonymous";
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(userName[0].toUpperCase()),
                      ),
                      title: Row(
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(" $rating"),
                        ],
                      ),
                      subtitle: Text(comment),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Reconstructed CourseQuizScreen
class CourseQuizScreen extends StatefulWidget {
  final Course course;
  const CourseQuizScreen({super.key, required this.course});

  @override
  State<CourseQuizScreen> createState() => _CourseQuizScreenState();
}

class _CourseQuizScreenState extends State<CourseQuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _showResult = false;

  void _answerQuestion(int selectedIndex) {
    if (selectedIndex ==
        widget.course.questions[_currentQuestionIndex].correctIndex) {
      _score++;
    }

    setState(() {
      if (_currentQuestionIndex < widget.course.questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _showResult = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showResult) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quiz Result")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Your Score: $_score / ${widget.course.questions.length}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Back to Course"),
              ),
            ],
          ),
        ),
      );
    }

    final question = widget.course.questions[_currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(title: Text("Quiz: ${widget.course.title}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Question ${_currentQuestionIndex + 1} of ${widget.course.questions.length}",
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              question.text,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...List.generate(question.options.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                  ),
                  onPressed: () => _answerQuestion(index),
                  child: Text(
                    question.options[index],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
