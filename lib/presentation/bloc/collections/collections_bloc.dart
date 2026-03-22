
import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/add_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/clear_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_collections_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/remove_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/rename_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/watch_collections_use_case.dart';

part 'collections_event.dart';
part 'collections_state.dart';

class CollectionsBloc extends Bloc<CollectionsEvent, CollectionsState> {
  final GetCollectionsUseCase getCollectionsUseCase;
  final AddCollectionUseCase addCollectionUseCase;
  final RemoveCollectionUseCase removeCollectionUseCase;
  final WatchCollectionsUseCase watchCollectionsUseCase;
  final ClearCollectionUseCase clearCollectionUseCase;
  final RenameCollectionUseCase renameCollectionUseCase;
  StreamSubscription? _savedCollectionsSubscription;

  CollectionsBloc({
    required this.getCollectionsUseCase,
    required this.addCollectionUseCase,
    required this.removeCollectionUseCase,
    required this.watchCollectionsUseCase,
    required this.clearCollectionUseCase,
    required this.renameCollectionUseCase
  }) : super(CollectionsInitial()) {
    on<GetCollections>(_getCollections);
    on<AddNewCollection>(_addNewCollection);
    on<RemoveCollection>(_removeCollection);
    on<UpdateCollections>(_updateCollections);
    on<ClearCollection>(_clearCollection);
    on<RenameCollection>(_renameCollection);
  }
 
  Future<void> _getCollections(GetCollections event, Emitter emit) async {
    emit(CollectionsLoading());
    try{
      _savedCollectionsSubscription?.cancel();
      _savedCollectionsSubscription = watchCollectionsUseCase.call().listen(
        (updatedCollections) => add(UpdateCollections(updatedCollections: updatedCollections))
      );
    } on LocalDataSourceException catch(e) {
      emit(CollectionsFailure(message: e.message));
    } catch(e){
      emit(CollectionsFailure(message: e.toString()));
    }
  }

  Future<void> _addNewCollection(AddNewCollection event, Emitter emit) async {
    try{
      await addCollectionUseCase.call(event.collectionName);
    } on LocalDataSourceException catch(e){
      emit(CollectionsFailure(message: e.message));
    } catch(e){
      emit(CollectionsFailure(message: e.toString()));
    }
  }

  Future<void> _removeCollection(RemoveCollection event, Emitter emit) async {
    try{
      await removeCollectionUseCase.call(event.collectionId);
    } on LocalDataSourceException catch(e){
      emit(CollectionsFailure(message: e.message));
    } catch(e){
      emit(CollectionsFailure(message: e.toString()));
    }
  }

  Future<void> _updateCollections(UpdateCollections event, Emitter emit) async {
    try{
      final updatedCollections = event.updatedCollections;
      emit(CollectionsLoaded(collections: updatedCollections));
    } on LocalDataSourceException catch(e){
      emit(CollectionsFailure(message: e.message));
    } catch(e){
      emit(CollectionsFailure(message: e.toString()));
    }
  }

  Future<void> _clearCollection(ClearCollection event, Emitter emit) async {
    try{
      await clearCollectionUseCase.call(event.collectionId);
    } on LocalDataSourceException catch(e){
      emit(CollectionsFailure(message: e.message));
    } catch(e){
      emit(CollectionsFailure(message: e.toString()));
    }
  }

  Future<void> _renameCollection(RenameCollection event, Emitter emit) async {
    try{
      await renameCollectionUseCase.call(event.collection, event.updatedName);
    } on LocalDataSourceException catch(e){
      emit(CollectionsFailure(message: e.message));
    } catch(e){
      emit(CollectionsFailure(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _savedCollectionsSubscription?.cancel();
    return super.close();
  }
}
