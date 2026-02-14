import 'seed_helper.dart';

Future<void> ensureDataScienceCourseExists({Duration? timeout}) async {
  await seedCourse({
    "title": "Data Science BootCamp",
    "description":
        "Unlock insights from data. Master Python, SQL, Statistics, Pandas, NumPy, and Data Visualization.",
    "category": "Data Science",
    "thumbnail": "https://i.ytimg.com/vi/ua-CiDNNj30/maxresdefault.jpg",
    "video_url": "https://youtu.be/ua-CiDNNj30",
    "lessons": [
      {
        "title": "1. Data Science Full Course",
        "video_url": "https://youtu.be/ua-CiDNNj30",
        "duration": "12:00:00",
      },
      {
        "title": "2. Python for Data Science",
        "video_url": "https://youtu.be/Nid7vFf9Ovg",
        "duration": "04:00:00",
      },
      {
        "title": "3. SQL Mastery for Data Analysis",
        "video_url": "https://youtu.be/7S_zh1DXMEE",
        "duration": "03:30:00",
      },
      {
        "title": "4. Pandas & NumPy Tutorial",
        "video_url": "https://youtu.be/vmEHCJofslg",
        "duration": "02:15:00",
      },
      {
        "title": "5. Statistics & Probability",
        "video_url": "https://youtu.be/Vvo_S7Svt6I",
        "duration": "01:45:00",
      },
      {
        "title": "6. Data Visualization with Matplotlib",
        "video_url": "https://youtu.be/q7Bo_J8x_dw",
        "duration": "01:20:00",
      },
    ],
    "questions": [
      {
        "text": "Which library is best for data manipulation in Python?",
        "options": ["Django", "Flask", "Pandas", "PyQt"],
        "correct_index": 2,
      },
      {
        "text": "What does SQL stand for?",
        "options": [
          "Structured Query Language",
          "Simple Quick Logic",
          "Systematic Query Link",
          "Standard Quality Line",
        ],
        "correct_index": 0,
      },
      {
        "text": "Which of these is a supervised learning algorithm?",
        "options": ["K-Means", "PCA", "Linear Regression", "Apriori"],
        "correct_index": 2,
      },
    ],
  }, timeout: timeout);
}
