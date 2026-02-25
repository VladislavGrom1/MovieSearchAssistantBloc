
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/create_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_collections_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/remove_collection_use_case.dart';

part 'collections_event.dart';
part 'collections_state.dart';

class CollectionsBloc extends Bloc<CollectionsEvent, CollectionsState> {
  final GetCollectionsUseCase getCollectionsUseCase;
  final CreateCollectionUseCase createCollectionUseCase;
  final RemoveCollectionUseCase removeCollectionUseCase;

  CollectionsBloc({
    required this.getCollectionsUseCase,
    required this.createCollectionUseCase,
    required this.removeCollectionUseCase
  }) : super(CollectionsInitial()) {
    on<DisplayCollections>(_displayCollections);
    on<AddNewCollection>(_addNewCollection);
    on<RemoveCollection>(_removeCollection);
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
    final currentState = state;

    try{
      if(currentState is CollectionsLoadedSuccesful){
        await createCollectionUseCase.call(CollectionEntity(
          collectionName: event.nameCollection,
          createdAt: DateTime.now(),
          filmCount: 0
        ));
        final updatedCollections = await getCollectionsUseCase.call();
        emit(currentState.copyWith(collections: updatedCollections));
      } 
    } on LocalDataSourceException catch(e){
      emit(CollectionsLoadedFailure(exceptionType: e.message));
    } catch(e){
      emit(CollectionsLoadedFailure(exceptionType: e.toString()));
    }
  }

  void _removeCollection(RemoveCollection event, Emitter emit) async {
    final currentState = state;

    try{
      if(currentState is CollectionsLoadedSuccesful){
        await removeCollectionUseCase.call(event.collectionName);
        final updatedCollections = await getCollectionsUseCase.call();
        emit(currentState.copyWith(collections: updatedCollections));
      }
    } on LocalDataSourceException catch(e){
      emit(CollectionsLoadedFailure(exceptionType: e.message));
    } catch(e){
      emit(CollectionsLoadedFailure(exceptionType: e.toString()));
    }
  }
}
