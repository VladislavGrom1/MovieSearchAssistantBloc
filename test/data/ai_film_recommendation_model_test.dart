import 'package:flutter_test/flutter_test.dart';
import 'package:movie_search_assistant_bloc/data/models/ai_film_recommendation_model.dart';

void main() {
  test('парсит полный ответ сервиса', () {
    final model = AiFilmRecommendationModel.fromJson(const {
      'nameEn': "Ocean's Eleven",
      'nameRu': null,
      'year': 2001,
      'reason': 'Дэнни Оушен собирает команду из одиннадцати профессионалов.',
      'kinopoiskId': 526,
      'posterUrl': 'https://example.com/poster.jpg',
      'rating': '8.1',
    });

    expect(model.nameEn, "Ocean's Eleven");
    expect(model.year, 2001);
    expect(
      model.description,
      'Дэнни Оушен собирает команду из одиннадцати профессионалов.',
    );
    expect(model.kinopoiskId, 526);
    expect(model.posterUrl, 'https://example.com/poster.jpg');
    expect(model.rating, '8.1');
  });

  test('переживает null во всех необязательных полях', () {
    final model = AiFilmRecommendationModel.fromJson(const {
      'nameEn': 'Unknown',
      'nameRu': null,
      'year': null,
      'reason': 'Нет описания',
      'kinopoiskId': null,
      'posterUrl': null,
      'rating': null,
    });

    final entity = model.toEntity();

    expect(entity.film.year, isNull);
    expect(entity.film.kinopoiskId, isNull);
    expect(entity.film.posterUrl, isNull);
    expect(entity.film.posterUrlPreview, isNull);
    expect(entity.film.ratingKinopoisk, isNull);
    expect(entity.description, 'Нет описания');
  });

  test('пустые/отсутствующие строки превращаются в пустую строку', () {
    final model = AiFilmRecommendationModel.fromJson(const {});

    expect(model.nameEn, '');
    expect(model.description, '');
    expect(model.toEntity().film.nameOriginal, '');
  });

  test('постер попадает и в posterUrl, и в posterUrlPreview', () {
    const url = 'https://example.com/poster.jpg';
    final entity = AiFilmRecommendationModel.fromJson(const {
      'nameEn': 'X',
      'nameRu': null,
      'reason': 'Y',
      'posterUrl': url,
    }).toEntity();

    expect(entity.film.posterUrl, url);
    expect(entity.film.posterUrlPreview, url);
  });

  test('целый рейтинг приводится к int, дробный остаётся num', () {
    final whole = AiFilmRecommendationModel.fromJson(const {
      'nameEn': 'A',
      'nameRu': null,
      'reason': 'B',
      'rating': '8.0',
    }).toEntity();
    final fractional = AiFilmRecommendationModel.fromJson(const {
      'nameEn': 'A',
      'nameRu': null,
      'reason': 'B',
      'rating': '7.9',
    }).toEntity();
    final commaSeparated = AiFilmRecommendationModel.fromJson(const {
      'nameEn': 'A',
      'nameRu': null,
      'reason': 'B',
      'rating': '7,9',
    }).toEntity();

    expect(whole.film.ratingKinopoisk, isA<int>());
    expect(whole.film.ratingKinopoisk, 8);
    expect(fractional.film.ratingKinopoisk, 7.9);
    expect(commaSeparated.film.ratingKinopoisk, 7.9);
  });

  test('нераспознанный рейтинг превращается в null', () {
    final entity = AiFilmRecommendationModel.fromJson(const {
      'title': 'A',
      'reason': 'B',
      'rating': '—',
    }).toEntity();

    expect(entity.film.ratingKinopoisk, isNull);
  });

  test('парсит жанры из массива объектов', () {
    final entity = AiFilmRecommendationModel.fromJson(const {
      'nameEn': 'A',
      'reason': 'B',
      'genres': [
        {'genre': 'комедия'},
        {'genre': 'драма'},
      ],
    }).toEntity();

    expect(entity.film.genres, <String>['комедия', 'драма']);
  });

  test('парсит жанры из массива строк и поля name', () {
    final strings = AiFilmRecommendationModel.fromJson(const {
      'nameEn': 'A',
      'reason': 'B',
      'genres': ['криминал', 'триллер'],
    }).toEntity();
    final names = AiFilmRecommendationModel.fromJson(const {
      'nameEn': 'A',
      'reason': 'B',
      'genres': [
        {'name': 'боевик'},
      ],
    }).toEntity();

    expect(strings.film.genres, <String>['криминал', 'триллер']);
    expect(names.film.genres, <String>['боевик']);
  });

  test('пропускает пустые жанры и отдаёт null, если жанров нет', () {
    final withEmpty = AiFilmRecommendationModel.fromJson(const {
      'nameEn': 'A',
      'reason': 'B',
      'genres': [
        {'genre': '  '},
        {'genre': ''},
        {'genre': 'комедия'},
        '  ',
      ],
    });
    final withoutGenres =
        AiFilmRecommendationModel.fromJson(const {'nameEn': 'A', 'reason': 'B'});

    expect(withEmpty.genres, <String>['комедия']);
    expect(withEmpty.toEntity().film.genres, <String>['комедия']);
    expect(withoutGenres.genres, isEmpty);
    expect(withoutGenres.toEntity().film.genres, isNull);
  });

  test('переживает genres неверного типа', () {
    final entity = AiFilmRecommendationModel.fromJson(const {
      'nameEn': 'A',
      'reason': 'B',
      'genres': 'комедия',
    }).toEntity();

    expect(entity.film.genres, isNull);
  });
}
