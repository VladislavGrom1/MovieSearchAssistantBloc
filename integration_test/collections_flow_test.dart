import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/local/image_storage_service.dart';
import 'package:movie_search_assistant_bloc/data/models/collection_model.dart';
import 'package:movie_search_assistant_bloc/data/models/film_collection_link.dart';
import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/collection_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_collection_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/add_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/clear_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_collections_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/remove_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/remove_image_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/rename_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/upload_image_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/watch_collections_use_case.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/collections/collections_bloc.dart';
import 'package:rxdart/rxdart.dart';

class FakeCollectionRepository implements CollectionRepository {
  final Map<String, CollectionModel> _store = {};
  final _controller = BehaviorSubject<List<CollectionEntity>>.seeded(const []);

  void _emit() {
    _controller.add(_store.values
        .map((m) => CollectionEntity(
              id: m.id,
              name: m.name,
              createdAt: m.createdAt,
              filmCount: 0,
              imagePath: m.imagePath,
            ))
        .toList());
  }

  @override
  Stream<List<CollectionEntity>> watchCollections() => _controller.stream;

  @override
  Future<void> addCollection(CollectionModel collection) async {
    _store[collection.id!] = collection;
    _emit();
  }

  @override
  Future<List<CollectionEntity>> getAllCollections() async {
    return _store.values
        .map((m) => CollectionEntity(id: m.id, name: m.name, createdAt: m.createdAt, imagePath: m.imagePath))
        .toList();
  }

  @override
  Future<void> removeCollection(String collectionId) async {
    _store.remove(collectionId);
    _emit();
  }

  @override
  Future<void> removeAllCollection() async {
    _store.clear();
    _emit();
  }

  @override
  Future<bool> collectionIsExist(String collectionId) async => _store.containsKey(collectionId);

  @override
  Future<void> updateCollection(CollectionEntity collection) async {
    _store[collection.id!] = CollectionModel.fromCollectionEntity(collection);
    _emit();
  }

  Future<void> dispose() => _controller.close();
}

class FakeFilmCollectionRepository implements FilmCollectionRepository {
  final List<FilmCollectionLink> _links = [];
  final _controller = BehaviorSubject<List<FilmCollectionLink>>.seeded(const []);

  @override
  Stream<List<FilmCollectionLink>> watchLinks() => _controller.stream;

  @override
  Stream<List<int>> watchLinksByCollectionId(String collectionId) {
    return _controller.stream.map(
      (links) => links.where((l) => l.collectionId == collectionId).map((l) => l.filmId).toList(),
    );
  }

  @override
  Stream<List<String>> watchLinksByFilmId(int filmId) {
    return _controller.stream.map(
      (links) => links.where((l) => l.filmId == filmId).map((l) => l.collectionId).toList(),
    );
  }

  @override
  Future<void> addFilmCollectionLink(FilmCollectionLink filmCollectionLink) async {
    _links.add(filmCollectionLink);
    _controller.add(List.of(_links));
  }

  @override
  Future<void> removeFilmCollectionLink(FilmCollectionLink filmCollectionLink) async {
    _links.removeWhere((l) => l.filmId == filmCollectionLink.filmId && l.collectionId == filmCollectionLink.collectionId);
    _controller.add(List.of(_links));
  }

  @override
  Future<void> removeAllLinksByCollectionId(String collectionId) async {
    _links.removeWhere((l) => l.collectionId == collectionId);
    _controller.add(List.of(_links));
  }

  @override
  Future<void> removeAllLinks() async {
    _links.clear();
    _controller.add(const []);
  }

  @override
  Future<List<FilmCollectionLink>> getAllFilmCollectionLinks() async => List.of(_links);

  @override
  Future<List<int>> getFilmIdsByCollectionId(String collectionId) async =>
      _links.where((l) => l.collectionId == collectionId).map((l) => l.filmId).toList();

  @override
  Future<List<String>> getCollectionIdsByFilmId(int filmId) async =>
      _links.where((l) => l.filmId == filmId).map((l) => l.collectionId).toList();

  Future<void> dispose() => _controller.close();
}

class MockFilmRepository extends Mock implements FilmRepository {}

class MockImageStorageService extends Mock implements ImageStorageService {}

void main() {
  late FakeCollectionRepository collectionRepository;
  late FakeFilmCollectionRepository filmCollectionRepository;
  late MockFilmRepository filmRepository;
  late MockImageStorageService imageStorageService;
  late CollectionsBloc bloc;

  setUp(() {
    collectionRepository = FakeCollectionRepository();
    filmCollectionRepository = FakeFilmCollectionRepository();
    filmRepository = MockFilmRepository();
    imageStorageService = MockImageStorageService();

    bloc = CollectionsBloc(
      getCollectionsUseCase: GetCollectionsUseCase(collectionRepository: collectionRepository),
      addCollectionUseCase: AddCollectionUseCase(collectionRepository: collectionRepository),
      removeCollectionUseCase: RemoveCollectionUseCase(
        collectionRepository: collectionRepository,
        imageStorageService: imageStorageService,
        filmRepository: filmRepository,
        filmCollectionRepository: filmCollectionRepository,
      ),
      watchCollectionsUseCase: WatchCollectionsUseCase(
        collectionRepository: collectionRepository,
        filmCollectionRepository: filmCollectionRepository,
      ),
      clearCollectionUseCase: ClearCollectionUseCase(
        imageStorageService: imageStorageService,
        filmRepository: filmRepository,
        filmCollectionRepository: filmCollectionRepository,
      ),
      renameCollectionUseCase: RenameCollectionUseCase(collectionRepository: collectionRepository),
      uploadImageCollectionUseCase: UploadImageCollectionUseCase(
        collectionRepository: collectionRepository,
        imageStorageService: imageStorageService,
      ),
      removeImageCollectionUseCase: RemoveImageCollectionUseCase(
        collectionRepository: collectionRepository,
        imageStorageService: imageStorageService,
      ),
    );
  });

  tearDown(() async {
    await bloc.close();
    await collectionRepository.dispose();
    await filmCollectionRepository.dispose();
  });

  test('starting the watch on an empty store loads an empty collection list', () async {
    bloc.add(GetCollections());

    await expectLater(
      bloc.stream,
      emitsInOrder([
        isA<CollectionsLoading>(),
        isA<CollectionsLoaded>().having((s) => s.collections, 'collections', isEmpty),
      ]),
    );
  });

  test('adding a collection is reflected through the watch stream as CollectionsLoaded', () async {
    bloc.add(GetCollections());
    await Future<void>.delayed(Duration.zero);

    final states = <CollectionsState>[];
    final sub = bloc.stream.listen(states.add);

    bloc.add(const AddNewCollection(collectionName: 'Ужасы'));
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final loaded = states.whereType<CollectionsLoaded>().last;
    expect(loaded.collections, hasLength(1));
    expect(loaded.collections.first.name, 'Ужасы');

    await sub.cancel();
  });

  test('renaming a collection updates the name observed through the stream', () async {
    bloc.add(GetCollections());
    bloc.add(const AddNewCollection(collectionName: 'Ужасы'));
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final created = (await collectionRepository.getAllCollections()).first;

    final states = <CollectionsState>[];
    final sub = bloc.stream.listen(states.add);

    bloc.add(RenameCollection(collection: created, updatedName: 'Хорроры'));
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final loaded = states.whereType<CollectionsLoaded>().last;
    expect(loaded.collections.first.name, 'Хорроры');

    await sub.cancel();
  });

  test('removing a collection empties it out again through the stream', () async {
    bloc.add(GetCollections());
    bloc.add(const AddNewCollection(collectionName: 'Ужасы'));
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final created = (await collectionRepository.getAllCollections()).first;

    final states = <CollectionsState>[];
    final sub = bloc.stream.listen(states.add);

    bloc.add(RemoveCollection(collectionId: created.id!));
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final loaded = states.whereType<CollectionsLoaded>().last;
    expect(loaded.collections, isEmpty);

    await sub.cancel();
  });
}