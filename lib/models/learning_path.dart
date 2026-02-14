class LearningPath {
  final String id;
  final String title;
  final String description;
  final String thumbnail;
  final List<String> courseIds; // Ordered list of course IDs
  final String difficulty; // Beginner, Intermediate, Advanced

  LearningPath({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.courseIds,
    required this.difficulty,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
      'course_ids': courseIds,
      'difficulty': difficulty,
    };
  }

  factory LearningPath.fromMap(Map<String, dynamic> map, String id) {
    return LearningPath(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      thumbnail: map['thumbnail'] ?? '',
      courseIds: List<String>.from(map['course_ids'] ?? map['courseIds'] ?? []),
      difficulty: map['difficulty'] ?? map['level'] ?? 'Beginner',
    );
  }
}
