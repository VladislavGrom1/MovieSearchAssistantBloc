import 'package:dio/dio.dart';

abstract interface class NetworkProbe {
  Future<bool> isReachable();
}

class HttpNetworkProbe implements NetworkProbe {
  HttpNetworkProbe(this._dio, {this.timeout = const Duration(seconds: 3)});

  final Dio _dio;
  final Duration timeout;

  @override
  Future<bool> isReachable() async {
    try {
      await _dio.head<void>(
        '/',
        options: Options(
          connectTimeout: timeout,
          receiveTimeout: timeout,
          sendTimeout: timeout,
          validateStatus: (_) => true,
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
