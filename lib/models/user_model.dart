class UserModel {
  final String uid;
  final String email;
  final String name;
  final String photoUrl;
  final String role; // 'student', 'teacher', 'admin'
  final bool isBanned;

  UserModel({
    required this.uid,
    required this.email,
    this.name = '',
    this.photoUrl = '',
    this.role = 'pending',
    this.isBanned = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      photoUrl: data['photo_url'] ?? data['photoUrl'] ?? '',
      role: data['role'] ?? 'pending',
      isBanned: data['is_banned'] ?? data['isBanned'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': uid,
      'email': email,
      'name': name,
      'photo_url': photoUrl,
      'role': role,
      'is_banned': isBanned,
    };
  }
}
