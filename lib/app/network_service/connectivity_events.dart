import 'package:connectivity_plus/connectivity_plus.dart';

abstract interface class ConnectivityEvents {
  Stream<List<ConnectivityResult>> get onChanged;

  Future<List<ConnectivityResult>> check();
}

class PlusConnectivityEvents implements ConnectivityEvents {
  PlusConnectivityEvents(this._connectivity);

  final Connectivity _connectivity;

  @override
  Stream<List<ConnectivityResult>> get onChanged =>
      _connectivity.onConnectivityChanged;

  @override
  Future<List<ConnectivityResult>> check() => _connectivity.checkConnectivity();
}
