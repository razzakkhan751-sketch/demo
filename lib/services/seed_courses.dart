// ──────────────────────────────────────────────────────────
// SeedCourses — Non-blocking background seeder
// Checks if data exists before seeding. Never blocks UI.
// ──────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/course.dart';

class SeedCourses {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Call this from main.dart WITHOUT await — runs in background
  static void seedIfEmpty() {
    _doSeed().catchError((e) {
      debugPrint('Seeding skipped or failed (safe): $e');
    });
  }

  static Future<void> _doSeed() async {
    try {
      final snapshot = await _firestore.collection('courses').limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        debugPrint('Courses already exist — skipping seed.');
        return;
      }

      debugPrint('No courses found — seeding sample data...');
      final courses = _getSampleCourses();
      for (final course in courses) {
        await _firestore.collection('courses').add(course.toMap());
      }
      debugPrint('✅ Seeded ${courses.length} courses successfully.');
    } catch (e) {
      debugPrint('Seed error (non-blocking): $e');
    }
  }

  static List<Course> _getSampleCourses() {
    return [
      // ─── DART PROGRAMMING ───
      Course(
        title: 'Dart Programming Fundamentals',
        description:
            'Learn Dart from scratch — the language behind Flutter. Covers variables, functions, OOP, async, and more.',
        thumbnail: 'https://img.youtube.com/vi/Ej_Pcr4uC2Q/maxresdefault.jpg',
        videoUrl: 'https://www.youtube.com/watch?v=Ej_Pcr4uC2Q',
        category: 'Programming',
        level: 'Beginner',
        authorId: 'system',
        authorName: 'System',
        chapters: [
          Chapter(
            id: 'dart_ch1',
            title: 'Getting Started with Dart',
            order: 0,
            lectures: [
              Lecture(
                id: 'dart_ch1_l1',
                title: 'Introduction to Dart',
                videoUrl: 'https://www.youtube.com/watch?v=Ej_Pcr4uC2Q',
                duration: '12:00',
                content:
                    'Dart is a client-optimized language for fast apps on any platform. It is developed by Google and is used to build mobile, desktop, server, and web applications.\n\n**Key Features:**\n- Type safe\n- Null safety\n- Async-await support\n- Rich standard library',
                order: 0,
                questions: [
                  Question(
                    text: 'Who developed Dart?',
                    options: ['Apple', 'Google', 'Microsoft', 'Facebook'],
                    correctIndex: 1,
                  ),
                  Question(
                    text: 'Dart is used primarily for building:',
                    options: [
                      'Operating Systems',
                      'Flutter Apps',
                      'Hardware Drivers',
                      'None of these',
                    ],
                    correctIndex: 1,
                  ),
                ],
              ),
              Lecture(
                id: 'dart_ch1_l2',
                title: 'Variables & Data Types',
                videoUrl: 'https://www.youtube.com/watch?v=Ej_Pcr4uC2Q',
                duration: '15:00',
                content:
                    'Dart supports several built-in types:\n\n- `int` — Integer numbers\n- `double` — Floating point numbers\n- `String` — Text\n- `bool` — true/false\n- `List` — Ordered collections\n- `Map` — Key-value pairs\n\n```dart\nvar name = "Dart";\nint age = 10;\ndouble pi = 3.14;\nbool isAwesome = true;\n```',
                order: 1,
                questions: [
                  Question(
                    text: 'Which keyword declares a variable in Dart?',
                    options: ['let', 'var', 'dim', 'variable'],
                    correctIndex: 1,
                  ),
                ],
              ),
            ],
          ),
          Chapter(
            id: 'dart_ch2',
            title: 'Control Flow & Functions',
            order: 1,
            lectures: [
              Lecture(
                id: 'dart_ch2_l1',
                title: 'If-Else & Loops',
                videoUrl: 'https://www.youtube.com/watch?v=Ej_Pcr4uC2Q',
                duration: '18:00',
                content:
                    'Control flow in Dart includes:\n\n- `if / else if / else`\n- `for` loops\n- `while` and `do-while` loops\n- `switch-case` statements\n\n```dart\nfor (int i = 0; i < 5; i++) {\n  print(i);\n}\n```',
                order: 0,
                questions: [
                  Question(
                    text: 'Which loop checks condition before executing?',
                    options: ['do-while', 'while', 'for-each', 'repeat'],
                    correctIndex: 1,
                  ),
                ],
              ),
              Lecture(
                id: 'dart_ch2_l2',
                title: 'Functions & Closures',
                videoUrl: 'https://www.youtube.com/watch?v=Ej_Pcr4uC2Q',
                duration: '20:00',
                content:
                    'Functions in Dart can be:\n\n- Named functions\n- Anonymous functions (lambdas)\n- Arrow functions (=>)\n- Higher-order functions\n\n```dart\nint add(int a, int b) => a + b;\n\nvar multiply = (int x, int y) => x * y;\n```',
                order: 1,
              ),
            ],
          ),
          Chapter(
            id: 'dart_ch3',
            title: 'Object-Oriented Programming',
            order: 2,
            lectures: [
              Lecture(
                id: 'dart_ch3_l1',
                title: 'Classes & Objects',
                videoUrl: 'https://www.youtube.com/watch?v=Ej_Pcr4uC2Q',
                duration: '22:00',
                content:
                    'Dart is an object-oriented language with classes and mixin-based inheritance.\n\n```dart\nclass Animal {\n  String name;\n  Animal(this.name);\n  void speak() => print("\$name says hello!");\n}\n```',
                order: 0,
                questions: [
                  Question(
                    text: 'What keyword creates a class in Dart?',
                    options: ['struct', 'class', 'object', 'type'],
                    correctIndex: 1,
                  ),
                ],
              ),
              Lecture(
                id: 'dart_ch3_l2',
                title: 'Inheritance & Mixins',
                videoUrl: 'https://www.youtube.com/watch?v=Ej_Pcr4uC2Q',
                duration: '18:00',
                content:
                    'Dart supports single inheritance with `extends` and multiple behaviors with `mixin`.\n\n```dart\nclass Dog extends Animal {\n  Dog(String name) : super(name);\n}\n\nmixin Swimmer {\n  void swim() => print("Swimming!");\n}\n```',
                order: 1,
              ),
            ],
          ),
        ],
      ),

      // ─── PYTHON PROGRAMMING ───
      Course(
        title: 'Python for Beginners',
        description:
            'Complete Python course — from basics to advanced topics including data structures, file handling, and OOP.',
        thumbnail: 'https://img.youtube.com/vi/rfscVS0vtbw/maxresdefault.jpg',
        videoUrl: 'https://www.youtube.com/watch?v=rfscVS0vtbw',
        category: 'Programming',
        level: 'Beginner',
        authorId: 'system',
        authorName: 'System',
        chapters: [
          Chapter(
            id: 'py_ch1',
            title: 'Python Basics',
            order: 0,
            lectures: [
              Lecture(
                id: 'py_ch1_l1',
                title: 'Introduction to Python',
                videoUrl: 'https://www.youtube.com/watch?v=rfscVS0vtbw',
                duration: '10:00',
                content:
                    'Python is a high-level, interpreted programming language known for its simplicity.\n\n**Why Python?**\n- Easy to learn syntax\n- Massive community\n- Used in AI, Web Dev, Data Science\n- Cross-platform',
                order: 0,
                questions: [
                  Question(
                    text: 'Python is which type of language?',
                    options: ['Compiled', 'Interpreted', 'Assembly', 'Machine'],
                    correctIndex: 1,
                  ),
                ],
              ),
              Lecture(
                id: 'py_ch1_l2',
                title: 'Variables & Strings',
                videoUrl: 'https://www.youtube.com/watch?v=rfscVS0vtbw',
                duration: '14:00',
                content:
                    'Python variables don\'t need type declarations:\n\n```python\nname = "Python"\nage = 30\npi = 3.14\nis_fun = True\n```\n\nString operations:\n- Concatenation: `"Hello" + " World"`\n- f-strings: `f"Hello {name}"`\n- Slicing: `name[0:3]`',
                order: 1,
              ),
            ],
          ),
          Chapter(
            id: 'py_ch2',
            title: 'Data Structures',
            order: 1,
            lectures: [
              Lecture(
                id: 'py_ch2_l1',
                title: 'Lists & Tuples',
                videoUrl: 'https://www.youtube.com/watch?v=rfscVS0vtbw',
                duration: '16:00',
                content:
                    'Lists are mutable, tuples are immutable:\n\n```python\nfruits = ["apple", "banana", "cherry"]\ncoords = (10, 20)\n\nfruits.append("date")\nprint(fruits[0])  # apple\n```',
                order: 0,
                questions: [
                  Question(
                    text: 'Which Python data structure is immutable?',
                    options: ['List', 'Dictionary', 'Tuple', 'Set'],
                    correctIndex: 2,
                  ),
                ],
              ),
              Lecture(
                id: 'py_ch2_l2',
                title: 'Dictionaries & Sets',
                videoUrl: 'https://www.youtube.com/watch?v=rfscVS0vtbw',
                duration: '15:00',
                content:
                    'Dictionaries store key-value pairs:\n\n```python\nstudent = {"name": "Alice", "age": 20}\nprint(student["name"])  # Alice\n\nunique = {1, 2, 3, 3}  # {1, 2, 3}\n```',
                order: 1,
              ),
            ],
          ),
          Chapter(
            id: 'py_ch3',
            title: 'Functions & OOP',
            order: 2,
            lectures: [
              Lecture(
                id: 'py_ch3_l1',
                title: 'Functions in Python',
                videoUrl: 'https://www.youtube.com/watch?v=rfscVS0vtbw',
                duration: '18:00',
                content:
                    '```python\ndef greet(name):\n    return f"Hello, {name}!"\n\n# Lambda functions\nsquare = lambda x: x ** 2\n```',
                order: 0,
                questions: [
                  Question(
                    text: 'Which keyword defines a function in Python?',
                    options: ['function', 'func', 'def', 'fn'],
                    correctIndex: 2,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ─── JAVASCRIPT PROGRAMMING ───
      Course(
        title: 'JavaScript Essentials',
        description:
            'Master JavaScript fundamentals — DOM manipulation, ES6+, async/await, and modern web development.',
        thumbnail: 'https://img.youtube.com/vi/PkZNo7MFNFg/maxresdefault.jpg',
        videoUrl: 'https://www.youtube.com/watch?v=PkZNo7MFNFg',
        category: 'Programming',
        level: 'Beginner',
        authorId: 'system',
        authorName: 'System',
        chapters: [
          Chapter(
            id: 'js_ch1',
            title: 'JavaScript Basics',
            order: 0,
            lectures: [
              Lecture(
                id: 'js_ch1_l1',
                title: 'Introduction to JavaScript',
                videoUrl: 'https://www.youtube.com/watch?v=PkZNo7MFNFg',
                duration: '10:00',
                content:
                    'JavaScript is the language of the web. Every modern website uses it.\n\n**Key Facts:**\n- Runs in browsers and Node.js\n- Dynamic typing\n- Event-driven programming\n- Supports OOP and functional paradigms',
                order: 0,
                questions: [
                  Question(
                    text: 'Where does JavaScript run natively?',
                    options: [
                      'Operating System',
                      'Web Browser',
                      'Database',
                      'Compiler',
                    ],
                    correctIndex: 1,
                  ),
                ],
              ),
              Lecture(
                id: 'js_ch1_l2',
                title: 'Variables & Types',
                videoUrl: 'https://www.youtube.com/watch?v=PkZNo7MFNFg',
                duration: '12:00',
                content:
                    'ES6 introduced `let` and `const`:\n\n```javascript\nlet name = "JavaScript";\nconst PI = 3.14;\n\n// Types\ntypeof name   // "string"\ntypeof 42     // "number"\ntypeof true   // "boolean"\ntypeof null   // "object" (historical bug)\n```',
                order: 1,
              ),
            ],
          ),
          Chapter(
            id: 'js_ch2',
            title: 'Functions & ES6+',
            order: 1,
            lectures: [
              Lecture(
                id: 'js_ch2_l1',
                title: 'Arrow Functions & Destructuring',
                videoUrl: 'https://www.youtube.com/watch?v=PkZNo7MFNFg',
                duration: '16:00',
                content:
                    '```javascript\n// Arrow functions\nconst add = (a, b) => a + b;\n\n// Destructuring\nconst { name, age } = person;\nconst [first, ...rest] = array;\n\n// Template literals\nconst msg = `Hello \${name}!`;\n```',
                order: 0,
                questions: [
                  Question(
                    text: 'Arrow functions use which syntax?',
                    options: ['->', '=>', '::', '->'],
                    correctIndex: 1,
                  ),
                ],
              ),
              Lecture(
                id: 'js_ch2_l2',
                title: 'Promises & Async/Await',
                videoUrl: 'https://www.youtube.com/watch?v=PkZNo7MFNFg',
                duration: '20:00',
                content:
                    '```javascript\n// Promise\nfetch(url)\n  .then(response => response.json())\n  .then(data => console.log(data));\n\n// Async/Await\nasync function getData() {\n  const response = await fetch(url);\n  const data = await response.json();\n  return data;\n}\n```',
                order: 1,
                questions: [
                  Question(
                    text: 'Which keyword pauses async execution?',
                    options: ['pause', 'wait', 'await', 'yield'],
                    correctIndex: 2,
                  ),
                ],
              ),
            ],
          ),
          Chapter(
            id: 'js_ch3',
            title: 'DOM & Web APIs',
            order: 2,
            lectures: [
              Lecture(
                id: 'js_ch3_l1',
                title: 'DOM Manipulation',
                videoUrl: 'https://www.youtube.com/watch?v=PkZNo7MFNFg',
                duration: '18:00',
                content:
                    'The Document Object Model (DOM) lets JavaScript interact with HTML:\n\n```javascript\nconst element = document.getElementById("myId");\nelement.textContent = "Hello!";\nelement.style.color = "blue";\n\ndocument.querySelector(".btn")\n  .addEventListener("click", () => {\n    alert("Clicked!");\n  });\n```',
                order: 0,
              ),
            ],
          ),
        ],
      ),

      // ─── FLUTTER DEVELOPMENT ───
      Course(
        title: 'Flutter App Development',
        description:
            'Build beautiful cross-platform apps with Flutter. Covers widgets, state management, navigation, and Firebase.',
        thumbnail: 'https://img.youtube.com/vi/VPvVD8t02U8/maxresdefault.jpg',
        videoUrl: 'https://www.youtube.com/watch?v=VPvVD8t02U8',
        category: 'Mobile Development',
        level: 'Intermediate',
        authorId: 'system',
        authorName: 'System',
        chapters: [
          Chapter(
            id: 'fl_ch1',
            title: 'Flutter Fundamentals',
            order: 0,
            lectures: [
              Lecture(
                id: 'fl_ch1_l1',
                title: 'What is Flutter?',
                videoUrl: 'https://www.youtube.com/watch?v=VPvVD8t02U8',
                duration: '15:00',
                content:
                    'Flutter is Google\'s UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.\n\n**Key Features:**\n- Hot Reload\n- Expressive UI with widgets\n- Native performance\n- Single codebase for iOS, Android, Web, Desktop',
                order: 0,
                questions: [
                  Question(
                    text: 'Flutter uses which programming language?',
                    options: ['Java', 'Kotlin', 'Dart', 'Swift'],
                    correctIndex: 2,
                  ),
                ],
              ),
              Lecture(
                id: 'fl_ch1_l2',
                title: 'Widgets & Layout',
                videoUrl: 'https://www.youtube.com/watch?v=VPvVD8t02U8',
                duration: '20:00',
                content:
                    'Everything in Flutter is a widget:\n\n- `Container` — A box model widget\n- `Row` / `Column` — Horizontal/vertical layout\n- `Stack` — Overlapping widgets\n- `ListView` — Scrollable lists\n\n```dart\nColumn(\n  children: [\n    Text("Hello"),\n    ElevatedButton(\n      onPressed: () {},\n      child: Text("Click Me"),\n    ),\n  ],\n)\n```',
                order: 1,
              ),
            ],
          ),
          Chapter(
            id: 'fl_ch2',
            title: 'State Management',
            order: 1,
            lectures: [
              Lecture(
                id: 'fl_ch2_l1',
                title: 'setState & Provider',
                videoUrl: 'https://www.youtube.com/watch?v=VPvVD8t02U8',
                duration: '25:00',
                content:
                    'State management approaches in Flutter:\n\n1. **setState** — Simple local state\n2. **Provider** — Recommended for most apps\n3. **Riverpod** — More powerful Provider\n4. **BLoC** — Business Logic Component\n\n```dart\nclass Counter with ChangeNotifier {\n  int _count = 0;\n  int get count => _count;\n  void increment() {\n    _count++;\n    notifyListeners();\n  }\n}\n```',
                order: 0,
                questions: [
                  Question(
                    text:
                        'Which is the recommended state management for Flutter?',
                    options: ['Redux', 'MobX', 'Provider', 'Vuex'],
                    correctIndex: 2,
                  ),
                ],
              ),
            ],
          ),
          Chapter(
            id: 'fl_ch3',
            title: 'Firebase Integration',
            order: 2,
            lectures: [
              Lecture(
                id: 'fl_ch3_l1',
                title: 'Firebase Setup & Auth',
                videoUrl: 'https://www.youtube.com/watch?v=VPvVD8t02U8',
                duration: '22:00',
                content:
                    'Firebase provides backend services:\n\n- **Authentication** — Email, Google, Phone\n- **Cloud Firestore** — NoSQL database\n- **Firebase Storage** — File uploads\n- **Cloud Functions** — Server-side logic\n\nSetup:\n1. Create Firebase project\n2. Add `firebase_core` to pubspec.yaml\n3. Run `flutterfire configure`',
                order: 0,
              ),
            ],
          ),
        ],
      ),

      // ─── HTML & CSS ───
      Course(
        title: 'HTML & CSS Crash Course',
        description:
            'Learn web development fundamentals — HTML structure, CSS styling, responsive design, and modern layouts.',
        thumbnail: 'https://img.youtube.com/vi/mU6anWqZJcc/maxresdefault.jpg',
        videoUrl: 'https://www.youtube.com/watch?v=mU6anWqZJcc',
        category: 'Web Development',
        level: 'Beginner',
        authorId: 'system',
        authorName: 'System',
        chapters: [
          Chapter(
            id: 'html_ch1',
            title: 'HTML Foundations',
            order: 0,
            lectures: [
              Lecture(
                id: 'html_ch1_l1',
                title: 'HTML Structure & Tags',
                videoUrl: 'https://www.youtube.com/watch?v=mU6anWqZJcc',
                duration: '15:00',
                content:
                    'HTML is the skeleton of every webpage:\n\n```html\n<!DOCTYPE html>\n<html>\n<head>\n  <title>My Page</title>\n</head>\n<body>\n  <h1>Hello World</h1>\n  <p>This is a paragraph.</p>\n</body>\n</html>\n```\n\nCommon tags: `<div>`, `<span>`, `<a>`, `<img>`, `<ul>`, `<ol>`',
                order: 0,
                questions: [
                  Question(
                    text: 'What does HTML stand for?',
                    options: [
                      'Hyper Text Markup Language',
                      'High Tech Modern Language',
                      'Hyper Transfer Markup Language',
                      'Home Tool Markup Language',
                    ],
                    correctIndex: 0,
                  ),
                ],
              ),
            ],
          ),
          Chapter(
            id: 'html_ch2',
            title: 'CSS Styling',
            order: 1,
            lectures: [
              Lecture(
                id: 'html_ch2_l1',
                title: 'Selectors & Properties',
                videoUrl: 'https://www.youtube.com/watch?v=mU6anWqZJcc',
                duration: '18:00',
                content:
                    'CSS styles HTML elements:\n\n```css\nbody {\n  font-family: Arial, sans-serif;\n  background: #f0f0f0;\n}\n\n.container {\n  max-width: 1200px;\n  margin: 0 auto;\n  padding: 20px;\n}\n```\n\nSelectors: element, .class, #id, [attribute]',
                order: 0,
              ),
              Lecture(
                id: 'html_ch2_l2',
                title: 'Flexbox & Grid',
                videoUrl: 'https://www.youtube.com/watch?v=mU6anWqZJcc',
                duration: '20:00',
                content:
                    'Modern layouts use Flexbox and Grid:\n\n```css\n.flex-container {\n  display: flex;\n  justify-content: center;\n  align-items: center;\n  gap: 16px;\n}\n\n.grid-container {\n  display: grid;\n  grid-template-columns: repeat(3, 1fr);\n  gap: 20px;\n}\n```',
                order: 1,
                questions: [
                  Question(
                    text: 'Which CSS property creates a flex container?',
                    options: [
                      'position: flex',
                      'display: flex',
                      'layout: flex',
                      'flex: true',
                    ],
                    correctIndex: 1,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ];
  }
}
