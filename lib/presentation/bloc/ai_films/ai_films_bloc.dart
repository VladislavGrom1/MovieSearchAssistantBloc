import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_film_recommendation.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_ai_film_recommendations_use_case.dart';

part 'ai_films_event.dart';
part 'ai_films_state.dart';

class AiFilmsBloc extends Bloc<AiFilmsEvent, AiFilmsState> {
  final GetAiFilmRecommendationsUseCase getAiFilmRecommendationsUseCase;

  /// Номер актуального запроса. Сброс и каждый новый запрос увеличивают его,
  /// поэтому ответ устаревшего запроса не вернёт экран из Initial в
  /// Loaded/Failure.
  int _requestToken = 0;

  AiFilmsBloc(this.getAiFilmRecommendationsUseCase)
      : super(const AiFilmsInitial()) {
    on<AiFilmsRequested>(_onAiFilmsRequested);
    on<AiFilmsRetryRequested>(_onAiFilmsRetryRequested);
    on<AiFilmsResetRequested>(_onAiFilmsResetRequested);
  }

  void _onAiFilmsResetRequested(
    AiFilmsResetRequested event,
    Emitter<AiFilmsState> emit,
  ) {
    _requestToken++;
    emit(const AiFilmsInitial());
  }

  Future<void> _onAiFilmsRequested(
    AiFilmsRequested event,
    Emitter<AiFilmsState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) return;

    await _load(query, emit);
  }

  Future<void> _onAiFilmsRetryRequested(
    AiFilmsRetryRequested event,
    Emitter<AiFilmsState> emit,
  ) async {
    final query = state.query?.trim();
    if (query == null || query.isEmpty) return;

    // Повтор не уводит экран в Loading: сообщение об ошибке остаётся
    // на месте и показывает индикатор, иначе заглушки карточек мелькают.
    switch (state) {
      case AiFilmsFailure failure:
        emit(failure.copyWith(isRetrying: true));
      case AiFilmsEmpty empty:
        emit(empty.copyWith(isRetrying: true));
      default:
        return;
    }

    await _load(query, emit, isRetry: true);
  }

  Future<void> _load(
    String query,
    Emitter<AiFilmsState> emit, {
    bool isRetry = false,
  }) async {
    final token = ++_requestToken;

    if (!isRetry) {
      emit(AiFilmsLoading(query: query));
    }

    try {
      final recommendations = await getAiFilmRecommendationsUseCase(query);
      if (!_isActual(token, emit)) return;

      if (recommendations.isEmpty) {
        emit(AiFilmsEmpty(query: query));
      } else {
        emit(AiFilmsLoaded(query: query, recommendations: recommendations));
      }
    } on RemoteDataSourceException catch (e) {
      if (!_isActual(token, emit)) return;
      emit(AiFilmsFailure(query: query, message: e.message));
    } catch (_) {
      if (!_isActual(token, emit)) return;
      emit(
        AiFilmsFailure(
          query: query,
          message: 'Неизвестная ошибка. Попробуйте ещё раз.',
        ),
      );
    }
  }

  /// Ответ актуален, только если BLoC жив, emit ещё открыт и с момента
  /// запуска запроса не было ни нового запроса, ни сброса.
  bool _isActual(int token, Emitter<AiFilmsState> emit) =>
      !isClosed && !emit.isDone && token == _requestToken;
}
