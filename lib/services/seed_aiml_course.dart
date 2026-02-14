import 'seed_helper.dart';

Future<void> ensureAIMLCourseExists({Duration? timeout}) async {
  await seedCourse({
    "title": "AI & Machine Learning Mastery",
    "description":
        "Build the future with AI. Learn Neural Networks, Deep Learning, TensorFlow, PyTorch, and NLP.",
    "category": "AI & ML",
    "thumbnail": "https://i.ytimg.com/vi/JMUxmLtx-QU/maxresdefault.jpg",
    "video_url": "https://youtu.be/JMUxmLtx-QU",
    "lessons": [
      {
        "title": "1. AI & Machine Learning Full Course",
        "video_url": "https://youtu.be/JMUxmLtx-QU",
        "duration": "11:00:00",
      },
      {
        "title": "2. Neural Networks from Scratch",
        "video_url": "https://youtu.be/aircAruvnKk",
        "duration": "03:00:00",
      },
      {
        "title": "3. TensorFlow & Keras Tutorial",
        "video_url": "https://youtu.be/tPYj3fFJGjk",
        "duration": "02:30:00",
      },
      {
        "title": "4. Deep Learning with PyTorch",
        "video_url": "https://youtu.be/V_xro1bcAuA",
        "duration": "03:15:00",
      },
      {
        "title": "5. Natural Language Processing (NLP)",
        "video_url": "https://youtu.be/CMrHM8a3hqw",
        "duration": "01:20:00",
      },
    ],
    "questions": [
      {
        "text": "What does AI stand for?",
        "options": [
          "Authentic Intelligence",
          "Artificial Intelligence",
          "Automated Information",
          "Advanced Integration",
        ],
        "correct_index": 1,
      },
      {
        "text": "Which of these is a popular Deep Learning framework?",
        "options": ["React", "TensorFlow", "Django", "Angular"],
        "correct_index": 1,
      },
      {
        "text": "What is 'Overfitting'?",
        "options": [
          "A model that is too small",
          "A model that performs well on training but poor on test data",
          "A type of graphics card",
          "A data cleaning method",
        ],
        "correct_index": 1,
      },
    ],
  }, timeout: timeout);
}
