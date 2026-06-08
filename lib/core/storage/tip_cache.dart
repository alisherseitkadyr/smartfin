import 'dart:convert';

import 'package:hive/hive.dart';

/// Persists the last fetched tip across app restarts for offline support.
/// Always tries the network first; falls back to this cache when offline.
class TipCache {
  static const boxName = 'tip_cache';

  Box<dynamic> get _box => Hive.box<dynamic>(boxName);

  Map<String, dynamic>? getLast() {
    final raw = _box.get('tip') as String?;
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as Map).cast<String, dynamic>();
    } catch (_) {
      return null;
    }
  }

  Future<void> save(Map<String, dynamic> tipJson) async {
    await _box.put('tip', jsonEncode(tipJson));
  }

  Future<void> clear() async => _box.clear();
}
