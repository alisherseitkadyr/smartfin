import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'safe_storage.dart';

/// Central API client configuration with base URL and interceptors
class ApiClient {
  static const _accessTokenKey = 'access_token';

  static String get baseUrl {
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) {
      final normalized = configured.endsWith('/')
          ? configured.substring(0, configured.length - 1)
          : configured;
      return normalized.endsWith('/api') ? normalized : '$normalized/api';
    }

    // Android emulator routes localhost through 10.0.2.2
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8081/api';
    }
    return 'http://localhost:8081/api';
  }

  static Dio createDio({SafeStorage storage = const SafeStorage()}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.read(key: _accessTokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    // Add logging interceptor in debug builds.
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
          requestHeader: true,
          responseHeader: true,
        ),
      );
    }

    return dio;
  }
}
