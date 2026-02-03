import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_card_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/search_filter_films_use_case.dart';

part 'searched_films_event.dart';
part 'searched_films_state.dart';

class SearchedFilmsBloc extends Bloc<SearchedFilmsEvent, SearchedFilmsState> {
  final SearchFilterFilmsUseCase searchFilterFilmsUseCase;
  SearchedFilmsBloc({required this.searchFilterFilmsUseCase}) : super(SearchedFilmsInitial()) {
    on<DisplaySearchedFilms>(_displaySearchedFilms);
  }

  Future<void> _displaySearchedFilms(DisplaySearchedFilms event, Emitter emit) async{
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
      emit(SearchedFilmsLoadedSuccessful(filterFilms: filterFilms));
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
