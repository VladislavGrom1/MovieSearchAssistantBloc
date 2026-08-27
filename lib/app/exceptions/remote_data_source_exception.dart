
sealed class RemoteDataSourceException implements Exception{
  final String message;
  RemoteDataSourceException(this.message);
}

class NetworkFailure extends RemoteDataSourceException {
  NetworkFailure() : super("Отсутствует интернет-соединение. \n Проверьте подключение к интернету и попробуйте снова.");
}

class ServerFailure extends RemoteDataSourceException {
  ServerFailure() : super("Сервер временно недоступен или не отвечает на запросы. \n Пожалуйста, попробуйте позже.");
}

class NotFoundFailure extends RemoteDataSourceException {
  NotFoundFailure() : super("Не удалось получить данные с сервера.");
}

class UnauthorizedFailure extends RemoteDataSourceException {
  UnauthorizedFailure() : super("Неверный API ключ. \nAPI ключ недействителен.");
}

class TooManyRequests extends RemoteDataSourceException {
  TooManyRequests() : super("Превышен лимит количества запросов к серверу в сутки. \n Пожалуйста, подождите до сброса лимита или перейдите на общий ");
}

class UnknownFailure extends RemoteDataSourceException{
  UnknownFailure() : super("Неизвестная ошибка");
}