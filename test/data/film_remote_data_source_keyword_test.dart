import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/remote/film_remote_data_source.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({required this.body});

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
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  FilmRemoteDataSource buildDataSource(_FakeAdapter adapter) {
    final dio = Dio(BaseOptions(baseUrl: 'https://kinopoisk-proxy.example/'));
    dio.httpClientAdapter = adapter;
    return FilmRemoteDataSource(dio: dio);
  }

  // Ответ Кинопоиска на /api/v2.1/films/search-by-keyword: year и rating
  // приходят строками, у невышедших фильмов — буквальной строкой "null".
  const realResponse = {
    'keyword': 'matrix',
    'pagesCount': 2,
    'searchFilmsCountResult': 105,
    'films': [
      {
        'filmId': 301,
        'nameRu': 'Матрица',
        'nameEn': 'The Matrix',
        'type': 'FILM',
        'year': '1999',
        'description': 'Жизнь Томаса Андерсона разделена на две части.',
        'filmLength': '02:16',
        'countries': [
          {'country': 'Австралия'},
          {'country': 'США'},
        ],
        'genres': [
          {'genre': 'боевик'},
          {'genre': 'фантастика'},
        ],
        'rating': '8.5',
        'ratingVoteCount': 814839,
        'posterUrl': 'https://example.com/301.jpg',
        'posterUrlPreview': 'https://example.com/301_small.jpg',
      },
      {
        'filmId': 5516267,
        'nameRu': 'Матрица 5',
        'nameEn': 'Matrix 5',
        'type': 'FILM',
        'year': 'null',
        'countries': [
          {'country': 'США'},
        ],
        'genres': [
          {'genre': 'фантастика'},
        ],
        'rating': 'null',
        'ratingVoteCount': 0,
        'posterUrl': 'https://example.com/no-poster.png',
        'posterUrlPreview': 'https://example.com/no-poster.png',
      },
    ],
  };

  test('парсит реальный ответ search-by-keyword со строковыми year и rating',
      () async {
    final adapter = _FakeAdapter(body: realResponse);

    final films = await buildDataSource(adapter).getSearchFilmsByKeyword(
      'matrix',
      1,
    );

    expect(films, isNotNull);
    expect(films, hasLength(2));

    final matrix = films!.first;
    expect(matrix.kinopoiskId, 301);
    expect(matrix.nameRu, 'Матрица');
    expect(matrix.nameOriginal, 'The Matrix');
    expect(matrix.year, 1999);
    expect(matrix.ratingKinopoisk, 8.5);
    expect(matrix.countries, ['Австралия', 'США']);
    expect(matrix.genres, ['боевик', 'фантастика']);
    expect(matrix.posterUrl, 'https://example.com/301.jpg');

    final unreleased = films.last;
    expect(unreleased.kinopoiskId, 5516267);
    expect(unreleased.year, isNull);
    expect(unreleased.ratingKinopoisk, isNull);
  });

  test('передаёт keyword и page в запрос', () async {
    final adapter = _FakeAdapter(body: realResponse);

    await buildDataSource(adapter).getSearchFilmsByKeyword('матрица', 3);

    expect(adapter.lastRequest?.method, 'GET');
    expect(
      adapter.lastRequest?.uri.path,
      '/api/v2.1/films/search-by-keyword',
    );
    expect(adapter.lastRequest?.queryParameters['keyword'], 'матрица');
    expect(adapter.lastRequest?.queryParameters['page'].toString(), '3');
  });

  test('пустой films даёт null', () async {
    final adapter = _FakeAdapter(body: {
      'keyword': 'zzzz',
      'pagesCount': 0,
      'searchFilmsCountResult': 0,
      'films': <Object>[],
    });

    final films =
        await buildDataSource(adapter).getSearchFilmsByKeyword('zzzz', 1);

    expect(films, isNull);
  });
}
