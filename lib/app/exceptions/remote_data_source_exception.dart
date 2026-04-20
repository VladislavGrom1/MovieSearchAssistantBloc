
sealed class RemoteDataSourceException implements Exception{
  final String message;
  RemoteDataSourceException(this.message);
}

class NetworkFailure extends RemoteDataSourceException {
  NetworkFailure() : super("Отсутствует интернет-соединение");
}

class ServerFailure extends RemoteDataSourceException {
  ServerFailure() : super("Сервер не отвечает");
}

class NotFoundFailure extends RemoteDataSourceException {
  NotFoundFailure() : super("Не удалось получить данные с сервера");
}

class UnauthorizedFailure extends RemoteDataSourceException {
  UnauthorizedFailure() : super("Неверный API ключ");
}

class TooManyRequests extends RemoteDataSourceException {
  TooManyRequests() : super("Превышен лимит количества запросов в сутки");
}

class UnknownFailure extends RemoteDataSourceException{
  UnknownFailure() : super("Неизвестная ошибка");
}