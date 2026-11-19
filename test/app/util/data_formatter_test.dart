import 'package:flutter_test/flutter_test.dart';
import 'package:movie_search_assistant_bloc/app/util/data_formatter.dart';

void main() {
  group('formatYearWithGenres', () {
    test('склеивает год и два жанра через разделитель', () {
      expect(
        DataFormatter.formatYearWithGenres(2001, <String>['криминал', 'комедия']),
        '2001 · Криминал, комедия',
      );
    });

    test('поднимает первую букву только у первого жанра', () {
      expect(
        DataFormatter.formatYearWithGenres(
          2006,
          <String>['боевик', 'триллер', 'детектив'],
        ),
        '2006 · Боевик, триллер',
      );
    });

    test('ограничивает количество жанров', () {
      expect(
        DataFormatter.formatYearWithGenres(
          2006,
          <String>['боевик', 'триллер'],
          genreLimit: 1,
        ),
        '2006 · Боевик',
      );
    });

    test('оставляет только год, если жанров нет', () {
      expect(DataFormatter.formatYearWithGenres(2001, null), '2001');
      expect(DataFormatter.formatYearWithGenres(2001, const <String>[]), '2001');
      expect(
        DataFormatter.formatYearWithGenres(2001, const <String>['', '  ']),
        '2001',
      );
    });

    test('оставляет только жанры, если года нет', () {
      expect(
        DataFormatter.formatYearWithGenres(null, <String>['аниме']),
        'Аниме',
      );
    });

    test('возвращает прочерк, если данных нет совсем', () {
      expect(DataFormatter.formatYearWithGenres(null, null), '-');
      expect(DataFormatter.formatYearWithGenres(null, const <String>[]), '-');
    });
  });

  group('formatRelativeDay', () {
    final DateTime now = DateTime(2026, 11, 14, 15, 38);

    test('сегодня и вчера называются словами', () {
      expect(
        DataFormatter.formatRelativeDay(DateTime(2026, 11, 14, 9), now: now),
        'Сегодня',
      );
      expect(
        DataFormatter.formatRelativeDay(DateTime(2026, 11, 13, 23, 59), now: now),
        'Вчера',
      );
    });

    test('другой день текущего года — день и месяц', () {
      expect(
        DataFormatter.formatRelativeDay(DateTime(2026, 11, 5, 12), now: now),
        '05.11',
      );
    });

    test('другой год добавляет год', () {
      expect(
        DataFormatter.formatRelativeDay(DateTime(2025, 11, 12, 12), now: now),
        '12.11.2025',
      );
    });
  });

  group('formatRelativeDayTime', () {
    final DateTime now = DateTime(2026, 11, 14, 18, 0);

    test('добавляет время к относительному дню', () {
      expect(
        DataFormatter.formatRelativeDayTime(
          DateTime(2026, 11, 14, 15, 38),
          now: now,
        ),
        'Сегодня, 15:38',
      );
      expect(
        DataFormatter.formatRelativeDayTime(
          DateTime(2026, 11, 13, 9, 5),
          now: now,
        ),
        'Вчера, 09:05',
      );
    });
  });

  group('formatBytes', () {
    test('неизвестный размер не притворяется нулём', () {
      expect(DataFormatter.formatBytes(null), 'неизвестно');
    });

    test('пусто и мелочь считаются в байтах', () {
      expect(DataFormatter.formatBytes(0), '0 Б');
      expect(DataFormatter.formatBytes(-1), '0 Б');
      expect(DataFormatter.formatBytes(999), '999 Б');
    });

    test('дальше идут десятичные КБ, МБ и ГБ', () {
      expect(DataFormatter.formatBytes(1000), '1 КБ');
      expect(DataFormatter.formatBytes(1234), '1.2 КБ');
      expect(DataFormatter.formatBytes(640000), '640 КБ');
      expect(DataFormatter.formatBytes(1000000), '1 МБ');
      expect(DataFormatter.formatBytes(12400000), '12.4 МБ');
      expect(DataFormatter.formatBytes(1500000000), '1.5 ГБ');
    });

    test('переход к следующей единице не показывает «1.0»', () {
      expect(DataFormatter.formatBytes(999950), '1 МБ');
      expect(DataFormatter.formatBytes(999999999), '1 ГБ');
    });
  });

  group('formatFilmWordDeclension', () {
    test('склоняет слово «фильм»', () {
      expect(DataFormatter.formatFilmWordDeclension(1), '1 фильм');
      expect(DataFormatter.formatFilmWordDeclension(2), '2 фильма');
      expect(DataFormatter.formatFilmWordDeclension(5), '5 фильмов');
      expect(DataFormatter.formatFilmWordDeclension(11), '11 фильмов');
      expect(DataFormatter.formatFilmWordDeclension(21), '21 фильм');
    });
  });
}
