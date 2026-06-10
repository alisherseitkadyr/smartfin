import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'safe_storage.dart';

/// Central API client configuration with base URL and interceptors
class ApiClient {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  // Serializes concurrent refresh calls so only one refresh runs at a time.
  static Completer<bool>? _refreshCompleter;

  // Called after tokens are wiped on refresh failure so callers can react.
  static void Function()? onSessionExpired;

  static String get baseUrl {
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) {
      final normalized = configured.endsWith('/')
          ? configured.substring(0, configured.length - 1)
          : configured;
      return normalized.endsWith('/api') ? normalized : '$normalized/api';
    }
    if (kIsWeb){
      return 'https://diploma-5ebq.onrender.com/api';
    }
    // Default to localhost (works with adb reverse for physical devices)
    // For emulator, use 10.0.2.2 or pass --dart-define=API_BASE_URL=http://10.0.2.2:8081
    return 'https://diploma-5ebq.onrender.com/api';
    // return 'http://localhost:8081/api';
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
        onError: (error, handler) async {
          if (error.requestOptions.path == '/auth/refresh') {
            return handler.next(error);
          }

          if (error.response?.statusCode == 401) {
            try {
              final refreshed = await _getOrAwaitRefresh(storage);

              if (refreshed) {
                final newToken = await storage.read(key: _accessTokenKey);
                error.requestOptions.headers['Authorization'] =
                    'Bearer $newToken';
                return handler.resolve(await dio.fetch(error.requestOptions));
              }

              // Refresh failed — wipe stored tokens so the app starts clean.
              await storage.delete(key: _accessTokenKey);
              await storage.delete(key: _refreshTokenKey);
              onSessionExpired?.call();
            } on DioException catch (e) {
              return handler.reject(e);
            }
          }
          return handler.next(error);
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

  static Future<bool> _getOrAwaitRefresh(SafeStorage storage) async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }
    _refreshCompleter = Completer<bool>();
    try {
      final result = await _refreshAccessToken(storage);
      _refreshCompleter!.complete(result);
      return result;
    } catch (_) {
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  static Future<bool> _refreshAccessToken(SafeStorage storage) async {
    try {
      final refreshToken = await storage.read(key: _refreshTokenKey);

      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      // Separate Dio instance to avoid interceptor recursion
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
        ),
      );

      final response = await refreshDio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final newAccessToken = response.data['access_token'];
      final newRefreshToken = response.data['refresh_token'];

      if (newAccessToken == null || newAccessToken is! String) {
        return false;
      }

      await storage.write(key: _accessTokenKey, value: newAccessToken);

      // Backend rotates the refresh token on every use — save the new one.
      if (newRefreshToken is String && newRefreshToken.isNotEmpty) {
        await storage.write(key: _refreshTokenKey, value: newRefreshToken);
      }

      return true;
    } catch (_) {
      return false;
    }
  }
}
