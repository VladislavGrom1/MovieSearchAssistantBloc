import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:movie_search_assistant_bloc/app/network_service/connectivity_events.dart';
import 'package:movie_search_assistant_bloc/app/network_service/cubit/internet_cubit.dart';
import 'package:movie_search_assistant_bloc/app/network_service/network_probe.dart';
import 'package:movie_search_assistant_bloc/app/network_service/network_service.dart';

void registerNetworkModule(GetIt getIt) {
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());
  getIt.registerLazySingleton<ConnectivityEvents>(
    () => PlusConnectivityEvents(getIt<Connectivity>()),
  );
  getIt.registerLazySingleton<NetworkProbe>(
    () => HttpNetworkProbe(getIt<Dio>()),
  );
  getIt.registerLazySingleton<NetworkService>(
    () => NetworkService(
      connectivity: getIt<ConnectivityEvents>(),
      probe: getIt<NetworkProbe>(),
    ),
  );
  getIt.registerLazySingleton<NetworkStatusSource>(
    () => getIt<NetworkService>(),
  );
  getIt.registerLazySingleton<NetworkCubit>(
    () => NetworkCubit(getIt<NetworkStatusSource>()),
  );
}
