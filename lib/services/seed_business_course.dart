import 'seed_helper.dart';

Future<void> ensureBusinessCourseExists({Duration? timeout}) async {
  await seedCourse({
    "title": "Entrepreneurship & Business",
    "description":
        "Build and scale your own business. Learn Business Models, Scaling, Fundraising, and Sales Strategies.",
    "category": "Business",
    "thumbnail": "https://i.ytimg.com/vi/lJjILQu2xM8/maxresdefault.jpg",
    "video_url": "https://youtu.be/lJjILQu2xM8",
    "lessons": [
      {
        "title": "1. Business Management Full Course",
        "video_url": "https://youtu.be/lJjILQu2xM8",
        "duration": "09:15:00",
      },
      {
        "title": "2. How to Start a Startup",
        "video_url": "https://youtu.be/CBYhVcOnBwg",
        "duration": "01:00:00",
      },
      {
        "title": "3. Business Networking & Sales",
        "video_url": "https://youtu.be/G2S9vH7z08w",
        "duration": "00:45:00",
      },
      {
        "title": "4. Fundraising & VC Basics",
        "video_url": "https://youtu.be/7U9mY_c7EBY",
        "duration": "00:55:00",
      },
      {
        "title": "5. Scaling Your Business",
        "video_url": "https://youtu.be/E_Wp5Y7E9gA",
        "duration": "01:20:00",
      },
    ],
    "questions": [
      {
        "text": "What is an 'MVP'?",
        "options": [
          "Most Valuable Player",
          "Minimum Viable Product",
          "Maximum Value Profit",
          "Master Variable Plan",
        ],
        "correct_index": 1,
      },
      {
        "text": "What is 'Equity'?",
        "options": [
          "Debt taken from a bank",
          "Ownership in a company",
          "Employee salary",
          "Office rent",
        ],
        "correct_index": 1,
      },
      {
        "text": "What does ROI stand for?",
        "options": [
          "Return on Investment",
          "Rate of Interest",
          "Reduction of Items",
          "Revenue of Income",
        ],
        "correct_index": 0,
      },
    ],
  }, timeout: timeout);
}
