import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NetworkStatus { online, offline }

class NetworkNotifier extends StateNotifier<NetworkStatus> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  NetworkNotifier() : super(NetworkStatus.online) {
    _init();
  }

  Future<void> _init() async {
    final results = await Connectivity().checkConnectivity();
    _updateStatus(results);

    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      _updateStatus(results);
    });
  }

  void _updateStatus(List<ConnectivityResult> results) {
    if (results.isEmpty ||
        results.every((result) => result == ConnectivityResult.none)) {
      state = NetworkStatus.offline;
    } else {
      state = NetworkStatus.online;
    }
  }

  Future<void> checkConnection() async {
    final results = await Connectivity().checkConnectivity();
    _updateStatus(results);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final networkProvider =
    StateNotifierProvider<NetworkNotifier, NetworkStatus>((ref) {
  return NetworkNotifier();
});
