import 'package:equatable/equatable.dart';

class UserProfile extends Equatable{
  final String name;
  final String email;
  final String status;
  final int xp;
  final int topicsCompleted;
  final String? assessedLevel;
  final Map<String, String>? preferences;
  final DateTime? lastAssessmentDate;

  UserProfile({
    required this.name,
    required this.email,
    required this.status,
    required this.xp,
    required this.topicsCompleted,
    this.assessedLevel,
    this.preferences,
    this.lastAssessmentDate,
  });

  @override
  List<Object?> get props => [
    name,
    email,
    status,
    xp,
    topicsCompleted,
    assessedLevel,
    preferences,
    lastAssessmentDate,
  ];
}