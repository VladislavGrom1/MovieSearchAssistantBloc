import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/remote/ai_film_remote_data_source.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({required this.statusCode, required this.body});

  final int statusCode;
  final Object? body;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  AiFilmRemoteDataSource buildDataSource(_FakeAdapter adapter) {
    final dio = Dio(BaseOptions(baseUrl: 'https://kinopoisk-proxy.example/'));
    dio.httpClientAdapter = adapter;
    return AiFilmRemoteDataSource(dio: dio);
  }

  test('отправляет POST с query и парсит movies', () async {
    final adapter = _FakeAdapter(
      statusCode: 200,
      body: {
        'movies': [
          {
            'title': "Ocean's Eleven",
            'year': 2001,
            'reason': 'Ограбление казино.',
            'kinopoiskId': 526,
            'posterUrl': 'https://example.com/1.jpg',
            'rating': '8.1',
          },
          {
            'title': 'Heat',
            'year': null,
            'reason': 'Погоня.',
            'kinopoiskId': null,
            'posterUrl': null,
            'rating': null,
          },
        ],
      },
    );

    final result = await buildDataSource(adapter).getRecommendations('ограбление');

    expect(result, hasLength(2));
    expect(result.first.title, "Ocean's Eleven");
    expect(result.first.description, 'Ограбление казино.');
    expect(adapter.lastRequest?.method, 'POST');
    expect(adapter.lastRequest?.uri.toString(), aiFilmsEndpoint);
    expect(adapter.lastRequest?.data, {'query': 'ограбление'});
  });

  test('пустой movies возвращает пустой список, а не null', () async {
    final adapter = _FakeAdapter(statusCode: 200, body: {'movies': <dynamic>[]});

    final result = await buildDataSource(adapter).getRecommendations('что-нибудь');

    expect(result, isEmpty);
  });

  test('404 отдаёт сообщение про ненайденные фильмы', () async {
    final adapter = _FakeAdapter(
      statusCode: 404,
      body: {'error': 'Фильмы не найдены на Кинопоиске.'},
    );

    await expectLater(
      buildDataSource(adapter).getRecommendations('q'),
      throwsA(
        isA<AiServiceFailure>().having(
          (e) => e.message,
          'message',
          'Фильмы не найдены. Попробуйте описать иначе.',
        ),
      ),
    );
  });

  test('502 отдаёт сообщение про недоступную модель', () async {
    final adapter = _FakeAdapter(
      statusCode: 502,
      body: {'error': 'Ошибка модели. Возможно, лимит нейронов исчерпан.'},
    );

    await expectLater(
      buildDataSource(adapter).getRecommendations('q'),
      throwsA(
        isA<AiServiceFailure>().having(
          (e) => e.message,
          'message',
          'Модель не смогла ответить. Попробуйте позже.',
        ),
      ),
    );
  });

  test('500 не пробрасывает технический текст сервера', () async {
    final adapter = _FakeAdapter(
      statusCode: 500,
      body: {'error': 'AI binding не настроен'},
    );

    await expectLater(
      buildDataSource(adapter).getRecommendations('q'),
      throwsA(
        isA<AiServiceFailure>().having(
          (e) => e.message,
          'message',
          'Сервис подбора временно недоступен. Попробуйте позже.',
        ),
      ),
    );
  });

  test('незнакомый статус с error в теле показывает текст сервера', () async {
    final adapter = _FakeAdapter(
      statusCode: 503,
      body: {'error': 'Технические работы'},
    );

    await expectLater(
      buildDataSource(adapter).getRecommendations('q'),
      throwsA(
        isA<AiServiceFailure>()
            .having((e) => e.message, 'message', 'Технические работы'),
      ),
    );
  });

  test('незнакомый статус без error падает в общий маппер', () async {
    final adapter = _FakeAdapter(statusCode: 503, body: {'ok': false});

    await expectLater(
      buildDataSource(adapter).getRecommendations('q'),
      throwsA(
        isA<AiServiceFailure>().having(
          (e) => e.message,
          'message',
          ServerFailure().message,
        ),
      ),
    );
  });
}
