import 'dart:convert';

class Course {
  final String id;
  final String title;
  final String description;
  final String thumbnail;
  final String category;
  final String videoUrl;
  final List<Lesson> lessons;
  final List<Section> sections;
  final List<dynamic> questions;
  final String authorId;
  final String authorName;
  final String level;

  Course({
    this.id = '',
    this.title = '',
    this.description = '',
    this.thumbnail = '',
    this.videoUrl = '',
    this.category = 'General',
    this.lessons = const [],
    this.sections = const [],
    this.questions = const [],
    this.authorId = '',
    this.authorName = '',
    this.level = 'Beginner',
  });

  factory Course.fromMap(Map<String, dynamic> data, String documentId) {
    dynamic lessonsData = data['lessons'];
    if (lessonsData is String && lessonsData.isNotEmpty) {
      try {
        lessonsData = jsonDecode(lessonsData);
      } catch (e) {
        lessonsData = [];
      }
    }

    dynamic questionsData = data['questions'];
    if (questionsData is String && questionsData.isNotEmpty) {
      try {
        questionsData = jsonDecode(questionsData);
      } catch (e) {
        questionsData = [];
      }
    }

    return Course(
      id: documentId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      thumbnail: data['thumbnail'] ?? '',
      videoUrl: data['video_url'] ?? data['videoUrl'] ?? '',
      category: data['category'] ?? 'General',
      lessons:
          (lessonsData as List<dynamic>?)
              ?.map((e) => Lesson.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      questions:
          (questionsData as List<dynamic>?)
              ?.map((e) => Question.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      authorId: (data['author_id'] ?? data['authorId'] ?? '').toString(),
      authorName: (data['author_name'] ?? data['authorName'] ?? '').toString(),
      level: data['level'] ?? 'Beginner',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
      'video_url': videoUrl,
      'category': category,
      'lessons': lessons.map((e) => e.toMap()).toList(),
      'questions': questions.map((e) => e.toMap()).toList(),
      'author_id': authorId,
      'author_name': authorName,
      'level': level,
    };
  }
}

class Question {
  final String text;
  final List<String> options;
  final int correctIndex;

  Question({
    required this.text,
    required this.options,
    required this.correctIndex,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      text: map['text'] ?? '',
      options: (map['options'] as List<dynamic>?)?.cast<String>() ?? [],
      correctIndex: map['correct_index'] ?? map['correctIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'text': text, 'options': options, 'correct_index': correctIndex};
  }
}

class Lesson {
  final String title;
  final String videoUrl;
  final String duration;

  Lesson({this.title = '', this.videoUrl = '', this.duration = ''});

  factory Lesson.fromMap(Map<String, dynamic> data) {
    return Lesson(
      title: data['title'] ?? '',
      videoUrl: data['video_url'] ?? data['videoUrl'] ?? '',
      duration: data['duration'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'video_url': videoUrl, 'duration': duration};
  }
}

class Section {
  // Placeholder for Section if needed
  final String title;
  Section({this.title = ''});
}
