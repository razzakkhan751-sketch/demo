import 'seed_helper.dart';

Future<void> ensureCCourseExists({Duration? timeout}) async {
  await seedCourse({
    "title": "Mastering C Programming",
    "description":
        "The foundation of computer science. Learn variables, pointers, memory management, and system-level programming.",
    "category": "C Programming",
    "thumbnail": "https://i.ytimg.com/vi/itM8C_6Xzlo/maxresdefault.jpg",
    "video_url": "https://youtu.be/itM8C_6Xzlo",
    "lessons": [
      {
        "title": "1. C Programming Full Course",
        "video_url": "https://youtu.be/itM8C_6Xzlo",
        "duration": "10:30:00",
      },
      {
        "title": "2. Memory & Pointers in C",
        "video_url": "https://youtu.be/zuegQmMd8MA",
        "duration": "01:45:00",
      },
      {
        "title": "3. Data Structures in C",
        "video_url": "https://youtu.be/zX6yB4sS4r0",
        "duration": "05:00:00",
      },
      {
        "title": "4. Algorithms and Complexity",
        "video_url": "https://youtu.be/RBSGKlAvoir",
        "duration": "02:15:00",
      },
      {
        "title": "5. C Projects: Build a Simple OS",
        "video_url": "https://youtu.be/fN6fayf6WvM",
        "duration": "03:00:00",
      },
    ],
    "questions": [
      {
        "text": "What is a pointer in C?",
        "options": [
          "A variable that stores a value",
          "A variable that stores a memory address",
          "A function",
          "A keyword",
        ],
        "correct_index": 1,
      },
      {
        "text": "Which operator is used to get the address of a variable?",
        "options": ["*", "&", "#", "@"],
        "correct_index": 1,
      },
      {
        "text": "What is the result of 'sizeof(int)' on most 64-bit systems?",
        "options": ["2 bytes", "4 bytes", "8 bytes", "1 byte"],
        "correct_index": 1,
      },
    ],
  }, timeout: timeout);
}
