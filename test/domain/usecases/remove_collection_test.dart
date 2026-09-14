import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/local/image_storage_service.dart';
import 'package:movie_search_assistant_bloc/data/models/film_collection_link.dart';
import 'package:movie_search_assistant_bloc/domain/repository/collection_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_collection_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/remove_collection_use_case.dart';

class MockCollectionRepository extends Mock implements CollectionRepository {}

class MockImageStorageService extends Mock implements ImageStorageService {}

class MockFilmRepository extends Mock implements FilmRepository {}

class MockFilmCollectionRepository extends Mock implements FilmCollectionRepository {}

void main() {
  late MockCollectionRepository collectionRepository;
  late MockImageStorageService imageStorageService;
  late MockFilmRepository filmRepository;
  late MockFilmCollectionRepository filmCollectionRepository;
  late RemoveCollectionUseCase useCase;

  const collectionIdToRemove = 'collection-1';
  const otherCollectionId = 'collection-2';

  setUp(() {
    collectionRepository = MockCollectionRepository();
    imageStorageService = MockImageStorageService();
    filmRepository = MockFilmRepository();
    filmCollectionRepository = MockFilmCollectionRepository();

    useCase = RemoveCollectionUseCase(
      collectionRepository: collectionRepository,
      imageStorageService: imageStorageService,
      filmRepository: filmRepository,
      filmCollectionRepository: filmCollectionRepository,
    );

    when(() => filmCollectionRepository.removeAllLinksByCollectionId(any()))
        .thenAnswer((_) async {});
    when(() => collectionRepository.removeCollection(any())).thenAnswer((_) async {});
    when(() => imageStorageService.deleteFilmImages(any())).thenAnswer((_) async {});
    when(() => filmRepository.removeFilmFromLocalDataSource(any())).thenAnswer((_) async {});
  });

  test('removes the collection and its links from the repositories', () async {
    when(() => filmCollectionRepository.getAllFilmCollectionLinks()).thenAnswer((_) async => []);

    await useCase.call(collectionIdToRemove);

    verify(() => filmCollectionRepository.removeAllLinksByCollectionId(collectionIdToRemove)).called(1);
    verify(() => collectionRepository.removeCollection(collectionIdToRemove)).called(1);
  });

  test('deletes films that only belonged to the removed collection', () async {
    when(() => filmCollectionRepository.getAllFilmCollectionLinks()).thenAnswer((_) async => [
          const FilmCollectionLink(filmId: 100, collectionId: collectionIdToRemove),
        ]);

    await useCase.call(collectionIdToRemove);

    verify(() => imageStorageService.deleteFilmImages(100)).called(1);
    verify(() => filmRepository.removeFilmFromLocalDataSource(100)).called(1);
  });

  test('keeps films that also belong to another collection', () async {
    when(() => filmCollectionRepository.getAllFilmCollectionLinks()).thenAnswer((_) async => [
          const FilmCollectionLink(filmId: 100, collectionId: collectionIdToRemove),
          const FilmCollectionLink(filmId: 100, collectionId: otherCollectionId),
        ]);

    await useCase.call(collectionIdToRemove);

    verifyNever(() => imageStorageService.deleteFilmImages(100));
    verifyNever(() => filmRepository.removeFilmFromLocalDataSource(100));
  });

  test('handles a mix of shared and exclusive films correctly', () async {
    when(() => filmCollectionRepository.getAllFilmCollectionLinks()).thenAnswer((_) async => [
          const FilmCollectionLink(filmId: 1, collectionId: collectionIdToRemove),
          const FilmCollectionLink(filmId: 2, collectionId: collectionIdToRemove),
          const FilmCollectionLink(filmId: 2, collectionId: otherCollectionId),
        ]);

    await useCase.call(collectionIdToRemove);

    // Film 1 only existed in the removed collection -> should be deleted.
    verify(() => imageStorageService.deleteFilmImages(1)).called(1);
    verify(() => filmRepository.removeFilmFromLocalDataSource(1)).called(1);

    // Film 2 is shared with another collection -> must be kept.
    verifyNever(() => imageStorageService.deleteFilmImages(2));
    verifyNever(() => filmRepository.removeFilmFromLocalDataSource(2));
  });

  test('does nothing to films when the collection is already empty', () async {
    when(() => filmCollectionRepository.getAllFilmCollectionLinks()).thenAnswer((_) async => [
          const FilmCollectionLink(filmId: 5, collectionId: otherCollectionId),
        ]);

    await useCase.call(collectionIdToRemove);

    verifyNever(() => imageStorageService.deleteFilmImages(any()));
    verifyNever(() => filmRepository.removeFilmFromLocalDataSource(any()));
  });
}