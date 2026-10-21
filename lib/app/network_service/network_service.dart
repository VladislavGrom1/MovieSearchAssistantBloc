import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  static const Duration _lookupTimeout = Duration(seconds: 2);
  static const Duration _retryInterval = Duration(seconds: 2);
 
  final Connectivity _connectivity;
 
  NetworkService(this._connectivity);
 
  Stream<bool> get onStatusChange {
    late final StreamController<bool> controller;
    StreamSubscription? connectivitySubscription;
    Timer? retryTimer;
    var cancelled = false;
    var lastCheckId = 0;
 
    Future<void> check() async {
      retryTimer?.cancel();
      final checkId = ++lastCheckId;
      final isConnected = await hasConnection();
 
      if (cancelled || checkId != lastCheckId) return;
 
      controller.add(isConnected);
      if (!isConnected) {
        retryTimer = Timer(_retryInterval, check);
      }
    }
 
    controller = StreamController<bool>(
      onListen: () {
        check();
        connectivitySubscription =
            _connectivity.onConnectivityChanged.listen((_) => check());
      },
      onCancel: () {
        cancelled = true;
        retryTimer?.cancel();
        connectivitySubscription?.cancel();
      },
    );
 
    return controller.stream;
  }
 
  Future<bool> hasConnection() async {
    try {
      final resultYandex =
          await InternetAddress.lookup('yandex.ru').timeout(_lookupTimeout);
      return resultYandex.isNotEmpty && resultYandex[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}