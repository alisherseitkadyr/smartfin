final Map<String, String> _fallback = <String, String>{};

String? readFallback(String key) => _fallback[key];

void writeFallback(String key, String value) {
  _fallback[key] = value;
}

void deleteAllFallback() {
  _fallback.clear();
}
