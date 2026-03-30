import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/search_collection_films_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/search_filter_films_use_case.dart';

part 'searched_films_event.dart';
part 'searched_films_state.dart';

class SearchedFilmsBloc extends Bloc<SearchedFilmsEvent, SearchedFilmsState> {
  final SearchFilterFilmsUseCase searchFilterFilmsUseCase;
  final SearchCollectionFilmsUseCase searchCollectionFilmsUseCase;

  int currentPage = 1;
  bool hasReachedMax = false;
  LoadSearchedFilms? _lastQuery; 

  SearchedFilmsBloc({
    required this.searchFilterFilmsUseCase,
    required this.searchCollectionFilmsUseCase,
    }) : super(SearchedFilmsInitial()) {
    on<LoadSearchedFilms>(_onLoadSearchedFilms);
    on<LoadNextPage>(_onLoadNextPage);
    on<RefreshFilmsPage>(_onRefreshFilmsPage);
  }

  Future<void> _onLoadSearchedFilms(LoadSearchedFilms event, Emitter emit) async {
    emit(SearchedFilmsLoading());

    currentPage = 1;
    hasReachedMax = false;
    _lastQuery = event;

    try {
      final films = await _fetchFilms(event, page: currentPage);

      if (films.isEmpty) {
        emit(SearchedFilmsLoadedFailure(message: "Фильмы по запросу не найдены"));
      } else {
        emit(SearchedFilmsLoadedSuccessful(
          searchedFilms: films,
          isLoadingMore: false,
          hasReachedMax: false,
        ));
      }

    } on RemoteDataSourceException catch (e) {
      emit(SearchedFilmsLoadedFailure(message: e.message));
    } on LocalDataSourceException catch (e) {
      emit(SearchedFilmsLoadedFailure(message: e.message));
    } catch (e) {
      emit(SearchedFilmsLoadedFailure(message: "Неизвестная ошибка"));
    }
  }

  Future<void> _onLoadNextPage(LoadNextPage event, Emitter emit) async {
    final currentState = state;

    if (currentState is! SearchedFilmsLoadedSuccessful ||
        currentState.isLoadingMore ||
        currentState.hasReachedMax) {
        return;
    } 

    emit(currentState.copyWith(isLoadingMore: true));

    currentPage++;

    try {
      final films = await _fetchFilms(_lastQuery!, page: currentPage);

      if (films.isEmpty) {
        emit(currentState.copyWith(
          isLoadingMore: false,
          hasReachedMax: true,
        ));
      } else {
        emit(currentState.copyWith(
          searchedFilms: [...currentState.searchedFilms, ...films],
          isLoadingMore: false,
        ));
      }

    } on RemoteDataSourceException {
      emit(currentState.copyWith(
        isLoadingMore: false,
      ));
    } on LocalDataSourceException {
      emit(currentState.copyWith(
        isLoadingMore: false,
      ));
    } catch (_) {
      emit(currentState.copyWith(
        isLoadingMore: false,
      ));
    }
  }

  Future<void> _onRefreshFilmsPage(
    RefreshFilmsPage event,
    Emitter emit,
  ) async {
    if (_lastQuery != null) {
      add(_lastQuery!);
    }
  }

  Future<List<FilmEntity>> _fetchFilms(
    LoadSearchedFilms event, {
    required int page,
  }) async {
    if (event.nameCollection != null) {
      return await searchCollectionFilmsUseCase(
        event.nameCollection!,
        page,
      ) ?? [];
    } else {
      return await searchFilterFilmsUseCase(
        event.keyword,
        event.countries,
        event.genres,
        event.yearFrom,
        event.yearTo,
        page,
      ) ?? [];
    }
  }
}
