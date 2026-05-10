
class ProfileModel{
  final String name;
  final String email;
  final String status;
  final int xp;
  final int topicsCompleted;
  ProfileModel({
    required this.name,
    required this.email,
    required this.status,
    required this.xp,
    required this.topicsCompleted,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: json['name'] as String,
      email: json['email'] as String,
      status: json['status'] as String,
      xp: json['xp'] as int,
      topicsCompleted: json['topicsCompleted'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'status': status,
      'xp': xp,
      'topicsCompleted': topicsCompleted,
    };
  }
  
}