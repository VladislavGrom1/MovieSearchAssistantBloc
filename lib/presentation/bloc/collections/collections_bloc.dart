
import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/add_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_collections_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/remove_collection_use_case.dart';

part 'collections_event.dart';
part 'collections_state.dart';

class CollectionsBloc extends Bloc<CollectionsEvent, CollectionsState> {
  final GetCollectionsUseCase getCollectionsUseCase;
  final AddCollectionUseCase addCollectionUseCase;
  final RemoveCollectionUseCase removeCollectionUseCase;

  CollectionsBloc({
    required this.getCollectionsUseCase,
    required this.addCollectionUseCase,
    required this.removeCollectionUseCase,
  }) : super(CollectionsInitial()) {
    on<DisplayCollections>(_displayCollections);
    on<AddNewCollection>(_addNewCollection);
    on<RemoveCollection>(_removeCollection);
    on<UpdateCollection>(_updateCollection);
  }
 
  Future<void> _displayCollections(DisplayCollections event, Emitter emit) async {
    emit(CollectionsLoading());
    try{
      List<CollectionEntity>? collections = await getCollectionsUseCase.call();
      if(collections != null){
        emit(CollectionsLoadedSuccesful(collections: collections));
      } else{
        emit(CollectionsLoadedFailure(exceptionType: "Нет коллекций"));
      }
    } on LocalDataSourceException catch(e) {
      emit(CollectionsLoadedFailure(exceptionType: e.message));
    } catch(e){
      emit(CollectionsLoadedFailure(exceptionType: e.toString()));
    }
  }

  Future<void> _addNewCollection(AddNewCollection event, Emitter emit) async {
    final currentState = state as CollectionsLoadedSuccesful;

    try{
      await addCollectionUseCase.call(CollectionEntity(
        name: event.nameCollection,
        createdAt: DateTime.now(),
        filmCount: 0
      ));
      final updatedCollections = await getCollectionsUseCase.call();
      emit(CollectionAddedSuccessful());
      emit(currentState.copyWith(collections: updatedCollections));
    } on LocalDataSourceException catch(e){
      emit(CollectionAddedFailure());
      emit(CollectionsLoadedSuccesful(collections: currentState.collections));
    } catch(e){
      emit(CollectionAddedFailure());
      emit(CollectionsLoadedSuccesful(collections: currentState.collections));
    }
  }

  void _removeCollection(RemoveCollection event, Emitter emit) async {
    final currentState = state as CollectionsLoadedSuccesful;

    try{
      await removeCollectionUseCase.call(event.collectionId);
      final updatedCollections = await getCollectionsUseCase.call();
      emit(CollectionRemovedSuccessful());
      emit(currentState.copyWith(collections: updatedCollections));
    } on LocalDataSourceException catch(e){
      emit(CollectionRemovedFailure());
      emit(CollectionsLoadedSuccesful(collections: currentState.collections));
    } catch(e){
      emit(CollectionRemovedFailure());
      emit(CollectionsLoadedSuccesful(collections: currentState.collections));
    }
  }

  void _updateCollection(UpdateCollection event, Emitter emit) async {
    final currentState = state as CollectionsLoadedSuccesful;

    try{

    } on LocalDataSourceException catch(e){
      emit(CollectionUpdatedFailure());
      emit(CollectionsLoadedSuccesful(collections: currentState.collections));
    } catch(e){
      emit(CollectionUpdatedFailure());
      emit(CollectionsLoadedSuccesful(collections: currentState.collections));
    }
  }
}
