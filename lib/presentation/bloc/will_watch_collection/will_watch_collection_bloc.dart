import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/models/film_detail_model.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_saved_films_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/watch_saved_films_use_case.dart';

part 'will_watch_collection_event.dart';
part 'will_watch_collection_state.dart';

class WillWatchCollectionBloc extends Bloc<WillWatchCollectionEvent, WillWatchCollectionState> {
  final GetSavedFilmsUseCase getSavedFilmsUseCase;
  final WatchSavedFilmsUseCase watchSavedFilmsUseCase;
  late final StreamSubscription _onChangeSavedFilmsSubscription;
  
  WillWatchCollectionBloc({
    required this.getSavedFilmsUseCase,
    required this.watchSavedFilmsUseCase
    }) : super(WillWatchCollectionInitial()) {
    on<DisplaySavedFilms>(_displaySavedFilms);
    on<SavedFilmsUpdated>(_onSavedFilmsUpdated); 

    _onChangeSavedFilmsSubscription = watchSavedFilmsUseCase().listen((savedFilms) {
      add(SavedFilmsUpdated(savedFilms: savedFilms));
    });
  }

  Future<void> _displaySavedFilms(DisplaySavedFilms event, Emitter emit) async {
    emit(SavedFilmsLoading());
    try{
      List<FilmDetailModel>? savedFilms = await getSavedFilmsUseCase.call();
      if(savedFilms != null && savedFilms.isNotEmpty){
        emit(SavedFilmsLoadedSuccessful(savedFilms: savedFilms));
      } else{
        emit(SavedFilmsLoadedFailure(exceptionType: "Коллекция пустая"));
      }
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

  @override
  Future<void> close() {
    _onChangeSavedFilmsSubscription.cancel();
    return super.close();
  }
}
