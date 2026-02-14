import 'seed_helper.dart';

Future<void> ensureSQLCourseExists({Duration? timeout}) async {
  final courseData = {
    "title": "Master SQL Database",
    "description":
        "Master the language of databases. Learn to design, query, and manage relational databases with SQL covering MySQL, PostgreSQL concepts.",
    "category": "SQL",
    "thumbnail": "https://i.ytimg.com/vi/HXV3zeQKqGY/maxresdefault.jpg",
    "video_url": "https://youtu.be/HXV3zeQKqGY",
    "lessons": [
      {
        "title": "1. SQL Full Course",
        "video_url": "https://youtu.be/HXV3zeQKqGY",
        "duration": "04:20:00",
      },
      {
        "title": "2. Creating Databases & Tables",
        "video_url": "https://youtu.be/5OdVJbNCSso",
        "duration": "15:10",
      },
      {
        "title": "3. INSERT Data",
        "video_url": "https://youtu.be/9PzpeJ9L2Iw",
        "duration": "12:45",
      },
      {
        "title": "4. SELECT & WHERE",
        "video_url": "https://youtu.be/W87p02N2hYg",
        "duration": "14:30",
      },
      {
        "title": "5. UPDATE & DELETE",
        "video_url": "https://youtu.be/m3WwQhQ7qGg",
        "duration": "11:15",
      },
      {
        "title": "6. Primary & Foreign Keys",
        "video_url": "https://youtu.be/t2rS5v9bT9c",
        "duration": "16:20",
      },
      {
        "title": "7. Joins (Inner, Left, Right)",
        "video_url": "https://youtu.be/9PzpeJ9L2Iw",
        "duration": "18:40",
      },
      {
        "title": "8. Aggregate Functions",
        "video_url": "https://youtu.be/V6gV5B_X_Xw",
        "duration": "13:50",
      },
      {
        "title": "9. Group By & Having",
        "video_url": "https://youtu.be/C38lG2F-4-4",
        "duration": "15:00",
      },
      {
        "title": "10. Stored Procedures",
        "video_url": "https://youtu.be/2H1s3HqB0yU",
        "duration": "20:00",
      },
    ],
    "questions": [
      {
        "text": "What does SQL stand for?",
        "options": [
          "Strong Question Language",
          "Structured Query Language",
          "Structured Question Language",
          "Simple Query Language",
        ],
        "correct_index": 1,
      },
      {
        "text": "Which SQL statement is used to extract data from a database?",
        "options": ["GET", "OPEN", "EXTRACT", "SELECT"],
        "correct_index": 3,
      },
      {
        "text": "Which SQL statement is used to update data in a database?",
        "options": ["SAVE", "MODIFY", "SAVE AS", "UPDATE"],
        "correct_index": 3,
      },
      {
        "text": "Which SQL statement is used to remove a table?",
        "options": [
          "DELETE TABLE",
          "Remove TABLE",
          "DROP TABLE",
          "CLEAR TABLE",
        ],
        "correct_index": 2,
      },
    ],
  };

  await seedCourse(courseData, timeout: timeout);
}
