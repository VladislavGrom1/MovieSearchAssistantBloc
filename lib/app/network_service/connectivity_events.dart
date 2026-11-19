import 'package:connectivity_plus/connectivity_plus.dart';

/// События транспорта: есть ли у устройства сеть на уровне радио.
///
/// Это только повод перепроверить связь: плагин сам не знает, доходят ли
/// запросы до нашего API, и предупреждает об этом в документации
/// `checkConnectivity`. Шов нужен, чтобы `NetworkService` можно было
/// проверить тестом без платформенных каналов.
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
