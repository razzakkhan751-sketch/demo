import 'seed_helper.dart';

Future<void> ensurePHPCourseExists({Duration? timeout}) async {
  final courseData = {
    "title": "Master PHP Programming",
    "description":
        "Learn PHP from scratch. The backend language that powers 80% of the web. Covers syntax, databases (MySQL), and modern practices.",
    "category": "PHP",
    "thumbnail": "https://i.ytimg.com/vi/OK_JCtrrv-c/maxresdefault.jpg",
    "video_url": "https://youtu.be/OK_JCtrrv-c",
    "lessons": [
      {
        "title": "1. PHP Full Course for Beginners",
        "video_url": "https://youtu.be/OK_JCtrrv-c",
        "duration": "04:30:00",
      },
      {
        "title": "2. Variables & Scopes",
        "video_url": "https://youtu.be/OK_JCtrrv-c",
        "duration": "10:15",
      },
      {
        "title": "3. Arrays & Superglobals",
        "video_url": "https://youtu.be/OK_JCtrrv-c",
        "duration": "14:40",
      },
      {
        "title": "4. Forms & Get/Post",
        "video_url": "https://youtu.be/OK_JCtrrv-c",
        "duration": "16:20",
      },
      {
        "title": "5. Loops (Foreach)",
        "video_url": "https://youtu.be/OK_JCtrrv-c",
        "duration": "11:55",
      },
      {
        "title": "6. Functions",
        "video_url": "https://youtu.be/OK_JCtrrv-c",
        "duration": "13:30",
      },
      {
        "title": "7. Include & Require",
        "video_url": "https://youtu.be/OK_JCtrrv-c",
        "duration": "09:40",
      },
      {
        "title": "8. Sessions & Cookies",
        "video_url": "https://youtu.be/OK_JCtrrv-c",
        "duration": "18:10",
      },
      {
        "title": "9. File Handling",
        "video_url": "https://youtu.be/OK_JCtrrv-c",
        "duration": "15:25",
      },
      {
        "title": "10. OOP in PHP",
        "video_url": "https://youtu.be/OK_JCtrrv-c",
        "duration": "20:00",
      },
    ],
    "questions": [
      {
        "text": "What does PHP stand for?",
        "options": [
          "Personal Home Page",
          "PHP: Hypertext Preprocessor",
          "Private Home Page",
          "Public Hypertext Preprocessor",
        ],
        "correct_index": 1,
      },
      {
        "text": "Which symbol starts every PHP variable?",
        "options": ["!", "@", r"$", "&"],
        "correct_index": 2,
      },
      {
        "text": "Which function is used to output text in PHP?",
        "options": ["print_r", "echo", "write", "display"],
        "correct_index": 1,
      },
      {
        "text": "How do you end a PHP statement?",
        "options": [".", "!", ";", ":"],
        "correct_index": 2,
      },
    ],
  };

  await seedCourse(courseData, timeout: timeout);
}
