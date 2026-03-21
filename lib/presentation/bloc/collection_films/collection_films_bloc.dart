import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_saved_films_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/remove_film_from_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/watch_collection_films_use_case.dart';

part 'collection_films_event.dart';
part 'collection_films_state.dart';

class CollectionFilmsBloc extends Bloc<CollectionFilmsEvent, CollectionFilmsState> {
  final GetSavedFilmsUseCase getSavedFilmsUseCase;
  final RemoveFilmFromCollectionUseCase removeFilmFromCollectionUseCase;
  final WatchCollectionFilmsUseCase watchFilmsUseCase;
  StreamSubscription? _savedFilmsSubscription;

  CollectionFilmsBloc({
    required this.getSavedFilmsUseCase,
    required this.removeFilmFromCollectionUseCase,
    required this.watchFilmsUseCase
  }) : super(CollectionFilmsInitial()) {
    on<GetSavedFilms>(_getSavedFilms);
    on<UpdateSavedFilms>(_updateSavedFilms);
    on<RemoveFilm>(_removeFilm);
  }

  Future<void> _getSavedFilms(GetSavedFilms event, Emitter emit) async {
    emit(CollectionFilmsLoading());
    try{
      await _savedFilmsSubscription?.cancel();
      _savedFilmsSubscription = watchFilmsUseCase(event.collectionId).listen((films) {
        add(UpdateSavedFilms(updatedSavedFilms: films));
      });
      final List<FilmEntity> savedFilms = await getSavedFilmsUseCase.call(event.collectionId);
      emit(CollectionFilmsLoaded(collectionId: event.collectionId, savedFilms: savedFilms));
    } on LocalDataSourceException catch(e){
      emit(CollectionFilmsFailure(message: e.message));
    } catch(e){
      emit(CollectionFilmsFailure(message: e.toString()));
    }
  }

  Future<void> _updateSavedFilms(UpdateSavedFilms event, Emitter emit) async {
    final currentState = state;
    if(currentState is! CollectionFilmsLoaded) return;
    try{
      emit(CollectionFilmsLoaded(collectionId: currentState.collectionId, savedFilms: event.updatedSavedFilms));
    } on LocalDataSourceException catch(e){
      emit(CollectionFilmsFailure(message: e.message));
      emit(currentState);
    } catch(e){
      emit(CollectionFilmsFailure(message: e.toString()));
      emit(currentState);
    }
  }

  Future<void> _removeFilm(RemoveFilm event, Emitter emit) async {
    final currentState = state;
    if(currentState is! CollectionFilmsLoaded) return;
    try{
      await removeFilmFromCollectionUseCase.call(event.film, event.collectionId);
    } on LocalDataSourceException catch(e){
      emit(CollectionFilmsFailure(message: e.message));
      emit(currentState);
    } catch(e){
      emit(CollectionFilmsFailure(message: e.toString()));
      emit(currentState);
    }
  }


  @override
  Future<void> close() {
    _savedFilmsSubscription?.cancel();
    return super.close();
  }
}
