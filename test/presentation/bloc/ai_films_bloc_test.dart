import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_film_recommendation.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_ai_film_recommendations_use_case.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/ai_films/ai_films_bloc.dart';

class MockGetAiFilmRecommendationsUseCase extends Mock
    implements GetAiFilmRecommendationsUseCase {}

void main() {
  late MockGetAiFilmRecommendationsUseCase useCase;
  late Completer<List<AiFilmRecommendation>> completer;

  const recommendation = AiFilmRecommendation(
    film: FilmEntity(kinopoiskId: 1, nameOriginal: 'Heat'),
    description: 'Погоня в Лос-Анджелесе.',
  );

  setUp(() {
    useCase = MockGetAiFilmRecommendationsUseCase();
    completer = Completer<List<AiFilmRecommendation>>();
  });

  AiFilmsBloc buildBloc() => AiFilmsBloc(useCase);

  test('initial state is AiFilmsInitial', () {
    expect(buildBloc().state, isA<AiFilmsInitial>());
  });

  blocTest<AiFilmsBloc, AiFilmsState>(
    'Requested обрезает пробелы и эмитит [Loading, Loaded]',
    build: () {
      when(() => useCase.call('комедия'))
          .thenAnswer((_) async => [recommendation]);
      return buildBloc();
    },
    act: (bloc) => bloc.add(const AiFilmsRequested('  комедия  ')),
    expect: () => [
      isA<AiFilmsLoading>().having((s) => s.query, 'query', 'комедия'),
      isA<AiFilmsLoaded>()
          .having((s) => s.query, 'query', 'комедия')
          .having((s) => s.recommendations, 'recommendations', [recommendation]),
    ],
  );

  blocTest<AiFilmsBloc, AiFilmsState>(
    'пустой список рекомендаций даёт AiFilmsEmpty',
    build: () {
      when(() => useCase.call(any())).thenAnswer((_) async => []);
      return buildBloc();
    },
    act: (bloc) => bloc.add(const AiFilmsRequested('ничего')),
    expect: () => [
      isA<AiFilmsLoading>(),
      isA<AiFilmsEmpty>().having((s) => s.query, 'query', 'ничего'),
    ],
  );

  blocTest<AiFilmsBloc, AiFilmsState>(
    'RemoteDataSourceException превращается в AiFilmsFailure с её текстом',
    build: () {
      when(() => useCase.call(any())).thenThrow(
        AiServiceFailure('Фильмы не найдены. Попробуйте описать иначе.'),
      );
      return buildBloc();
    },
    act: (bloc) => bloc.add(const AiFilmsRequested('запрос')),
    expect: () => [
      isA<AiFilmsLoading>(),
      isA<AiFilmsFailure>().having(
        (s) => s.message,
        'message',
        'Фильмы не найдены. Попробуйте описать иначе.',
      ),
    ],
  );

  blocTest<AiFilmsBloc, AiFilmsState>(
    'любое другое исключение даёт нейтральный текст',
    build: () {
      when(() => useCase.call(any())).thenThrow(Exception('boom'));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const AiFilmsRequested('запрос')),
    expect: () => [
      isA<AiFilmsLoading>(),
      isA<AiFilmsFailure>().having(
        (s) => s.message,
        'message',
        'Неизвестная ошибка. Попробуйте ещё раз.',
      ),
    ],
  );

  blocTest<AiFilmsBloc, AiFilmsState>(
    'Retry после ошибки повторяет исходный запрос',
    build: () {
      var callCount = 0;
      when(() => useCase.call('комедия')).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          throw AiServiceFailure(
            'Модель не смогла ответить. Попробуйте позже.',
          );
        }
        return [recommendation];
      });
      return buildBloc();
    },
    act: (bloc) {
      bloc.add(const AiFilmsRequested('комедия'));
      bloc.add(const AiFilmsRetryRequested());
    },
    expect: () => [
      isA<AiFilmsLoading>(),
      isA<AiFilmsFailure>().having((s) => s.isRetrying, 'isRetrying', false),
      isA<AiFilmsFailure>().having((s) => s.isRetrying, 'isRetrying', true),
      isA<AiFilmsLoaded>(),
    ],
    verify: (_) {
      verify(() => useCase.call('комедия')).called(2);
    },
  );

  blocTest<AiFilmsBloc, AiFilmsState>(
    'Retry из пустого результата не эмитит Loading',
    build: () {
      var callCount = 0;
      when(() => useCase.call('аниме')).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) return [];
        return [recommendation];
      });
      return buildBloc();
    },
    act: (bloc) {
      bloc.add(const AiFilmsRequested('аниме'));
      bloc.add(const AiFilmsRetryRequested());
    },
    expect: () => [
      isA<AiFilmsLoading>(),
      isA<AiFilmsEmpty>().having((s) => s.isRetrying, 'isRetrying', false),
      isA<AiFilmsEmpty>().having((s) => s.isRetrying, 'isRetrying', true),
      isA<AiFilmsLoaded>(),
    ],
  );

  blocTest<AiFilmsBloc, AiFilmsState>(
    'Retry в Initial ничего не делает',
    build: buildBloc,
    act: (bloc) => bloc.add(const AiFilmsRetryRequested()),
    expect: () => [],
    verify: (_) {
      verifyNever(() => useCase.call(any()));
    },
  );

  blocTest<AiFilmsBloc, AiFilmsState>(
    'пустой и пробельный запрос не уходит в use case',
    build: buildBloc,
    act: (bloc) {
      bloc.add(const AiFilmsRequested(''));
      bloc.add(const AiFilmsRequested('   '));
    },
    expect: () => [],
    verify: (_) {
      verifyNever(() => useCase.call(any()));
    },
  );

  blocTest<AiFilmsBloc, AiFilmsState>(
    'Сброс после результата возвращает Initial',
    build: () {
      when(() => useCase.call('комедия'))
          .thenAnswer((_) async => [recommendation]);
      return buildBloc();
    },
    act: (bloc) async {
      bloc.add(const AiFilmsRequested('комедия'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      bloc.add(const AiFilmsResetRequested());
    },
    expect: () => [
      isA<AiFilmsLoading>(),
      isA<AiFilmsLoaded>(),
      isA<AiFilmsInitial>(),
    ],
    verify: (_) {
      verify(() => useCase.call('комедия')).called(1);
    },
  );

  blocTest<AiFilmsBloc, AiFilmsState>(
    'Сброс после ошибки возвращает Initial',
    build: () {
      when(() => useCase.call(any())).thenThrow(AiServiceFailure('нет сети'));
      return buildBloc();
    },
    act: (bloc) async {
      bloc.add(const AiFilmsRequested('комедия'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      bloc.add(const AiFilmsResetRequested());
    },
    expect: () => [
      isA<AiFilmsLoading>(),
      isA<AiFilmsFailure>(),
      isA<AiFilmsInitial>(),
    ],
  );

  blocTest<AiFilmsBloc, AiFilmsState>(
    'Сброс во время загрузки отбрасывает ответ устаревшего запроса',
    build: () {
      when(() => useCase.call('комедия')).thenAnswer(
        (_) => completer.future,
      );
      return buildBloc();
    },
    act: (bloc) async {
      bloc.add(const AiFilmsRequested('комедия'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      bloc.add(const AiFilmsResetRequested());
      completer.complete([recommendation]);
      await Future<void>.delayed(const Duration(milliseconds: 10));
    },
    expect: () => [
      isA<AiFilmsLoading>(),
      isA<AiFilmsInitial>(),
    ],
  );

  blocTest<AiFilmsBloc, AiFilmsState>(
    'Сброс в Initial безопасен',
    build: buildBloc,
    act: (bloc) => bloc.add(const AiFilmsResetRequested()),
    expect: () => [isA<AiFilmsInitial>()],
    verify: (_) {
      verifyNever(() => useCase.call(any()));
    },
  );
}
