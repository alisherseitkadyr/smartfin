import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_client.dart';

/// Single shared Dio instance for the entire app.
/// All features import this instead of declaring their own.
final dioProvider = Provider<Dio>((_) => ApiClient.createDio());
