import 'seed_helper.dart';

Future<void> ensureJavaCourseExists({Duration? timeout}) async {
  final courseData = {
    "title": "Java Masterclass",
    "description":
        "Become a master Java programmer. Learn OOP, multi-threading, and enterprise development with one of the most powerful languages.",
    "category": "Java",
    "thumbnail": "https://i.ytimg.com/vi/eIrMbAQSU34/maxresdefault.jpg",
    "video_url": "https://youtu.be/eIrMbAQSU34",
    "lessons": [
      {
        "title": "1. Java Tutorial for Beginners",
        "video_url": "https://youtu.be/eIrMbAQSU34",
        "duration": "2:00:00",
      },
      {
        "title": "2. Object Oriented Programming in Java",
        "video_url": "https://youtu.be/mAtkpqZmzT4",
        "duration": "45:00",
      },
    ],
    "questions": [
      {
        "text": "Which company originally developed Java?",
        "options": ["Microsoft", "Google", "Sun Microsystems", "Apple"],
        "correct_index": 2,
      },
    ],
  };

  await seedCourse(courseData, timeout: timeout);
}
