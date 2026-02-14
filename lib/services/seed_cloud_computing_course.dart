import 'seed_helper.dart';

Future<void> ensureCloudComputingCourseExists({Duration? timeout}) async {
  await seedCourse({
    "title": "Cloud Computing Essentials",
    "description":
        "Master the cloud. Learn AWS, Azure, Google Cloud, Serverless, and Cloud Architecture.",
    "category": "Cloud Computing",
    "thumbnail": "https://i.ytimg.com/vi/M988_fsOSWo/maxresdefault.jpg",
    "video_url": "https://youtu.be/EN4fPBX2C_0",
    "lessons": [
      {
        "title": "1. Cloud Computing Full Course",
        "video_url": "https://youtu.be/EN4fPBX2C_0",
        "duration": "07:00:00",
      },
      {
        "title": "2. AWS Practitioner Essentials",
        "video_url": "https://youtu.be/Z3Sqz748XMI",
        "duration": "06:00:00",
      },
      {
        "title": "3. Microsoft Azure Fundamentals",
        "video_url": "https://youtu.be/NPEsD6n9A_I",
        "duration": "03:00:00",
      },
      {
        "title": "4. Google Cloud Platform (GCP)",
        "video_url": "https://youtu.be/jpno8YxI_f0",
        "duration": "01:45:00",
      },
      {
        "title": "5. Serverless Architecture",
        "video_url": "https://youtu.be/_j_f_4mPxhU",
        "duration": "00:50:00",
      },
    ],
    "questions": [
      {
        "text": "What does SaaS stand for?",
        "options": [
          "Software as a Service",
          "System as a Solution",
          "Security as a Shield",
          "Storage as a Source",
        ],
        "correct_index": 0,
      },
      {
        "text": "Which cloud provider is owned by Amazon?",
        "options": ["Azure", "GCP", "AWS", "Oracle"],
        "correct_index": 2,
      },
      {
        "text": "What is 'Autoscaling'?",
        "options": [
          "Adjusting screen size",
          "Dynamically adjusting resources based on load",
          "Automatically saving files",
          "Scanning for viruses",
        ],
        "correct_index": 1,
      },
    ],
  }, timeout: timeout);
}
