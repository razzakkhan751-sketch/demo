import 'seed_helper.dart';

Future<void> ensureSwiftCourseExists({Duration? timeout}) async {
  final courseData = {
    "title": "Master Swift Programming",
    "description":
        "Learn Swift for iOS Development. From basic syntax to building full logic for iPhone apps. Covers SwiftUI concepts initially.",
    "category": "Swift",
    "thumbnail": "https://i.ytimg.com/vi/comQ1-x2a1Q/maxresdefault.jpg",
    "video_url": "https://youtu.be/comQ1-x2a1Q",
    "lessons": [
      {
        "title": "1. Swift Full Course for Beginners",
        "video_url": "https://youtu.be/comQ1-x2a1Q",
        "duration": "03:10:00",
      },
    ],
    "questions": [
      {
        "text": "Which keyword is used to define a constant in Swift?",
        "options": ["var", "let", "const", "static"],
        "correct_index": 1,
      },
    ],
  };

  await seedCourse(courseData, timeout: timeout);
}
