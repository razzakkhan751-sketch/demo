import 'seed_helper.dart';

Future<void> ensureCppCourseExists({Duration? timeout}) async {
  final courseData = {
    "title": "Master C++ Programming",
    "description":
        "A complete 15-hour C++ course from beginner to advance. Covers object-oriented programming, STL, memory management, and more.",
    "category": "C++",
    "thumbnail": "https://i.ytimg.com/vi/-TkoO8Z07hI/maxresdefault.jpg",
    "video_url": "https://youtu.be/-TkoO8Z07hI",
    "lessons": [
      {
        "title": "1. C++ Introduction & Setup",
        "video_url": "https://youtu.be/8jLOx1hD3_o",
        "duration": "12:00",
      },
      {
        "title": "2. Variables & Data Types",
        "video_url": "https://youtu.be/1v_4dL8l8pQ",
        "duration": "15:45",
      },
      {
        "title": "3. User Input & Output",
        "video_url": "https://youtu.be/Jj9i01F4CgQ",
        "duration": "14:20",
      },
      {
        "title": "4. Arithmetic & Type Conversion",
        "video_url": "https://youtu.be/M_eX15_v00s",
        "duration": "11:50",
      },
      {
        "title": "5. If Statements & Switches",
        "video_url": "https://youtu.be/yl7o82dJ2dY",
        "duration": "16:30",
      },
      {
        "title": "6. Loops (For/While)",
        "video_url": "https://youtu.be/mF8yRzGjE5I",
        "duration": "13:40",
      },
      {
        "title": "7. Arrays & Vectors",
        "video_url": "https://youtu.be/1y4Y6t6p9cM",
        "duration": "18:10",
      },
      {
        "title": "8. Functions",
        "video_url": "https://youtu.be/ZtfN7zV9Z5k",
        "duration": "15:25",
      },
      {
        "title": "9. Pointers & References",
        "video_url": "https://youtu.be/rljS15e3h9c",
        "duration": "20:00",
      },
      {
        "title": "10. Object Oriented Programming (OOP)",
        "video_url": "https://youtu.be/wN0x9eZLix4",
        "duration": "25:35",
      },
    ],
    "questions": [
      {
        "text": "What does 'cout' stand for?",
        "options": [
          "Character Output",
          "Console Output",
          "Common Output",
          "Compile Output",
        ],
        "correct_index": 1,
      },
      {
        "text": "Which symbol is used for creating a pointer?",
        "options": ["&", "*", "->", "."],
        "correct_index": 1,
      },
      {
        "text": "What is the correct syntax to output 'Hello World' in C++?",
        "options": [
          "System.out.println('Hello World');",
          "print('Hello World');",
          "cout << \"Hello World\";",
          "Console.WriteLine('Hello World');",
        ],
        "correct_index": 2,
      },
      {
        "text": "Which library is needed for input and output?",
        "options": ["<iostream>", "<cmath>", "<string>", "<vector>"],
        "correct_index": 0,
      },
    ],
  };

  await seedCourse(courseData, timeout: timeout);
}
