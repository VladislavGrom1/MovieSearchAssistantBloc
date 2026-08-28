
sealed class RemoteDataSourceException implements Exception{
  final String message;
  RemoteDataSourceException(this.message);
}

class NetworkFailure extends RemoteDataSourceException {
  NetworkFailure() : super("Отсутствует интернет-соединение. \nПроверьте подключение к интернету и попробуйте снова.");
}

class ServerFailure extends RemoteDataSourceException {
  ServerFailure() : super("Сервер временно недоступен или не отвечает на запросы. \nПожалуйста, попробуйте позже.");
}

class NotFoundFailure extends RemoteDataSourceException {
  NotFoundFailure() : super("Не удалось получить данные с сервера.");
}

class UnauthorizedFailure extends RemoteDataSourceException {
  UnauthorizedFailure() : super("Неверный API ключ. \nAPI ключ недействителен.");
}

class TooManyRequests extends RemoteDataSourceException {
  TooManyRequests() : super("Превышен лимит количества запросов к серверу в сутки. \nПожалуйста, подождите до сброса лимита или перейдите на стандартный план приложения в Профиле.");
}

class UnknownFailure extends RemoteDataSourceException{
  UnknownFailure() : super("Неизвестная ошибка. \nПопробуйте обновить страницу.");
}