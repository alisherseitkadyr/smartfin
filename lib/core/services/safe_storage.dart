import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'storage_fallback_stub.dart'
    if (dart.library.html) 'storage_fallback_web.dart'
    as fallback;

class SafeStorage {
  final FlutterSecureStorage _secureStorage;

  static final Set<String> _reportedOperations = <String>{};

  const SafeStorage({
    FlutterSecureStorage secureStorage = const FlutterSecureStorage(),
  }) : _secureStorage = secureStorage;

  Future<String?> read({required String key}) async {
    try {
      final value = await _secureStorage.read(key: key);
      if (value != null) fallback.writeFallback(key, value);
      return value ?? fallback.readFallback(key);
    } catch (error) {
      _report('read', error);
      return fallback.readFallback(key);
    }
  }

  Future<void> write({required String key, required String value}) async {
    fallback.writeFallback(key, value);
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (error) {
      _report('write', error);
    }
  }

  Future<void> deleteAll() async {
    fallback.deleteAllFallback();
    try {
      await _secureStorage.deleteAll();
    } catch (error) {
      _report('deleteAll', error);
    }
  }

  void _report(String operation, Object error) {
    if (!kDebugMode || !_reportedOperations.add(operation)) return;
    debugPrint(
      'Secure storage $operation failed; using fallback storage. $error',
    );
  }
}
