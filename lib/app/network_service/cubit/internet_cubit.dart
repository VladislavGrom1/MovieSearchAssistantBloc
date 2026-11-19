import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/network_service/network_service.dart';

/// Состояние связи в приложении.
///
/// [unknown] — проверка ещё не дала ответа. Трактовать его как «онлайн» нельзя:
/// именно на этой ошибке экран фильма шёл в сеть, ничего не зная о связи.
enum NetworkStatus { unknown, connected, disconnected }

class NetworkCubit extends Cubit<NetworkStatus> {
  NetworkCubit(this._statusSource) : super(NetworkStatus.unknown) {
    _subscription = _statusSource.onStatusChange.listen((isConnected) {
      if (isClosed) return;
      emit(isConnected ? NetworkStatus.connected : NetworkStatus.disconnected);
    });
  }

  final NetworkStatusSource _statusSource;
  StreamSubscription<bool>? _subscription;

  /// Перепроверить связь — вызывается при возврате приложения из фона.
  Future<void> refresh() => _statusSource.refresh();

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
