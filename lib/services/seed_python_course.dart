import 'seed_helper.dart';

Future<void> ensurePythonCourseExists({Duration? timeout}) async {
  final courseData = {
    "title": "Python for Data Science",
    "description":
        "Learn Python basics and how to use it for data manipulation and visualization.",
    "category": "Python",
    "thumbnail": "https://i.ytimg.com/vi/rfscVS0vtbw/maxresdefault.jpg",
    "video_url": "https://youtu.be/rfscVS0vtbw",
    "lessons": [
      {
        "title": "1. Python for Beginners - Full Course",
        "video_url": "https://youtu.be/rfscVS0vtbw", // Free Hosting
        "duration": "6:00:00",
      },
      {
        "title": "2. Python Data structures",
        "video_url": "https://youtu.be/8DvywoWv6fI",
        "duration": "5:30:00",
      },
    ],
    "questions": [
      {
        "text": "What is the correct file extension for Python files?",
        "options": [".py", ".pyt", ".python", ".txt"],
        "correct_index": 0,
      },
    ],
  };

  await seedCourse(courseData, timeout: timeout);
}
