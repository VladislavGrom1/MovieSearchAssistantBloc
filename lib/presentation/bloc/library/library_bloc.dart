import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_saved_films_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/remove_film_from_library_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/watch_saved_films_use_case.dart';

part 'library_event.dart';
part 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final GetSavedFilmsUseCase getSavedFilmsUseCase;
  final WatchSavedFilmsUseCase watchSavedFilmsUseCase;
  final RemoveFilmFromLibraryUseCase removeFilmFromLibraryUseCase;
  late final StreamSubscription _onChangeSavedFilmsSubscription;
  
  LibraryBloc({
    required this.getSavedFilmsUseCase,
    required this.watchSavedFilmsUseCase,
    required this.removeFilmFromLibraryUseCase
    }) : super(LibraryInitial()) {
    on<DisplaySavedFilms>(_displaySavedFilms);
    on<SavedFilmsUpdated>(_onSavedFilmsUpdated);
    on<RemoveFilmFromLibrary>(_removeFilmFromLibrary); 

    _onChangeSavedFilmsSubscription = watchSavedFilmsUseCase().listen((savedFilms) {
      add(SavedFilmsUpdated(savedFilms: savedFilms));
    });
  }

  Future<void> _displaySavedFilms(DisplaySavedFilms event, Emitter emit) async {
    emit(SavedFilmsLoading());
    try{
      List<FilmEntity>? savedFilms = await getSavedFilmsUseCase.call();
      emit(SavedFilmsLoadedSuccessful(savedFilms: savedFilms ?? []));
    } on LocalDataSourceException catch(e){
      emit(SavedFilmsLoadedFailure(exceptionType: e.message));
    } catch(e){
      emit(SavedFilmsLoadedFailure(exceptionType: e.toString()));
    }
  }

  Future<void> _onSavedFilmsUpdated(SavedFilmsUpdated event, Emitter emit) async {
    final currentState = state;
    if(currentState is SavedFilmsLoadedSuccessful){
      emit(currentState.copyWith(savedFilms: event.savedFilms));
    }
  }

  Future<void> _removeFilmFromLibrary(RemoveFilmFromLibrary event, Emitter emit) async {
    final currentState = state;
    try{
      if(currentState is SavedFilmsLoadedSuccessful){
        await removeFilmFromLibraryUseCase.call(event.film);
        emit(currentState.copyWith(savedFilms: event.savedFilms));
      }
    } on LocalDataSourceException catch(e){
      emit(SavedFilmsLoadedFailure(exceptionType: e.message));
    } catch(e){
      emit(SavedFilmsLoadedFailure(exceptionType: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _onChangeSavedFilmsSubscription.cancel();
    return super.close();
  }
}
