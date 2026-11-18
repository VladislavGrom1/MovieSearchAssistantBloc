import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:movie_search_assistant_bloc/data/models/ai_session_model.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_session.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('ai_sessions_test');
    Hive.init(tempDir.path);
    Hive.registerAdapter(AiSessionModelAdapter());
    Hive.registerAdapter(AiSessionTurnModelAdapter());
    Hive.registerAdapter(AiFilmSnapshotModelAdapter());
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  AiSessionModel buildSession({int id = 1700000000, String? posterPath}) {
    return AiSessionModel(
      id: id,
      createdAt: DateTime(2026, 11, 14, 15, 30),
      updatedAt: DateTime(2026, 11, 14, 15, 31),
      turns: <AiSessionTurnModel>[
        AiSessionTurnModel(
          id: id,
          query: 'фильм про ограбление казино',
          onlyNew: true,
          createdAt: DateTime(2026, 11, 14, 15, 30),
          status: AiSessionTurnModelStatus.loaded,
          films: <AiFilmSnapshotModel>[
            AiFilmSnapshotModel(
              kinopoiskId: 472,
              nameRu: 'Одиннадцать друзей Оушена',
              nameOriginal: 'Ocean s Eleven',
              year: 2001,
              genres: const <String>['криминал', 'комедия'],
              ratingKinopoisk: 7.8,
              posterPath: posterPath,
              description: 'Команда мастеров готовит ограбление трёх казино.',
            ),
          ],
        ),
      ],
    );
  }

  test('stores and reads a session with its turn and film snapshot', () async {
    final box = await Hive.openBox<AiSessionModel>('aiSessionModelBox');
    final model = buildSession(posterPath: '1700000000/472/poster.jpg');

    await box.put(model.id, model);

    final stored = box.get(model.id)!;

    expect(stored.id, 1700000000);
    expect(stored.schemaVersion, AiSessionModel.currentSchemaVersion);
    expect(stored.createdAt, DateTime(2026, 11, 14, 15, 30));
    expect(stored.updatedAt, DateTime(2026, 11, 14, 15, 31));

    final turn = stored.turns.single;

    expect(turn.query, 'фильм про ограбление казино');
    expect(turn.onlyNew, isTrue);
    expect(turn.status, AiSessionTurnModelStatus.loaded);

    final snapshot = turn.films.single;

    expect(snapshot.kinopoiskId, 472);
    expect(snapshot.nameRu, 'Одиннадцать друзей Оушена');
    expect(snapshot.nameOriginal, 'Ocean s Eleven');
    expect(snapshot.year, 2001);
    expect(snapshot.genres, const <String>['криминал', 'комедия']);
    expect(snapshot.ratingKinopoisk, 7.8);
    expect(snapshot.posterPath, '1700000000/472/poster.jpg');
    expect(snapshot.description,
        'Команда мастеров готовит ограбление трёх казино.');

    await box.close();
  });

  test('maps a stored record back to domain entities', () async {
    final box = await Hive.openBox<AiSessionModel>('aiSessionModelBox');

    await box.put(1, buildSession(id: 1, posterPath: '1/472/poster.jpg'));

    final entity = box.get(1)!.toEntity();

    expect(entity.id, 1);
    expect(entity.turns, hasLength(1));
    expect(entity.lastTurn?.search.query, 'фильм про ограбление казино');
    expect(entity.lastTurn?.search.onlyNew, isTrue);
    expect(entity.lastTurn?.status, AiSessionTurnStatus.loaded);
    expect(entity.lastTurn?.films.single.film.kinopoiskId, 472);
    expect(
      entity.lastTurn?.films.single.film.localPosterImagePath,
      '1/472/poster.jpg',
    );
    expect(
      entity.lastTurn?.films.single.description,
      'Команда мастеров готовит ограбление трёх казино.',
    );

    await box.close();
  });

  test('keeps an empty turn and a missing poster path', () async {
    final box = await Hive.openBox<AiSessionModel>('aiSessionModelBox');
    final model = AiSessionModel(
      id: 2,
      createdAt: DateTime(2026, 11, 14),
      updatedAt: DateTime(2026, 11, 14),
      turns: <AiSessionTurnModel>[
        AiSessionTurnModel(
          id: 2,
          query: 'аниме про путешествия',
          onlyNew: false,
          createdAt: DateTime(2026, 11, 14),
          status: AiSessionTurnModelStatus.empty,
          films: const <AiFilmSnapshotModel>[],
        ),
      ],
    );

    await box.put(model.id, model);

    final entity = box.get(2)!.toEntity();

    expect(entity.lastTurn?.status, AiSessionTurnStatus.empty);
    expect(entity.lastTurn?.films, isEmpty);

    await box.close();
  });
}
