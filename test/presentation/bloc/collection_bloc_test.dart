import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/add_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/clear_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_collections_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/remove_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/remove_image_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/rename_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/upload_image_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/watch_collections_use_case.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/collections/collections_bloc.dart';

class MockGetCollectionsUseCase extends Mock implements GetCollectionsUseCase {}

class MockAddCollectionUseCase extends Mock implements AddCollectionUseCase {}

class MockRemoveCollectionUseCase extends Mock implements RemoveCollectionUseCase {}

class MockWatchCollectionsUseCase extends Mock implements WatchCollectionsUseCase {}

class MockClearCollectionUseCase extends Mock implements ClearCollectionUseCase {}

class MockRenameCollectionUseCase extends Mock implements RenameCollectionUseCase {}

class MockUploadImageCollectionUseCase extends Mock implements UploadImageCollectionUseCase {}

class MockRemoveImageCollectionUseCase extends Mock implements RemoveImageCollectionUseCase {}

void main() {
  late MockGetCollectionsUseCase getCollectionsUseCase;
  late MockAddCollectionUseCase addCollectionUseCase;
  late MockRemoveCollectionUseCase removeCollectionUseCase;
  late MockWatchCollectionsUseCase watchCollectionsUseCase;
  late MockClearCollectionUseCase clearCollectionUseCase;
  late MockRenameCollectionUseCase renameCollectionUseCase;
  late MockUploadImageCollectionUseCase uploadImageCollectionUseCase;
  late MockRemoveImageCollectionUseCase removeImageCollectionUseCase;

  const collectionA = CollectionEntity(id: '1', name: 'Избранное', filmCount: 3);

  setUpAll(() {
    registerFallbackValue(collectionA);
  });

  setUp(() {
    getCollectionsUseCase = MockGetCollectionsUseCase();
    addCollectionUseCase = MockAddCollectionUseCase();
    removeCollectionUseCase = MockRemoveCollectionUseCase();
    watchCollectionsUseCase = MockWatchCollectionsUseCase();
    clearCollectionUseCase = MockClearCollectionUseCase();
    renameCollectionUseCase = MockRenameCollectionUseCase();
    uploadImageCollectionUseCase = MockUploadImageCollectionUseCase();
    removeImageCollectionUseCase = MockRemoveImageCollectionUseCase();
  });

  CollectionsBloc buildBloc() => CollectionsBloc(
        getCollectionsUseCase: getCollectionsUseCase,
        addCollectionUseCase: addCollectionUseCase,
        removeCollectionUseCase: removeCollectionUseCase,
        watchCollectionsUseCase: watchCollectionsUseCase,
        clearCollectionUseCase: clearCollectionUseCase,
        renameCollectionUseCase: renameCollectionUseCase,
        uploadImageCollectionUseCase: uploadImageCollectionUseCase,
        removeImageCollectionUseCase: removeImageCollectionUseCase,
      );

  test('initial state is CollectionsInitial', () {
    when(() => watchCollectionsUseCase.call()).thenAnswer((_) => const Stream.empty());
    expect(buildBloc().state, isA<CollectionsInitial>());
  });

  blocTest<CollectionsBloc, CollectionsState>(
    'emits [Loading, Loaded] when the watched stream produces collections',
    build: () {
      when(() => watchCollectionsUseCase.call())
          .thenAnswer((_) => Stream.value([collectionA]));
      return buildBloc();
    },
    act: (bloc) => bloc.add(GetCollections()),
    expect: () => [
      isA<CollectionsLoading>(),
      isA<CollectionsLoaded>()
          .having((s) => s.collections, 'collections', [collectionA]),
    ],
  );

  blocTest<CollectionsBloc, CollectionsState>(
    'emits Failure when starting the watch throws a LocalDataSourceException',
    build: () {
      when(() => watchCollectionsUseCase.call())
          .thenThrow(LocalDataSourceException(message: 'hive error'));
      return buildBloc();
    },
    act: (bloc) => bloc.add(GetCollections()),
    expect: () => [
      isA<CollectionsLoading>(),
      isA<CollectionsFailure>().having((s) => s.message, 'message', 'hive error'),
    ],
  );

  blocTest<CollectionsBloc, CollectionsState>(
    'emits Failure when addCollectionUseCase throws',
    build: () {
      when(() => watchCollectionsUseCase.call()).thenAnswer((_) => const Stream.empty());
      when(() => addCollectionUseCase.call(any()))
          .thenThrow(LocalDataSourceException(message: 'cannot add'));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const AddNewCollection(collectionName: 'New')),
    expect: () => [
      isA<CollectionsFailure>().having((s) => s.message, 'message', 'cannot add'),
    ],
  );

  blocTest<CollectionsBloc, CollectionsState>(
    'calls addCollectionUseCase with the given collection name and stays silent on success',
    build: () {
      when(() => watchCollectionsUseCase.call()).thenAnswer((_) => const Stream.empty());
      when(() => addCollectionUseCase.call(any())).thenAnswer((_) async {});
      return buildBloc();
    },
    act: (bloc) => bloc.add(const AddNewCollection(collectionName: 'New')),
    expect: () => [],
    verify: (_) {
      verify(() => addCollectionUseCase.call('New')).called(1);
    },
  );

  blocTest<CollectionsBloc, CollectionsState>(
    'calls removeCollectionUseCase with the given id',
    build: () {
      when(() => watchCollectionsUseCase.call()).thenAnswer((_) => const Stream.empty());
      when(() => removeCollectionUseCase.call(any())).thenAnswer((_) async {});
      return buildBloc();
    },
    act: (bloc) => bloc.add(const RemoveCollection(collectionId: '1')),
    verify: (_) {
      verify(() => removeCollectionUseCase.call('1')).called(1);
    },
  );

  blocTest<CollectionsBloc, CollectionsState>(
    'emits Failure when clearCollectionUseCase throws',
    build: () {
      when(() => watchCollectionsUseCase.call()).thenAnswer((_) => const Stream.empty());
      when(() => clearCollectionUseCase.call(any()))
          .thenThrow(LocalDataSourceException(message: 'clear failed'));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const ClearCollection(collectionId: '1')),
    expect: () => [
      isA<CollectionsFailure>().having((s) => s.message, 'message', 'clear failed'),
    ],
  );

  blocTest<CollectionsBloc, CollectionsState>(
    'UpdateCollections directly emits CollectionsLoaded with the provided list',
    build: () {
      when(() => watchCollectionsUseCase.call()).thenAnswer((_) => const Stream.empty());
      return buildBloc();
    },
    act: (bloc) => bloc.add(const UpdateCollections(updatedCollections: [collectionA])),
    expect: () => [
      isA<CollectionsLoaded>().having((s) => s.collections, 'collections', [collectionA]),
    ],
  );

  test('cancels the previous subscription when GetCollections is dispatched again', () async {
    final controllerA = StreamController<List<CollectionEntity>>.broadcast();
    final controllerB = StreamController<List<CollectionEntity>>.broadcast();
    addTearDown(controllerA.close);
    addTearDown(controllerB.close);

    var callCount = 0;
    when(() => watchCollectionsUseCase.call()).thenAnswer((_) {
      callCount++;
      return callCount == 1 ? controllerA.stream : controllerB.stream;
    });

    final bloc = buildBloc();
    addTearDown(bloc.close);

    bloc.add(GetCollections());
    await Future<void>.delayed(Duration.zero);

    bloc.add(GetCollections());
    await Future<void>.delayed(Duration.zero);

    controllerA.add([collectionA]);
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state, isA<CollectionsLoading>());

    const collectionB = CollectionEntity(id: '2', name: 'Фантастика');
    controllerB.add([collectionB]);
    await Future<void>.delayed(Duration.zero);

    expect(
      bloc.state,
      isA<CollectionsLoaded>().having((s) => s.collections, 'collections', [collectionB]),
    );
  });
}