import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  static const Duration _checkInterval = Duration(seconds: 3);
  static const Duration _lookupTimeout = Duration(seconds: 2);
 
  final Connectivity _connectivity;
  final List<String> _hosts;
 
  NetworkService(this._connectivity, {String? apiHost})
      : _hosts = [
          'google.com',
          'yandex.ru',
        ];
 
  Stream<bool> get onStatusChange {
    late final StreamController<bool> controller;
    StreamSubscription<dynamic>? connectivitySubscription;
    Timer? timer;
    bool? last;
    var checking = false;
 
    Future<void> check() async {
      if (checking) return;
      checking = true;
      final isConnected = await hasConnection();
      checking = false;
 
      if (controller.isClosed) return;
      if (isConnected != last) {
        last = isConnected;
        controller.add(isConnected);
      }
    }
 
    controller = StreamController<bool>(
      onListen: () {
        check();
        connectivitySubscription =
            _connectivity.onConnectivityChanged.listen((_) => check());
        timer = Timer.periodic(_checkInterval, (_) => check());
      },
      onCancel: () {
        timer?.cancel();
        connectivitySubscription?.cancel();
      },
    );
 
    return controller.stream;
  }
 
  Future<bool> hasConnection() async {
    for (final host in _hosts) {
      try {
        final result =
            await InternetAddress.lookup(host).timeout(_lookupTimeout);
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) return true;
      } catch (_) {
      }
    }
    return false;
  }
}