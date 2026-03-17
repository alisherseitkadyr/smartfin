import '../../domain/entities/lesson_topic.dart';

class LessonStepModel {
  final String id;
  final int order;
  final String title;
  final String body;
  final String example;
  final String tip;

  const LessonStepModel({
    required this.id,
    required this.order,
    required this.title,
    required this.body,
    required this.example,
    required this.tip,
  });

  factory LessonStepModel.fromJson(Map<String, dynamic> json) {
    return LessonStepModel(
      id: json['id'] as String,
      order: json['order'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      example: json['example'] as String,
      tip: json['tip'] as String,
    );
  }

  LessonStep toEntity() {
    return LessonStep(
      id: id, order: order, title: title,
      body: body, example: example, tip: tip,
    );
  }
}