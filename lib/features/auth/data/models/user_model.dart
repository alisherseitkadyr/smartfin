import '../../domain/entities/user.dart';

class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      email: json['email'] as String,
      name: (json['name'] ?? json['username']) as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  User toEntity() =>
      User(id: id, email: email, name: name, avatarUrl: avatarUrl);
}
