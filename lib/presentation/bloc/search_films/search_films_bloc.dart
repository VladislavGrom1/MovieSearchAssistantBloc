import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/util/constants/film_collection_names.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_card_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/display_film_collections_use_case.dart';

part 'search_films_event.dart';
part 'search_films_state.dart';

class SearchFilmsBloc extends Bloc<SearchFilmsEvent, SearchFilmsState> {
  final DisplayFilmCollectionsUseCase displayFilmCollectionsUseCase;
  SearchFilmsBloc({required this.displayFilmCollectionsUseCase}) : super(SearchFilmsInitial()) {
    on<DisplayFilmCollectionsEvent>((event, emit) => _displayFilmCollections(event, emit));
  }

  Future<void> _displayFilmCollections(SearchFilmsEvent event, Emitter emit) async{
    emit(SearchFilmsLoading());
    try{
      final Map<String, List<FilmCardEntity>?>? filmCollectionsMap = await displayFilmCollectionsUseCase.call(FilmCollectionNames.filmCollectionNames);
      if(filmCollectionsMap != null){
        emit(CollectionsFilmsLoadedSuccesful(filmCollectionsMap: filmCollectionsMap));
      } else{
        emit(CollectionsFilmsLoadedFailure(exceptionType: "Коллекция фильмов пустая"));
      }
    } on RemoteDataSourceException catch(e){
      emit(CollectionsFilmsLoadedFailure(exceptionType: e.exceptionType.name, statusCode: e.statusCode));
    } catch(e){
      emit(CollectionsFilmsLoadedFailure(exceptionType: "Неизвестная ошибка"));
    }
  }
}
