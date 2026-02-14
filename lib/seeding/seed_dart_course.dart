import 'seed_helper.dart';

Future<void> ensureDartCourseExists({Duration? timeout}) async {
  final courseData = {
    "title": "Dart Programming Zero to Hero",
    "description":
        "Learn Dart, the language behind Flutter. Master the syntax and reactive programming.",
    "category": "Dart",
    "thumbnail": "https://i.ytimg.com/vi/5xlVP04805w/maxresdefault.jpg",
    "video_url": "https://youtu.be/5xlVP04805w",
    "lessons": [
      {
        "title": "1. Dart Full Course - 3 Hours",
        "video_url": "https://youtu.be/5xlVP04805w",
        "duration": "3:10:00",
      },
    ],
    "questions": [
      {
        "text": "Is Dart a statically typed language?",
        "options": ["Yes", "No", "Only if configured", "Sometimes"],
        "correct_index": 0,
      },
    ],
  };

  await seedCourse(courseData, timeout: timeout);
}
