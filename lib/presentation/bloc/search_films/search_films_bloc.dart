import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/util/constants/film_collection_names.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_collections_films_use_case.dart';

part 'search_films_event.dart';
part 'search_films_state.dart';

class SearchFilmsBloc extends Bloc<SearchFilmsEvent, SearchFilmsState> {
  final GetCollectionsFilmsUseCase displayFilmCollectionsUseCase;
  SearchFilmsBloc({required this.displayFilmCollectionsUseCase}) : super(SearchFilmsInitial()) {
    on<DisplayFilmCollections>(_displayFilmCollections);
  }

  Future<void> _displayFilmCollections(SearchFilmsEvent event, Emitter emit) async{
    emit(SearchFilmsLoading());
    try{
      final Map<String, List<FilmEntity>?>? filmCollectionsMap = await displayFilmCollectionsUseCase.call(FilmCollectionNames.filmCollectionNames);
      if(filmCollectionsMap != null){
        emit(CollectionsFilmsLoadedSuccessful(filmCollectionsMap: filmCollectionsMap));
      } else{
        emit(CollectionsFilmsLoadedFailure(message: "Коллекция фильмов пуста"));
      }
    } on RemoteDataSourceException catch(e){
      emit(CollectionsFilmsLoadedFailure(message: e.message));
    } on LocalDataSourceException catch(e){
      emit(CollectionsFilmsLoadedFailure(message: e.message));
    } catch(e){
      emit(CollectionsFilmsLoadedFailure(message: "Неизвестная ошибка"));
    }
  }
}
