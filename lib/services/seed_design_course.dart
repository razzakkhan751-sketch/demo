import 'seed_helper.dart';

Future<void> ensureDesignCourseExists({Duration? timeout}) async {
  await seedCourse({
    "title": "Mastering UI/UX Design",
    "description":
        "Create stunning user interfaces and great user experiences. Learn Figma, Adobe XD, Design Systems, and Prototyping.",
    "category": "Design",
    "thumbnail": "https://i.ytimg.com/vi/c9Wg6ndoxag/maxresdefault.jpg",
    "video_url": "https://youtu.be/c9Wg6ndoxag",
    "lessons": [
      {
        "title": "1. UI/UX Design Full Course",
        "video_url": "https://youtu.be/c9Wg6ndoxag",
        "duration": "08:30:00",
      },
      {
        "title": "2. Figma Tutorial for Beginners",
        "video_url": "https://youtu.be/FTFaQW99g64",
        "duration": "01:20:00",
      },
      {
        "title": "3. User Research Methods",
        "video_url": "https://youtu.be/vWJ2t7v9j1k",
        "duration": "00:45:00",
      },
      {
        "title": "4. Wireframing & Prototyping",
        "video_url": "https://youtu.be/X6Xn3p9HRE4",
        "duration": "01:10:00",
      },
      {
        "title": "5. Color Theory & Typography",
        "video_url": "https://youtu.be/395XWl4L8E8",
        "duration": "00:55:00",
      },
    ],
    "questions": [
      {
        "text": "What does UI stand for?",
        "options": [
          "User Interaction",
          "User Interface",
          "Unified Integration",
          "Unique Identity",
        ],
        "correct_index": 1,
      },
      {
        "text": "Which tool is most popular for collaborative UI design?",
        "options": ["Photoshop", "Figma", "Illustrator", "Flash"],
        "correct_index": 1,
      },
      {
        "text": "What is a 'Wireframe'?",
        "options": [
          "A colorful high-fidelity mockup",
          "A low-fidelity structural blueprint",
          "A finished website",
          "A 3D model",
        ],
        "correct_index": 1,
      },
    ],
  }, timeout: timeout);
}
