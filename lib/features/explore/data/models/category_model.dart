import '../../domain/entities/category.dart';

class CategoryModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String color;
  final List<String> topicIds;

  const CategoryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.topicIds,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      topicIds: List<String>.from(json['topic_ids'] as List),
    );
  }

  Category toEntity() {
    return Category(
      id: id,
      title: title,
      description: description,
      icon: icon,
      color: _parseColor(color),
      topicIds: topicIds,
    );
  }

  CategoryColor _parseColor(String raw) {
    switch (raw) {
      case 'blue':  return CategoryColor.blue;
      case 'navy':  return CategoryColor.navy;
      default:      return CategoryColor.green;
    }
  }
}