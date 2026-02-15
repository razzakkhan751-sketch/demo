// ──────────────────────────────────────────────────────────
// AdminLecturesScreen — Manage lectures within a chapter
// Each lecture has: title, video URL, content/notes, quiz
// ──────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../models/course.dart';
import '../../services/course_content_service.dart';

class AdminLecturesScreen extends StatefulWidget {
  final String courseId;
  final String chapterId;
  final String chapterTitle;
  const AdminLecturesScreen({
    super.key,
    required this.courseId,
    required this.chapterId,
    required this.chapterTitle,
  });

  @override
  State<AdminLecturesScreen> createState() => _AdminLecturesScreenState();
}

class _AdminLecturesScreenState extends State<AdminLecturesScreen> {
  final CourseContentService _service = CourseContentService();
  bool _isLoading = true;
  List<Lecture> _lectures = [];

  @override
  void initState() {
    super.initState();
    _loadLectures();
  }

  Future<void> _loadLectures() async {
    setState(() => _isLoading = true);
    final course = await _service.getCourse(widget.courseId);
    if (mounted && course != null) {
      Chapter? chapter;
      try {
        chapter = course.chapters.firstWhere(
          (c) => c.id == widget.chapterId,
        );
      } catch (_) {
        chapter = null;
      }
      setState(() {
        _lectures = chapter?.lectures ?? [];
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showLectureForm({Lecture? lecture}) {
    final titleCtrl = TextEditingController(text: lecture?.title ?? '');
    final videoCtrl = TextEditingController(text: lecture?.videoUrl ?? '');
    final durationCtrl = TextEditingController(text: lecture?.duration ?? '');
    final contentCtrl = TextEditingController(text: lecture?.content ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                lecture == null ? 'Add Lecture' : 'Edit Lecture',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Lecture Title *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: videoCtrl,
                decoration: const InputDecoration(
                  labelText: 'YouTube Video URL',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.video_library),
                  hintText: 'https://www.youtube.com/watch?v=...',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Duration (e.g., 15:00)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notes / Content (Markdown)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                  alignLabelWithHint: true,
                ),
                maxLines: 6,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () async {
                  if (titleCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Title is required')),
                    );
                    return;
                  }
                  Navigator.pop(ctx);

                  if (lecture == null) {
                    await _service.addLecture(
                      widget.courseId,
                      widget.chapterId,
                      Lecture(
                        title: titleCtrl.text.trim(),
                        videoUrl: videoCtrl.text.trim(),
                        duration: durationCtrl.text.trim(),
                        content: contentCtrl.text.trim(),
                      ),
                    );
                  } else {
                    await _service.updateLecture(
                      widget.courseId,
                      widget.chapterId,
                      lecture.id,
                      {
                        'title': titleCtrl.text.trim(),
                        'video_url': videoCtrl.text.trim(),
                        'duration': durationCtrl.text.trim(),
                        'content': contentCtrl.text.trim(),
                      },
                    );
                  }
                  _loadLectures();
                },
                icon: Icon(lecture == null ? Icons.add : Icons.save),
                label: Text(lecture == null ? 'Add Lecture' : 'Save Changes'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteLecture(Lecture lecture) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Lecture'),
        content: Text('Delete "${lecture.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _service.deleteLecture(
        widget.courseId,
        widget.chapterId,
        lecture.id,
      );
      _loadLectures();
    }
  }

  void _showQuizEditor(Lecture lecture) {
    final questions = List<Question>.from(lecture.questions);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _QuizEditorSheet(
        questions: questions,
        onSave: (updatedQuestions) async {
          await _service.updateLecture(
            widget.courseId,
            widget.chapterId,
            lecture.id,
            {'questions': updatedQuestions.map((q) => q.toMap()).toList()},
          );
          _loadLectures();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.chapterTitle), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLectureForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Lecture'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lectures.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_lesson_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text('No lectures yet', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text('Tap + to add the first lecture'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _lectures.length,
              itemBuilder: (context, index) {
                final lecture = _lectures[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lecture.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (lecture.duration.isNotEmpty)
                                    Text(
                                      lecture.duration,
                                      style: TextStyle(
                                        color: theme.colorScheme.outline,
                                        fontSize: 13,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          children: [
                            if (lecture.videoUrl.isNotEmpty)
                              const Chip(
                                avatar: Icon(
                                  Icons.play_circle_outline,
                                  size: 18,
                                ),
                                label: Text('Video'),
                                visualDensity: VisualDensity.compact,
                              ),
                            if (lecture.content.isNotEmpty)
                              const Chip(
                                avatar: Icon(Icons.notes, size: 18),
                                label: Text('Notes'),
                                visualDensity: VisualDensity.compact,
                              ),
                            Chip(
                              avatar: const Icon(Icons.quiz_outlined, size: 18),
                              label: Text('${lecture.questions.length} Quiz Q'),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton.icon(
                              onPressed: () =>
                                  _showLectureForm(lecture: lecture),
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Edit'),
                            ),
                            TextButton.icon(
                              onPressed: () => _showQuizEditor(lecture),
                              icon: const Icon(Icons.quiz, size: 18),
                              label: const Text('Quiz'),
                            ),
                            TextButton.icon(
                              onPressed: () => _deleteLecture(lecture),
                              icon: const Icon(
                                Icons.delete,
                                size: 18,
                                color: Colors.red,
                              ),
                              label: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ─── Quiz Editor Sheet ───

class _QuizEditorSheet extends StatefulWidget {
  final List<Question> questions;
  final Function(List<Question>) onSave;
  const _QuizEditorSheet({required this.questions, required this.onSave});

  @override
  State<_QuizEditorSheet> createState() => _QuizEditorSheetState();
}

class _QuizEditorSheetState extends State<_QuizEditorSheet> {
  late List<_QuestionDraft> _drafts;

  @override
  void initState() {
    super.initState();
    _drafts = widget.questions
        .map(
          (q) => _QuestionDraft(
            text: q.text,
            options: List<String>.from(q.options),
            correctIndex: q.correctIndex,
          ),
        )
        .toList();
  }

  void _addQuestion() {
    setState(() {
      _drafts.add(
        _QuestionDraft(text: '', options: ['', '', '', ''], correctIndex: 0),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Quiz Questions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(
                onPressed: _addQuestion,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _drafts.length,
              itemBuilder: (context, index) {
                final draft = _drafts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Q${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                setState(() => _drafts.removeAt(index));
                              },
                              icon: const Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        TextField(
                          controller: TextEditingController(text: draft.text),
                          decoration: const InputDecoration(
                            labelText: 'Question',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (v) => draft.text = v,
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(4, (oi) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Radio<int>(
                                  value: oi,
                                  groupValue: draft.correctIndex,
                                  onChanged: (v) {
                                    setState(() => draft.correctIndex = v!);
                                  },
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: TextEditingController(
                                      text: oi < draft.options.length
                                          ? draft.options[oi]
                                          : '',
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'Option ${oi + 1}',
                                      border: const OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                    onChanged: (v) {
                                      while (draft.options.length <= oi) {
                                        draft.options.add('');
                                      }
                                      draft.options[oi] = v;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {
              final questions = _drafts
                  .where((d) => d.text.isNotEmpty)
                  .map(
                    (d) => Question(
                      text: d.text,
                      options: d.options,
                      correctIndex: d.correctIndex,
                    ),
                  )
                  .toList();
              Navigator.pop(context);
              widget.onSave(questions);
            },
            icon: const Icon(Icons.save),
            label: const Text('Save Quiz'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _QuestionDraft {
  String text;
  List<String> options;
  int correctIndex;

  _QuestionDraft({
    required this.text,
    required this.options,
    required this.correctIndex,
  });
}
