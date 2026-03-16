import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_saved_films_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/watch_films_use_case.dart';

part 'collection_films_event.dart';
part 'collection_films_state.dart';

class CollectionFilmsBloc extends Bloc<CollectionFilmsEvent, CollectionFilmsState> {
  final GetSavedFilmsUseCase getSavedFilmsUseCase;
  final WatchFilmsUseCase watchFilmsUseCase;
  late StreamSubscription _savedFilmsSubscription;

  CollectionFilmsBloc({
    required this.getSavedFilmsUseCase,
    required this.watchFilmsUseCase
  }) : super(CollectionFilmsInitial()) {
    on<GetSavedFilms>(_getSavedFilms);
    on<UpdateSavedFilms>(_updateSavedFilms);

    _savedFilmsSubscription = watchFilmsUseCase.call().listen(
      (savedFilms) => add(UpdateSavedFilms(updatedSavedFilms: savedFilms))
    );
  }

  Future<void> _getSavedFilms(GetSavedFilms event, Emitter emit) async {
    emit(CollectionFilmsLoading());
    try{
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
      final updatedCollectionSavedFilms = event.updatedSavedFilms.where((film) => film.collectionIds?.contains(currentState.collectionId) ?? false).toList();
      emit(CollectionFilmsLoaded(collectionId: currentState.collectionId, savedFilms: updatedCollectionSavedFilms));
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
    _savedFilmsSubscription.cancel();
    return super.close();
  }
}
