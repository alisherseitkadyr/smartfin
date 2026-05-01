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
    final body = _contentToText(json['content']);
    final interactiveText = _interactiveContentToText(
      json['interactiveContent'],
    );

    return LessonStepModel(
      id: json['id'].toString(),
      order: _toInt(json['order'] ?? json['orderIndex']),
      title:
          (json['title'] as String?) ??
          _titleForStepType(json['stepType'] as String?),
      body: (json['body'] as String?) ?? body,
      example: json['example'] as String? ?? '',
      tip: json['tip'] as String? ?? interactiveText,
    );
  }

  LessonStep toEntity() {
    return LessonStep(
      id: id,
      order: order,
      title: title,
      body: body,
      example: example,
      tip: tip,
    );
  }

  static String _contentToText(Object? content) {
    if (content is String) return content;
    if (content is List) return _blocksToText(content);
    if (content is Map<String, dynamic>) {
      final blocks = content['blocks'];
      if (blocks is List) return _blocksToText(blocks);
      final text = content['text'];
      if (text is String) return text;
    }
    return '';
  }

  static String _blocksToText(List<dynamic> blocks) {
    final parts = <String>[];

    for (final block in blocks) {
      if (block is! Map<String, dynamic>) continue;

      final type = block['type'];
      switch (type) {
        case 'bullet_list':
          parts.add(_listItemsToText(block['items']));
          break;
        case 'table':
          parts.add(_tableToText(block));
          break;
        default:
          final text = block['text'];
          if (text is String && text.trim().isNotEmpty) {
            parts.add(text.trim());
          }
      }
    }

    return parts.where((part) => part.isNotEmpty).join('\n\n');
  }

  static String _listItemsToText(Object? items) {
    if (items is! List) return '';
    return items
        .map((item) {
          if (item is String) return '• $item';
          if (item is Map<String, dynamic>) {
            final text = item['text'];
            if (text is String) return '• $text';
          }
          return '';
        })
        .where((line) => line.isNotEmpty)
        .join('\n');
  }

  static String _tableToText(Map<String, dynamic> table) {
    final rows = table['rows'];
    if (rows is! List) return '';
    return rows
        .map((row) {
          if (row is List) {
            return row.map((cell) => cell.toString()).join(' | ');
          }
          if (row is Map<String, dynamic>) {
            return row.values.map((cell) => cell.toString()).join(' | ');
          }
          return '';
        })
        .where((line) => line.isNotEmpty)
        .join('\n');
  }

  static String _interactiveContentToText(Object? content) {
    if (content is! Map<String, dynamic>) return '';
    final parts = <String>[];

    for (final key in ['instruction', 'question', 'explanation']) {
      final value = content[key];
      if (value is String && value.trim().isNotEmpty) {
        parts.add(value.trim());
      }
    }

    return parts.join('\n\n');
  }

  static String _titleForStepType(String? stepType) {
    switch (stepType) {
      case 'introduction':
        return 'Introduction';
      case 'explanation':
        return 'Explanation';
      case 'example':
        return 'Example';
      case 'interactive':
        return 'Try it';
      case 'conclusion':
        return 'Summary';
      default:
        return 'Lesson step';
    }
  }

  static int _toInt(Object? value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
