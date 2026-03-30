import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/util/network_service/network_service.dart';

enum NetworkStatus { initial, connected, disconnected }

class NetworkCubit extends Cubit<NetworkStatus> {
  final NetworkService networkInfoService;
  StreamSubscription? _subscription;

  NetworkCubit(this.networkInfoService) : super(NetworkStatus.initial) {
    _subscription = networkInfoService.onStatusChange.listen((isConnected) {
      emit(isConnected ? NetworkStatus.connected : NetworkStatus.disconnected);
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}