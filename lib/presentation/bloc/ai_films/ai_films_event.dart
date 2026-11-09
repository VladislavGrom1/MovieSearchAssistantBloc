part of 'ai_films_bloc.dart';

sealed class AiFilmsEvent extends Equatable {
  const AiFilmsEvent();

  @override
  List<Object?> get props => [];
}

final class AiFilmsRequested extends AiFilmsEvent {
  final String query;

  const AiFilmsRequested(this.query);

  @override
  List<Object?> get props => [query];
}

final class AiFilmsRetryRequested extends AiFilmsEvent {
  const AiFilmsRetryRequested();
}

/// Возвращает экран в исходное состояние: убирает результаты, ошибку и
/// пустой ответ, чтобы можно было начать подбор заново.
final class AiFilmsResetRequested extends AiFilmsEvent {
  const AiFilmsResetRequested();
}
