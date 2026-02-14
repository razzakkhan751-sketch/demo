import 'seed_helper.dart';

Future<void> ensureCyberSecurityCourseExists({Duration? timeout}) async {
  await seedCourse({
    "title": "Cybersecurity Fundamentals",
    "description":
        "Protect systems and networks. Learn Network Security, Ethical Hacking, Cryptography, and Security Operations.",
    "category": "Cyber Security",
    "thumbnail": "https://i.ytimg.com/vi/bXmXpPToE_8/maxresdefault.jpg",
    "video_url": "https://youtu.be/bXmXpPToE_8",
    "lessons": [
      {
        "title": "1. Cybersecurity Full Course",
        "video_url": "https://youtu.be/bXmXpPToE_8",
        "duration": "09:00:00",
      },
      {
        "title": "2. Network Security Basics",
        "video_url": "https://youtu.be/jQDjJm6p-A0",
        "duration": "01:30:00",
      },
      {
        "title": "3. Ethical Hacking Tutorial",
        "video_url": "https://youtu.be/3Kq1MIfTWCE",
        "duration": "02:45:00",
      },
      {
        "title": "4. Cryptography 101",
        "video_url": "https://youtu.be/S9JGmA5_unY",
        "duration": "01:15:00",
      },
      {
        "title": "5. SOC Operations & Incident Response",
        "video_url": "https://youtu.be/nL_6-c-L9B0",
        "duration": "02:00:00",
      },
    ],
    "questions": [
      {
        "text": "What is 'Phishing'?",
        "options": [
          "A type of network router",
          "A method of gathering info via deception",
          "A data encryption algorithm",
          "A cloud storage service",
        ],
        "correct_index": 1,
      },
      {
        "text": "What does VPN stand for?",
        "options": [
          "Virtual Private Network",
          "Verified Public Node",
          "Visual Protocol Network",
          "Variable Port Number",
        ],
        "correct_index": 0,
      },
      {
        "text": "Which of these is used for network packet analysis?",
        "options": ["Wireshark", "Photoshop", "Word", "Excel"],
        "correct_index": 0,
      },
    ],
  }, timeout: timeout);
}
