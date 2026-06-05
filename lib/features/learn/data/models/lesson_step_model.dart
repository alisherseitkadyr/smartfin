import '../../domain/entities/lesson_topic.dart';

class LessonStepModel {
  final String id;
  final int order;
  final String stepType;
  final String title;
  final String body;
  final String example;
  final String tip;
  final String? interactiveType;
  final Map<String, dynamic>? interactiveContent;
  final List<List<List<String>>>? tables;

  const LessonStepModel({
    required this.id,
    required this.order,
    required this.stepType,
    required this.title,
    required this.body,
    required this.example,
    required this.tip,
    this.interactiveType,
    this.interactiveContent,
    this.tables,
  });

  factory LessonStepModel.fromJson(Map<String, dynamic> json) {
    final stepType = json['stepType'] as String? ?? '';
    final content = _asStringMap(json['content']);
    final interactiveContent =
        _asStringMap(json['interactiveContent']) ??
        _interactiveContentFromContent(stepType, content);
    final body = _contentToText(json['content']);
    final tables = _extractTables(json['content']);
    final interactiveText = interactiveContent == null
        ? _interactiveContentToText(json['interactiveContent'])
        : '';

    return LessonStepModel(
      id: json['id'].toString(),
      order: _toInt(json['order'] ?? json['orderIndex']),
      stepType: stepType,
      title: (json['title'] as String?) ?? _titleForStepType(stepType),
      body: (json['body'] as String?) ?? body,
      example: json['example'] as String? ?? '',
      tip: json['tip'] as String? ?? interactiveText,
      interactiveType: json['interactiveType'] as String?,
      interactiveContent: interactiveContent,
      tables: tables.isNotEmpty ? tables : null,
    );
  }

  LessonStep toEntity() {
    return LessonStep(
      id: id,
      order: order,
      stepType: stepType,
      title: title,
      body: body,
      example: example,
      tip: tip,
      interactiveType: interactiveType,
      interactiveContent: interactiveContent,
      tables: tables,
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
          // Tables are extracted separately and rendered as widgets; skip here.
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

  /// Returns structured table data extracted from block content.
  /// Each table is a list of rows; each row is a list of cell strings.
  static List<List<List<String>>> _extractTables(Object? content) {
    final tables = <List<List<String>>>[];
    List<dynamic>? blocks;

    if (content is List) {
      blocks = content;
    } else if (content is Map<String, dynamic>) {
      final b = content['blocks'];
      if (b is List) blocks = b;
    }

    if (blocks == null) return tables;

    for (final block in blocks) {
      if (block is! Map<String, dynamic>) continue;
      if (block['type'] != 'table') continue;

      final rows = block['rows'];
      if (rows is! List) continue;

      final parsedRows = <List<String>>[];
      for (final row in rows) {
        if (row is List) {
          parsedRows.add(row.map((cell) => cell.toString()).toList());
        } else if (row is Map<String, dynamic>) {
          parsedRows.add(row.values.map((cell) => cell.toString()).toList());
        }
      }
      if (parsedRows.isNotEmpty) tables.add(parsedRows);
    }

    return tables;
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

  static String _interactiveContentToText(Object? content) {
    final map = _asStringMap(content);
    if (map == null) return '';
    final parts = <String>[];

    for (final key in ['instruction', 'question', 'explanation']) {
      final value = map[key];
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

  static Map<String, dynamic>? _interactiveContentFromContent(
    String stepType,
    Map<String, dynamic>? content,
  ) {
    if (content == null || stepType != 'interactive') return null;
    if (content['blocks'] != null) return null;

    final hasInteractiveShape = [
      'instruction',
      'fields',
      'inputs',
      'categories',
      'scenarios',
      'options',
      'cases',
      'type',
    ].any(content.containsKey);

    return hasInteractiveShape ? content : null;
  }

  static Map<String, dynamic>? _asStringMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }
}
