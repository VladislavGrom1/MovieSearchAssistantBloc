
import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/add_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_collections_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/remove_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/watch_collections_use_case.dart';

part 'collections_event.dart';
part 'collections_state.dart';

class CollectionsBloc extends Bloc<CollectionsEvent, CollectionsState> {
  final GetCollectionsUseCase getCollectionsUseCase;
  final AddCollectionUseCase addCollectionUseCase;
  final RemoveCollectionUseCase removeCollectionUseCase;
  final WatchCollectionsUseCase watchCollectionsUseCase;
  late StreamSubscription _savedCollectionsSubscription;

  CollectionsBloc({
    required this.getCollectionsUseCase,
    required this.addCollectionUseCase,
    required this.removeCollectionUseCase,
    required this.watchCollectionsUseCase
  }) : super(CollectionsInitial()) {
    on<GetCollections>(_getCollections);
    on<AddNewCollection>(_addNewCollection);
    on<RemoveCollection>(_removeCollection);
    on<UpdateCollections>(_updateCollections);

    _savedCollectionsSubscription = watchCollectionsUseCase.call().listen(
      (updatedCollections) => add(UpdateCollections(updatedCollections: updatedCollections))
    );
  }
 
  Future<void> _getCollections(GetCollections event, Emitter emit) async {
    emit(CollectionsLoading());
    try{
      List<CollectionEntity>? collections = await getCollectionsUseCase.call();
      if(collections != null){
        emit(CollectionsLoaded(collections: collections));
      } else{
        emit(CollectionsFailure(exceptionType: "Нет коллекций"));
      }
    } on LocalDataSourceException catch(e) {
      emit(CollectionsFailure(exceptionType: e.message));
    } catch(e){
      emit(CollectionsFailure(exceptionType: e.toString()));
    }
  }

  Future<void> _addNewCollection(AddNewCollection event, Emitter emit) async {
    final currentState = state;
    if(currentState is! CollectionsLoaded) return;
    try{
      final newCollection = await addCollectionUseCase.call(event.collectionName);
      final updatedCollections = [...currentState.collections, newCollection];
      emit(CollectionAddedSuccess(collections: updatedCollections, message: "Коллекция успешно создана"));
      emit(CollectionsLoaded(collections: updatedCollections));
    } on LocalDataSourceException catch(e){
      emit(CollectionActionFailure(collections: currentState.collections, message: e.message));
      emit(currentState);
    } catch(e){
      emit(CollectionActionFailure(collections: currentState.collections, message: "Не удалось создать коллекцию"));
      emit(currentState);
    }
  }

  Future<void> _removeCollection(RemoveCollection event, Emitter emit) async {
    final currentState = state;
    if(currentState is! CollectionsLoaded) return;
    try{
      await removeCollectionUseCase.call(event.collectionId);
      final updatedCollections = currentState.collections.where((c) => c.id != event.collectionId).toList();
      emit(CollectionRemovedSuccess(collections: updatedCollections, message: "Коллекция успешно удалена"));
      emit(CollectionsLoaded(collections: updatedCollections));
    } on LocalDataSourceException catch(e){
      emit(CollectionActionFailure(collections: currentState.collections, message: e.toString()));
      emit(currentState);
    } catch(e){
      emit(CollectionActionFailure(collections: currentState.collections, message: "Не удалось удалить коллекцию"));
      emit(currentState);
    }
  }

  Future<void> _updateCollections(UpdateCollections event, Emitter emit) async {
    final currentState = state;
    if(currentState is! CollectionsLoaded) return;
    try{
      final updatedCollections = event.updatedCollections;
      emit(CollectionsLoaded(collections: updatedCollections));
    } on LocalDataSourceException catch(e){
      emit(CollectionActionFailure(collections: currentState.collections, message: e.toString()));
      emit(currentState);
    } catch(e){
      emit(CollectionActionFailure(collections: currentState.collections, message: "Не удалось обновить коллекции"));
      emit(currentState);
    }
  }

  @override
  Future<void> close() {
    _savedCollectionsSubscription.cancel();
    return super.close();
  }
}
