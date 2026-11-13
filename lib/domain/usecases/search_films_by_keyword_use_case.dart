import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class SearchFilmsByKeywordUseCase {
  final FilmRepository filmRepository;

  SearchFilmsByKeywordUseCase({required this.filmRepository});
  
  Future<List<FilmEntity>?>? call(String? keyword, int page) async{
    List<FilmEntity>? filterFilms = [];
    try{
      filterFilms = await filmRepository.getSearchFilmsByKeyword(keyword ?? '', page);
      return filterFilms;
    } on RemoteDataSourceException{
      rethrow;
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}