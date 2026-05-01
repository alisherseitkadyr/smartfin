import 'package:web/web.dart' as web;

const _prefix = 'smartfin.';

String? readFallback(String key) =>
    web.window.localStorage.getItem(_prefix + key);

void writeFallback(String key, String value) {
  web.window.localStorage.setItem(_prefix + key, value);
}

void deleteAllFallback() {
  final storage = web.window.localStorage;
  final keys = <String>[];

  for (var index = 0; index < storage.length; index++) {
    final key = storage.key(index);
    if (key != null && key.startsWith(_prefix)) keys.add(key);
  }

  for (final key in keys) {
    storage.removeItem(key);
  }
}
