import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_client.dart';
import '../services/safe_storage.dart';

final languageNotifierProvider =
    AsyncNotifierProvider<LanguageNotifier, String>(LanguageNotifier.new);

class LanguageNotifier extends AsyncNotifier<String> {
  static const _kLangKey = 'app_language_code';
  static const _kDefault = 'en';
  static const _supported = ['en', 'ru', 'kk'];

  SafeStorage get _storage => const SafeStorage();
  Dio get _dio => ApiClient.createDio(storage: _storage);

  @override
  Future<String> build() async {
    final stored = await _storage.read(key: _kLangKey);
    if (stored != null && _supported.contains(stored)) return stored;
    return _kDefault;
  }

  Future<void> setLanguage(String code) async {
    if (!_supported.contains(code)) return;
    await _storage.write(key: _kLangKey, value: code);
    state = AsyncData(code);
    try {
      await _dio.patch('/profile/settings', data: {'language_code': code});
    } catch (_) {}
  }
}

String languageLabel(String code) {
  switch (code) {
    case 'kk':
      return 'Қазақша';
    case 'ru':
      return 'Русский';
    default:
      return 'English';
  }
}
