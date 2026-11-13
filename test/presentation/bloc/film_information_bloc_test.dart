import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_images_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/add_film_to_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_film_images_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_film_information_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_saved_film_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/open_url_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/remove_film_from_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/update_saved_film_from_server_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/update_user_film_information_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/watch_film_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/watch_links_by_film_use_case.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/film_information/film_information_bloc.dart';

class MockGetFilmInformationUseCase extends Mock
    implements GetFilmInformationUseCase {}

class MockGetSavedFilmUseCase extends Mock implements GetSavedFilmUseCase {}

class MockGetFilmImagesUseCase extends Mock
    implements GetFilmImagesUseCase {}

class MockAddFilmToCollectionUseCase extends Mock
    implements AddFilmToCollectionUseCase {}

class MockUpdateSavedFilmFromServerUseCase extends Mock
    implements UpdateSavedFilmFromServerUseCase {}

class MockUpdateUserFilmInformationUseCase extends Mock
    implements UpdateUserFilmInformationUseCase {}

class MockRemoveFilmFromCollectionUseCase extends Mock
    implements RemoveFilmFromCollectionUseCase {}

class MockWatchLinksByFilmUseCase extends Mock
    implements WatchLinksByFilmUseCase {}

class MockWatchFilmUseCase extends Mock implements WatchFilmUseCase {}

class MockOpenUrlUseCase extends Mock implements OpenUrlUseCase {}

void main() {
  late MockGetFilmInformationUseCase getFilmInformationUseCase;
  late MockGetSavedFilmUseCase getSavedFilmUseCase;
  late MockGetFilmImagesUseCase getFilmImagesUseCase;
  late MockAddFilmToCollectionUseCase addFilmToCollectionUseCase;
  late MockUpdateSavedFilmFromServerUseCase updateSavedFilmFromServerUseCase;
  late MockUpdateUserFilmInformationUseCase updateUserFilmInformationUseCase;
  late MockRemoveFilmFromCollectionUseCase removeFilmFromCollectionUseCase;
  late MockWatchLinksByFilmUseCase watchLinksByFilmUseCase;
  late MockWatchFilmUseCase watchFilmUseCase;
  late MockOpenUrlUseCase openUrlUseCase;

  setUpAll(() {
    registerFallbackValue(1);
    registerFallbackValue(const FilmEntity(kinopoiskId: 1));
  });

  setUp(() {
    getFilmInformationUseCase = MockGetFilmInformationUseCase();
    getSavedFilmUseCase = MockGetSavedFilmUseCase();
    getFilmImagesUseCase = MockGetFilmImagesUseCase();
    addFilmToCollectionUseCase = MockAddFilmToCollectionUseCase();
    updateSavedFilmFromServerUseCase = MockUpdateSavedFilmFromServerUseCase();
    updateUserFilmInformationUseCase = MockUpdateUserFilmInformationUseCase();
    removeFilmFromCollectionUseCase = MockRemoveFilmFromCollectionUseCase();
    watchLinksByFilmUseCase = MockWatchLinksByFilmUseCase();
    watchFilmUseCase = MockWatchFilmUseCase();
    openUrlUseCase = MockOpenUrlUseCase();
  });

  FilmInformationBloc buildBloc() => FilmInformationBloc(
        getFilmInformationUseCase: getFilmInformationUseCase,
        getSavedFilmUseCase: getSavedFilmUseCase,
        getFilmImagesUseCase: getFilmImagesUseCase,
        addFilmToCollectionUseCase: addFilmToCollectionUseCase,
        updateSavedFilmFromServerUseCase: updateSavedFilmFromServerUseCase,
        updateUserFilmInformationUseCase: updateUserFilmInformationUseCase,
        removeFilmFromCollectionUseCase: removeFilmFromCollectionUseCase,
        watchLinksByFilmUseCase: watchLinksByFilmUseCase,
        watchFilmUseCase: watchFilmUseCase,
        openUrlUseCase: openUrlUseCase,
      );

  test(
    'closing the bloc while the film is loading does not add events to the '
    'closed bloc',
    () async {
      const film = FilmEntity(kinopoiskId: 1);
      final imagesRequested = Completer<void>();
      final images = Completer<FilmImagesEntity?>();
      final collectionIds = StreamController<List<String>>.broadcast();
      final watchedFilm = StreamController<FilmEntity?>.broadcast();
      final zoneErrors = <Object>[];

      when(() => getSavedFilmUseCase.call(any()))
          .thenAnswer((_) async => (null, <String>[]));
      when(() => getFilmInformationUseCase.call(any()))
          .thenAnswer((_) async => (film, <String>[]));
      when(() => getFilmImagesUseCase.call(any())).thenAnswer((_) {
        imagesRequested.complete();
        return images.future;
      });
      when(() => watchLinksByFilmUseCase.call(any()))
          .thenAnswer((_) => collectionIds.stream);
      when(() => watchFilmUseCase.call(any()))
          .thenAnswer((_) => watchedFilm.stream);

      late FilmInformationBloc bloc;
      runZonedGuarded(() {
        bloc = buildBloc();
        bloc.add(const GetFilmInformation(idFilm: 1));
      }, (error, stackTrace) => zoneErrors.add(error));

      // The screen is popped while the request is still in flight: the route
      // disposes the BlocProvider and closes the bloc.
      await imagesRequested.future;
      final closed = bloc.close();
      images.complete(null);
      await closed;

      // The Hive watch stream now delivers the collection ids of the film.
      collectionIds.add(const ['collection-1']);
      await Future<void>.delayed(Duration.zero);

      expect(
        zoneErrors,
        isEmpty,
        reason: 'the bloc must not add events after close',
      );
      expect(
        collectionIds.hasListener,
        isFalse,
        reason: '_subscribe must not listen on the watch stream after close',
      );

      await collectionIds.close();
      await watchedFilm.close();
    },
  );

  test('applies collection links and saved film updates after loading', () async {
    const film = FilmEntity(kinopoiskId: 1);
    final watchStarted = Completer<void>();
    final collectionIds = StreamController<List<String>>.broadcast(
      onListen: () {
        if (!watchStarted.isCompleted) watchStarted.complete();
      },
    );
    final watchedFilm = StreamController<FilmEntity?>.broadcast();

    when(() => getSavedFilmUseCase.call(any()))
        .thenAnswer((_) async => (null, <String>[]));
    when(() => getFilmInformationUseCase.call(any()))
        .thenAnswer((_) async => (film, <String>[]));
    when(() => getFilmImagesUseCase.call(any())).thenAnswer((_) async => null);
    when(() => watchLinksByFilmUseCase.call(any()))
        .thenAnswer((_) => collectionIds.stream);
    when(() => watchFilmUseCase.call(any()))
        .thenAnswer((_) => watchedFilm.stream);

    final bloc = buildBloc();
    addTearDown(bloc.close);
    addTearDown(collectionIds.close);
    addTearDown(watchedFilm.close);

    final loaded = bloc.stream.firstWhere((state) => state is FilmLoaded);
    bloc.add(const GetFilmInformation(idFilm: 1));
    expect(await loaded, isA<FilmLoaded>());
    await watchStarted.future;

    final linksApplied = bloc.stream.firstWhere(
      (state) => state is FilmLoaded && state.collectionIds.contains('collection-1'),
    );
    collectionIds.add(const ['collection-1']);
    expect((await linksApplied as FilmLoaded).collectionIds, ['collection-1']);

    final filmApplied = bloc.stream.firstWhere(
      (state) => state is FilmLoaded && state.film.nameRu == 'Обновлённое название',
    );
    watchedFilm.add(
      const FilmEntity(kinopoiskId: 1, nameRu: 'Обновлённое название'),
    );
    expect(
      (await filmApplied as FilmLoaded).film.nameRu,
      'Обновлённое название',
    );
  });
}
