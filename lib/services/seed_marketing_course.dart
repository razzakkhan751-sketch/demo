import 'seed_helper.dart';

Future<void> ensureMarketingCourseExists({Duration? timeout}) async {
  await seedCourse({
    "title": "Master Digital Marketing",
    "description":
        "Dominate the online space. Learn SEO, Social Media Marketing, Email Campaigns, Google Ads, and Content Strategy.",
    "category": "Marketing",
    "thumbnail": "https://i.ytimg.com/vi/bixR-KIJKcY/maxresdefault.jpg",
    "video_url": "https://youtu.be/bixR-KIJKcY",
    "lessons": [
      {
        "title": "1. Digital Marketing Full Course",
        "video_url": "https://youtu.be/bixR-KIJKcY",
        "duration": "12:00:00",
      },
      {
        "title": "2. SEO (Search Engine Optimization)",
        "video_url": "https://youtu.be/DvwS7cV9GmQ",
        "duration": "02:15:00",
      },
      {
        "title": "3. Social Media Marketing",
        "video_url": "https://youtu.be/h95cQkEwbx0",
        "duration": "01:45:00",
      },
      {
        "title": "4. Google Ads Tutorial",
        "video_url": "https://youtu.be/jJgdcPysRi0",
        "duration": "01:30:00",
      },
      {
        "title": "5. Facebook Ads & Instagram",
        "video_url": "https://youtu.be/1_M77c0vM5U",
        "duration": "02:20:00",
      },
      {
        "title": "6. Email Marketing",
        "video_url": "https://youtu.be/U0MvO8eS4yY",
        "duration": "01:10:00",
      },
      {
        "title": "7. Content Marketing Strategy",
        "video_url": "https://youtu.be/L5WfA98F7tI",
        "duration": "01:25:00",
      },
      {
        "title": "8. Copywriting Basics",
        "video_url": "https://youtu.be/6pYux6X9DUQ",
        "duration": "01:15:00",
      },
      {
        "title": "9. Affiliate Marketing",
        "video_url": "https://youtu.be/W87p02N2hYg",
        "duration": "00:50:00",
      },
      {
        "title": "10. Analytics & ROI",
        "video_url": "https://youtu.be/4bSr5qSM6uY",
        "duration": "01:40:00",
      },
    ],
    "questions": [
      {
        "text": "What does SEO stand for?",
        "options": [
          "Search Engine Organization",
          "Selective Entity Optimization",
          "Search Engine Optimization",
          "Social Engagement Online",
        ],
        "correct_index": 2,
      },
      {
        "text": "Which platform is best for B2B marketing?",
        "options": ["TikTok", "LinkedIn", "Snapchat", "Pinterest"],
        "correct_index": 1,
      },
      {
        "text": "What is 'CTR'?",
        "options": [
          "Click Through Rate",
          "Customer Total Returns",
          "Cost To Reach",
          "Content Type Ratio",
        ],
        "correct_index": 0,
      },
      {
        "text": "Which tool helps analyze website traffic?",
        "options": ["Photoshop", "Google Analytics", "Word", "Excel"],
        "correct_index": 1,
      },
    ],
  }, timeout: timeout);
}
