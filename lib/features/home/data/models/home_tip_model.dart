import 'dart:convert';

import '../../domain/entities/home_tip.dart';

class HomeTipModel {
  final int id;
  final String sectionCode;
  final String title;
  final String body;
  final String iconKey;
  final String themeKey;

  const HomeTipModel({
    required this.id,
    required this.sectionCode,
    required this.title,
    required this.body,
    required this.iconKey,
    required this.themeKey,
  });

  factory HomeTipModel.fromJson(Map<String, dynamic> json) => HomeTipModel(
        id: (json['id'] as num).toInt(),
        sectionCode: json['sectionCode'] as String? ?? '',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        iconKey: json['iconKey'] as String? ?? 'savings',
        themeKey: json['themeKey'] as String? ?? 'green',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sectionCode': sectionCode,
        'title': title,
        'body': body,
        'iconKey': iconKey,
        'themeKey': themeKey,
      };

  String toJsonString() => jsonEncode(toJson());

  HomeTip toDomain() => HomeTip(
        id: id,
        sectionCode: sectionCode,
        title: title,
        body: body,
        iconKey: iconKey,
        theme: _parseTheme(themeKey),
      );

  static TipTheme _parseTheme(String key) => switch (key) {
        'amber' => TipTheme.amber,
        'blue' => TipTheme.blue,
        'indigo' => TipTheme.indigo,
        _ => TipTheme.green,
      };
}
