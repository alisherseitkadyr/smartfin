import 'dart:async';
import 'dart:convert';

import 'package:hive/hive.dart';

/// Persists the /content/explore curriculum skeleton across app restarts.
/// Keys are language-scoped so a language switch forces a fresh fetch.
/// Layout per language code (e.g. "en"):
///   data_en  — JSON-encoded List of raw section maps
///   ts_en    — int millisecondsSinceEpoch of last successful fetch
class CurriculumCache {
  static const boxName = 'curriculum_cache';
  static const ttl = Duration(hours: 24);

  Box<dynamic> get _box => Hive.box<dynamic>(boxName);

  /// Returns the cached sections JSON for [lang] if the entry is still within
  /// TTL, null otherwise.
  List<Map<String, dynamic>>? getIfFresh(String lang) {
    final ts = _box.get('ts_$lang') as int?;
    if (ts == null) return null;
    final age = DateTime.now().millisecondsSinceEpoch - ts;
    if (age >= ttl.inMilliseconds) return null;
    final encoded = _box.get('data_$lang') as String?;
    if (encoded == null) return null;
    try {
      final raw = jsonDecode(encoded) as List;
      return raw.cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  /// Persists [sections] raw JSON for [lang] with the current timestamp.
  Future<void> save(String lang, List<Map<String, dynamic>> sections) async {
    await Future.wait([
      _box.put('data_$lang', jsonEncode(sections)),
      _box.put('ts_$lang', DateTime.now().millisecondsSinceEpoch),
    ]);
  }

  Future<void> clear() async => _box.clear();
}
