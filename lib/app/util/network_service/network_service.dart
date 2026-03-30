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
    final result = await _connectivity.checkConnectivity();

    final hasNetwork = result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.mobile);

    if (!hasNetwork) return false;

    try {
      final lookup = await InternetAddress.lookup('google.com');
      return lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }
}