import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final connectivity = Connectivity();

    final sub = connectivity.onConnectivityChanged.listen((results) {
      state = AsyncData(results.any((r) => r != ConnectivityResult.none));
    });
    ref.onDispose(sub.cancel);

    final results = await connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<void> recheck() async {
    state = const AsyncLoading();
    final results = await Connectivity().checkConnectivity();
    state = AsyncData(results.any((r) => r != ConnectivityResult.none));
  }
}

final connectivityProvider =
    AsyncNotifierProvider<ConnectivityNotifier, bool>(ConnectivityNotifier.new);
