import 'seed_helper.dart';

Future<void> ensureDevOpsCourseExists({Duration? timeout}) async {
  await seedCourse({
    "title": "DevOps Engineering Mastery",
    "description":
        "Learn to automate, scale, and secure your infrastructure. Covers Docker, Kubernetes, Jenkins, Terraform, and AWS.",
    "category": "DevOps",
    "thumbnail": "https://i.ytimg.com/vi/hQcFE0nvGuU/maxresdefault.jpg",
    "video_url": "https://youtu.be/hQcFE0nvGuU",
    "lessons": [
      {
        "title": "1. DevOps Full Course for Beginners",
        "video_url": "https://youtu.be/hQcFE0nvGuU",
        "duration": "10:00:00",
      },
      {
        "title": "2. Docker & Containers",
        "video_url": "https://youtu.be/3c-iBn7E8DE",
        "duration": "03:00:00",
      },
      {
        "title": "3. Kubernetes Fundamentals",
        "video_url": "https://youtu.be/X48VuDVv0do",
        "duration": "04:30:00",
      },
      {
        "title": "4. Jenkins CI/CD Pipeline",
        "video_url": "https://youtu.be/LFDrxDBCUms",
        "duration": "02:15:00",
      },
      {
        "title": "5. Terraform (IaC)",
        "video_url": "https://youtu.be/Vz_mNOn6wDM",
        "duration": "02:45:00",
      },
      {
        "title": "6. AWS for DevOps Engineers",
        "video_url": "https://youtu.be/Z3Sqz748XMI",
        "duration": "05:00:00",
      },
      {
        "title": "7. Ansible Configuration Management",
        "video_url": "https://youtu.be/EcnqJlp7nm0",
        "duration": "02:00:00",
      },
      {
        "title": "8. Prometheus & Grafana Monitoring",
        "video_url": "https://youtu.be/h43lS1H6IG8",
        "duration": "01:50:00",
      },
    ],
    "questions": [
      {
        "text": "What does CI/CD stand for?",
        "options": [
          "Continuous Integration / Continuous Delivery",
          "Code Inspection / Code Deployment",
          "Computer Integration / Cloud Delivery",
          "Config Initializer / Card Deployment",
        ],
        "correct_index": 0,
      },
      {
        "text": "Which tool is primarily used for container orchestration?",
        "options": ["Jenkins", "Docker", "Kubernetes", "Ansible"],
        "correct_index": 2,
      },
      {
        "text": "What is Terraform used for?",
        "options": [
          "Containerization",
          "Infrastructure as Code",
          "Version Control",
          "Monitoring",
        ],
        "correct_index": 1,
      },
    ],
  }, timeout: timeout);
}
