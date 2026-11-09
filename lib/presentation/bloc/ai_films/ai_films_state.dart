part of 'ai_films_bloc.dart';

sealed class AiFilmsState extends Equatable {
  final String? query;

  /// Идёт повторный запрос по кнопке «Повторить».
  ///
  /// Повтор не переводит экран в [AiFilmsLoading]: сообщение об ошибке
  /// остаётся на месте, иначе заглушки карточек мелькают на один кадр.
  final bool isRetrying;

  const AiFilmsState({this.query, this.isRetrying = false});

  @override
  List<Object?> get props => [query, isRetrying];
}

final class AiFilmsInitial extends AiFilmsState {
  const AiFilmsInitial();
}

final class AiFilmsLoading extends AiFilmsState {
  const AiFilmsLoading({super.query});
}

final class AiFilmsLoaded extends AiFilmsState {
  final List<AiFilmRecommendation> recommendations;

  const AiFilmsLoaded({super.query, required this.recommendations});

  @override
  List<Object?> get props => [query, recommendations];
}

final class AiFilmsEmpty extends AiFilmsState {
  const AiFilmsEmpty({super.query, super.isRetrying});

  AiFilmsEmpty copyWith({bool? isRetrying}) => AiFilmsEmpty(
        query: query,
        isRetrying: isRetrying ?? this.isRetrying,
      );
}

final class AiFilmsFailure extends AiFilmsState {
  final String message;

  const AiFilmsFailure({
    super.query,
    required this.message,
    super.isRetrying,
  });

  AiFilmsFailure copyWith({bool? isRetrying}) => AiFilmsFailure(
        query: query,
        message: message,
        isRetrying: isRetrying ?? this.isRetrying,
      );

  @override
  List<Object?> get props => [query, message, isRetrying];
}
