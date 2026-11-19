import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:movie_search_assistant_bloc/app/network_service/connectivity_events.dart';
import 'package:movie_search_assistant_bloc/app/network_service/cubit/internet_cubit.dart';
import 'package:movie_search_assistant_bloc/app/network_service/network_module.dart';
import 'package:movie_search_assistant_bloc/app/network_service/network_probe.dart';
import 'package:movie_search_assistant_bloc/app/network_service/network_service.dart';

void main() {
  // Регрессия: в проде регистрация NetworkCubit резолвила NetworkStatusSource
  // через вывод типа из параметра конструктора, а такой тип в DI не
  // зарегистрирован — приложение падало на старте с
  // "Error while creating NetworkCubit".
  test('сетевой модуль собирается на пустом GetIt и отдаёт рабочий кубит',
      () async {
    final getIt = GetIt.asNewInstance();
    registerNetworkModule(getIt);

    getIt.unregister<ConnectivityEvents>();
    getIt.registerSingleton<ConnectivityEvents>(
      _FakeConnectivityEvents(<ConnectivityResult>[ConnectivityResult.wifi]),
    );
    getIt.unregister<NetworkProbe>();
    getIt.registerSingleton<NetworkProbe>(_FakeNetworkProbe(true));

    final cubit = getIt<NetworkCubit>();
    expect(cubit.state, NetworkStatus.unknown);
    expect(identical(getIt<NetworkService>(), getIt<NetworkService>()), isTrue);

    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(cubit.state, NetworkStatus.connected);

    await getIt<NetworkService>().dispose();
    await cubit.close();
  });
}

class _FakeConnectivityEvents implements ConnectivityEvents {
  _FakeConnectivityEvents(this.transport);

  final List<ConnectivityResult> transport;

  @override
  Stream<List<ConnectivityResult>> get onChanged => const Stream.empty();

  @override
  Future<List<ConnectivityResult>> check() async => transport;
}

class _FakeNetworkProbe implements NetworkProbe {
  _FakeNetworkProbe(this.reachable);

  final bool reachable;

  @override
  Future<bool> isReachable() async => reachable;
}
