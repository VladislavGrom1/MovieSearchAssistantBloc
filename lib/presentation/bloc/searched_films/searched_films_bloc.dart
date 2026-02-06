import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_card_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/search_collection_films_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/search_filter_films_use_case.dart';

part 'searched_films_event.dart';
part 'searched_films_state.dart';

class SearchedFilmsBloc extends Bloc<SearchedFilmsEvent, SearchedFilmsState> {
  final SearchFilterFilmsUseCase searchFilterFilmsUseCase;
  final SearchCollectionFilmsUseCase searchCollectionFilmsUseCase;
  int currentPage;
  bool hasReachedMax; 

  SearchedFilmsBloc({
    required this.searchFilterFilmsUseCase,
    required this.searchCollectionFilmsUseCase,
    this.currentPage = 1,
    this.hasReachedMax = false
    }) : super(SearchedFilmsInitial()) {
    on<DisplaySearchedFilterFilms>(_displaySearchedFilterFilms);
    on<DisplaySearchedCollectionFilms>(_displaySearchedCollectionFilms);
    on<LoadNextSearchedFilterFilmsPage>(_loadNextSearchedFilmsPage);
    on<LoadNextSearchedCollectionFilmsPage>(_loadNextCollectionFilmsPage);
  }

  Future<void> _displaySearchedFilterFilms(DisplaySearchedFilterFilms event, Emitter emit) async{
    emit(SearchedFilmsLoading());

    currentPage = 1;
    hasReachedMax = false;

    emit(SearchedFilmsLoadedSuccessful(
        searchedFilms: [],
        isLoadingMore: false,
        hasReachedMax: false,
      ),
    );

    try{
      List<FilmCardEntity>? filterFilms = await searchFilterFilmsUseCase.call(
        event.keyword, 
        event.countries, 
        event.genres, 
        event.yearFrom, 
        event.yearTo, 
        event.page
      );
      if(filterFilms != null){
        emit(SearchedFilmsLoadedSuccessful(searchedFilms: filterFilms));
      } else{
        emit(SearchedFilmsLoadedFailure(exceptionType: "По запросу ничего не найдено"));
      }
    } on RemoteDataSourceException catch(e){
      emit(SearchedFilmsLoadedFailure(exceptionType: e.exceptionType.name, statusCode: e.statusCode));
    } on LocalDataSourceException catch(e){
      emit(SearchedFilmsLoadedFailure(exceptionType: e.message));
    } catch(e){
      emit(SearchedFilmsLoadedFailure(exceptionType: "Неизвестная ошибка"));
    }
  }

  Future<void> _displaySearchedCollectionFilms(DisplaySearchedCollectionFilms event, Emitter emit) async{
    emit(SearchedFilmsLoading());

    currentPage = 1;
    hasReachedMax = false;

    try{
      List<FilmCardEntity>? collectionFilms = await searchCollectionFilmsUseCase.call(
        event.nameCollection,
        event.page,
      );
      if(collectionFilms != null){
        emit(SearchedFilmsLoadedSuccessful(searchedFilms: collectionFilms));
      } else{
        emit(SearchedFilmsLoadedFailure(exceptionType: "По запросу ничего не найдено"));
      }
    } on RemoteDataSourceException catch(e){
      emit(SearchedFilmsLoadedFailure(exceptionType: e.exceptionType.name, statusCode: e.statusCode));
    } on LocalDataSourceException catch(e){
      emit(SearchedFilmsLoadedFailure(exceptionType: e.message));
    } catch(e){
      emit(SearchedFilmsLoadedFailure(exceptionType: "Неизвестная ошибка"));
    }
  }

  Future<void> _loadNextSearchedFilmsPage(LoadNextSearchedFilterFilmsPage event, Emitter emit) async {
    final currentState = state;
    if (currentState is !SearchedFilmsLoadedSuccessful ||
        currentState.isLoadingMore ||
        currentState.hasReachedMax) {
      return;
    }
    emit(currentState.copyWith(isLoadingMore: true));
    currentPage++;

    final newFilms = await searchFilterFilmsUseCase.call(
      event.keyword,
      event.countries,
      event.genres,
      event.yearFrom,
      event.yearTo,
      currentPage,
    );

    if (newFilms == null || newFilms.isEmpty) {
      emit(currentState.copyWith(
        isLoadingMore: false,
        hasReachedMax: true,
      ));
    } else {
      emit(currentState.copyWith(
        searchedFilms: [...currentState.searchedFilms, ...newFilms],
        isLoadingMore: false,
      ));
    }
  }

  Future<void> _loadNextCollectionFilmsPage(LoadNextSearchedCollectionFilmsPage event, Emitter emit) async{
    final currentState = state;
    if (currentState is !SearchedFilmsLoadedSuccessful ||
        currentState.isLoadingMore ||
        currentState.hasReachedMax) {
      return;
    }
    emit(currentState.copyWith(isLoadingMore: true));
    currentPage++;

    final newFilms = await searchCollectionFilmsUseCase.call(
      event.nameCollection,
      currentPage,
    );

    if (newFilms == null || newFilms.isEmpty) {
      emit(currentState.copyWith(
        isLoadingMore: false,
        hasReachedMax: true,
      ));
    } else {
      emit(currentState.copyWith(
        searchedFilms: [...currentState.searchedFilms, ...newFilms],
        isLoadingMore: false,
      ));
    }
  }
}
