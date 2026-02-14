class Note {
  final String id;
  final String title;
  final String content;
  final String category;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final String? pdfUrl;
  final String? fileName;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    this.pdfUrl,
    this.fileName,
  });

  factory Note.fromMap(Map<String, dynamic> data, String documentId) {
    return Note(
      id: documentId,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      category: data['category'] ?? 'General',
      authorId: (data['author_id'] ?? data['authorId'] ?? '').toString(),
      authorName: (data['author_name'] ?? data['authorName'] ?? 'Unknown')
          .toString(),
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : (data['createdAt'] is DateTime
                ? data['createdAt']
                : DateTime.now()),
      pdfUrl: data['pdf_url'] ?? data['pdfUrl'],
      fileName: data['file_name'] ?? data['fileName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'author_id': authorId,
      'author_name': authorName,
      'created_at': createdAt.toIso8601String(),
      'pdf_url': pdfUrl,
      'file_name': fileName,
    };
  }
}
