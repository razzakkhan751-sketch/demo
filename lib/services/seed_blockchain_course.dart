import 'seed_helper.dart';

Future<void> ensureBlockchainCourseExists({Duration? timeout}) async {
  await seedCourse({
    "title": "Mastering Blockchain & Web3",
    "description":
        "The future of the internet. Learn Bitcoin, Ethereum, Solidity, Smart Contracts, and Decentralized Apps (dApps).",
    "category": "Blockchain",
    "thumbnail": "https://i.ytimg.com/vi/qcX6o70Xnpg/maxresdefault.jpg",
    "video_url": "https://youtu.be/qcX6o70Xnpg",
    "lessons": [
      {
        "title": "1. Blockchain Full Course",
        "video_url": "https://youtu.be/qcX6o70Xnpg",
        "duration": "08:00:00",
      },
      {
        "title": "2. Bitcoin Fundamentals",
        "video_url": "https://youtu.be/bBC-nXj3Ng4",
        "duration": "01:00:00",
      },
      {
        "title": "3. Ethereum & Smart Contracts",
        "video_url": "https://youtu.be/M576WGiDBdQ",
        "duration": "02:15:00",
      },
      {
        "title": "4. Solidity Programming Tutorial",
        "video_url": "https://youtu.be/M576WGiDBdQ",
        "duration": "05:30:00",
      },
      {
        "title": "5. Web3.js & dApp Development",
        "video_url": "https://youtu.be/m9pByRSTatE",
        "duration": "01:45:00",
      },
    ],
    "questions": [
      {
        "text": "Who created Bitcoin?",
        "options": [
          "Vitalik Buterin",
          "Satoshi Nakamoto",
          "Elon Musk",
          "Mark Zuckerberg",
        ],
        "correct_index": 1,
      },
      {
        "text": "What is a 'Smart Contract'?",
        "options": [
          "A legal document on paper",
          "Self-executing code on a blockchain",
          "A high-speed internet connection",
          "A type of crypto wallet",
        ],
        "correct_index": 1,
      },
      {
        "text":
            "Which language is primarily used for Ethereum smart contracts?",
        "options": ["Python", "Solidity", "Dart", "C++"],
        "correct_index": 1,
      },
    ],
  }, timeout: timeout);
}
