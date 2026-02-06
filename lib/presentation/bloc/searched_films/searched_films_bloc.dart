import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
  SearchedFilmsBloc({
    required this.searchFilterFilmsUseCase,
    required this.searchCollectionFilmsUseCase
    }) : super(SearchedFilmsInitial()) {
    on<DisplaySearchedFilterFilms>(_displaySearchedFilterFilms);
    on<DisplaySearchedCollectionFilms>(_displaySearchedCollectionFilms);
  }

  Future<void> _displaySearchedFilterFilms(DisplaySearchedFilterFilms event, Emitter emit) async{
    emit(SearchedFilmsLoading());
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
}
