import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_images_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class GetFilmImagesUseCase {
  final FilmRepository filmRepository;

  GetFilmImagesUseCase({
    required this.filmRepository, 
  });

  Future<FilmImagesEntity?> call(int idFilm) async{
    try{
      FilmImagesEntity? filmImagesEntity = await filmRepository.getFilmImages(idFilm);
      return filmImagesEntity;
    } on RemoteDataSourceException{
      rethrow;
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}