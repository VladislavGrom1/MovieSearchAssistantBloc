import 'package:dio/dio.dart';

/// Проверяет, можно ли достучаться до нашего API — именно это пользователь
/// называет «интернет есть», а не резолвится ли чужой домен.
abstract interface class NetworkProbe {
  Future<bool> isReachable();
}

/// Проба реальным запросом в `baseUrl` клиента приложения: доходят ли
/// заголовки, жив ли прокси, не съел ли запрос таймаут.
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
          // Любой HTTP-ответ значит, что хост доступен: нам важен транспорт,
          // а не то, что именно прокси ответил на HEAD.
          validateStatus: (_) => true,
        ),
      );
      return true;
    } catch (_) {
      // Таймаут, обрыв соединения, ошибка платформы — всё это «связи нет».
      return false;
    }
  }
}
