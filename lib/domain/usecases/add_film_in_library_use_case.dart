import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/models/film_detail_model.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class AddFilmInLibraryUseCase {
  final FilmRepository filmRepository;

  AddFilmInLibraryUseCase({
    required this.filmRepository
  });

  Future<void> call(FilmEntity film) async {
    try{
      await filmRepository.addFilmInLocalDataSource(FilmDetailModel.fromFilmEntity(film));
    } on LocalDataSourceException{
      rethrow; 
    } catch(e){
      rethrow;
    }
  }
}