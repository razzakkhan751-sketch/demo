import 'seed_helper.dart';

Future<void> ensureJavascriptCourseExists({Duration? timeout}) async {
  final courseData = {
    "title": "JavaScript Mastery",
    "description":
        "Master the language of the web. Learn ES6+, Async/Await, and modern JavaScript patterns.",
    "category": "JavaScript",
    "thumbnail": "https://i.ytimg.com/vi/W6NZ1cH5X-E/maxresdefault.jpg",
    "video_url": "https://youtu.be/W6NZ1cH5X-E",
    "lessons": [
      {
        "title": "1. JS Full Course for Beginners",
        "video_url": "https://youtu.be/W6NZ1cH5X-E",
        "duration": "1:00:00",
      },
    ],
    "questions": [
      {
        "text": "What does DOM stand for?",
        "options": [
          "Document Object Model",
          "Data Object Management",
          "Digital Object Mapping",
          "Direct Operations Manual",
        ],
        "correct_index": 0,
      },
    ],
  };

  await seedCourse(courseData, timeout: timeout);
}
