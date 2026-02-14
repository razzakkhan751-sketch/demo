import 'seed_helper.dart';

Future<void> ensureKotlinCourseExists({Duration? timeout}) async {
  final courseData = {
    "title": "Master Kotlin Programming",
    "description":
        "Learn Kotlin from scratch. The tailored language for modern Android development, focusing on conciseness and safety.",
    "category": "Kotlin",
    "thumbnail": "https://i.ytimg.com/vi/F9UC9DY-vIU/maxresdefault.jpg",
    "video_url": "https://youtu.be/F9UC9DY-vIU",
    "lessons": [
      {
        "title": "1. Kotlin Full Course for Beginners",
        "video_url": "https://youtu.be/F9UC9DY-vIU",
        "duration": "11:30:00",
      },
      {
        "title": "2. Variables (val vs var)",
        "video_url": "https://youtu.be/5flXf8bvxFk",
        "duration": "10:15",
      },
      {
        "title": "3. Functions & Parameters",
        "video_url": "https://youtu.be/F1pX9p5oBJA",
        "duration": "12:40",
      },
      {
        "title": "4. Control Flow (If/Else/When)",
        "video_url": "https://youtu.be/Qy8A-hFceFs",
        "duration": "14:20",
      },
      {
        "title": "5. Loops & Ranger",
        "video_url": "https://youtu.be/7y-BwQyT9h0",
        "duration": "11:50",
      },
      {
        "title": "6. Null Safety (The Billion Dollar Mistake)",
        "video_url": "https://youtu.be/bC7G9RsOqT8",
        "duration": "15:30",
      },
      {
        "title": "7. Classes & Objects",
        "video_url": "https://youtu.be/m3WwQhQ7qGg",
        "duration": "16:45",
      },
      {
        "title": "8. Inheritance & Open Classes",
        "video_url": "https://youtu.be/t2rS5v9bT9c",
        "duration": "13:10",
      },
      {
        "title": "9. Lambda Expressions",
        "video_url": "https://youtu.be/V6gV5B_X_Xw",
        "duration": "12:20",
      },
      {
        "title": "10. Coroutines (Async Programming)",
        "video_url": "https://youtu.be/C38lG2F-4-4",
        "duration": "20:00",
      },
    ],
    "questions": [
      {
        "text": "Which keyword declares a read-only variable in Kotlin?",
        "options": ["var", "val", "const", "static"],
        "correct_index": 1,
      },
      {
        "text": "What is the replacement for 'switch' statements in Kotlin?",
        "options": ["switch", "case", "when", "match"],
        "correct_index": 2,
      },
      {
        "text": "Which symbol is used for safe calls on nullable types?",
        "options": ["!!", "?.", "?:", "*"],
        "correct_index": 1,
      },
      {
        "text": "What is the entry point of a Kotlin application?",
        "options": [
          "void main()",
          "fun main()",
          "public static void main",
          "start()",
        ],
        "correct_index": 1,
      },
    ],
  };

  await seedCourse(courseData, timeout: timeout);
}
