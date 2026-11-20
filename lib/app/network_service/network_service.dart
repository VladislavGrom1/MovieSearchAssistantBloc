import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:movie_search_assistant_bloc/app/network_service/connectivity_events.dart';
import 'package:movie_search_assistant_bloc/app/network_service/network_probe.dart';

abstract interface class NetworkStatusSource {
  Stream<bool> get onStatusChange;

  Future<void> refresh();
}

class NetworkService implements NetworkStatusSource {
  NetworkService({
    required ConnectivityEvents connectivity,
    required NetworkProbe probe,
    this.retryInterval = const Duration(seconds: 15),
  })  : _connectivity = connectivity,
        _probe = probe {
    _subscription = _connectivity.onChanged.listen(
      _onTransportChanged,
      onError: _onTransportError,
    );
    _bootstrap();
  }

  final ConnectivityEvents _connectivity;
  final NetworkProbe _probe;

  final Duration retryInterval;

  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _retryTimer;
  bool? _last;
  bool _checking = false;
  int _generation = 0;
  bool _disposed = false;

  @override
  Stream<bool> get onStatusChange => _controller.stream;

  @override
  Future<void> refresh() {
    _generation++;
    return _check();
  }

  Future<void> _bootstrap() async {
    try {
      final results = await _connectivity.check();
      if (!_hasTransport(results)) {
        _publish(false);
        return;
      }
    } catch (error, stackTrace) {
      _log('не удалось прочитать состояние транспорта: $error', stackTrace);
    }
    await _check();
  }

  void _onTransportChanged(List<ConnectivityResult> results) {
    if (_disposed) return;
    _generation++;
    if (!_hasTransport(results)) {
      _publish(false);
      return;
    }
    _check();
  }

  void _onTransportError(Object error, StackTrace stackTrace) {
    _log('поток транспорта оборвался: $error', stackTrace);
  }

  bool _hasTransport(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);

  Future<void> _check() async {
    if (_disposed || _checking) return;
    _checking = true;
    try {
      bool? latest;
      for (var attempt = 0; attempt < 3; attempt++) {
        final generation = _generation;
        latest = await _probe.isReachable();
        if (_disposed) return;
        if (generation == _generation) break;
      }
      if (latest != null) _publish(latest);
    } finally {
      _checking = false;
    }
  }

  void _publish(bool reachable) {
    if (_disposed) return;
    _syncRetryTimer(reachable);
    if (_last == reachable) return;
    _last = reachable;
    _controller.add(reachable);
  }

  void _syncRetryTimer(bool reachable) {
    if (reachable) {
      _retryTimer?.cancel();
      _retryTimer = null;
      return;
    }
    _retryTimer ??= Timer.periodic(retryInterval, (_) => _check());
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _retryTimer?.cancel();
    _retryTimer = null;
    await _subscription?.cancel();
    await _controller.close();
  }

  void _log(String message, StackTrace? stackTrace) {
    if (!kDebugMode) return;
    debugPrint('[NetworkService] $message${stackTrace == null ? '' : '\n$stackTrace'}');
  }
}
