import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  final Connectivity _connectivity;

  NetworkService(this._connectivity);

  Stream<bool> get onStatusChange async* {
    yield await hasConnection();

    await for (final _ in _connectivity.onConnectivityChanged) {
      yield await hasConnection();
    }
  }

  Future<bool> hasConnection() async {
    try {
      final result = await InternetAddress.lookup('yandex.ru');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}