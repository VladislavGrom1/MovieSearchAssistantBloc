import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/models/film_detail_model.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class UpdateSavedFilmUseCase {
  final FilmRepository filmRepository;

  UpdateSavedFilmUseCase({required this.filmRepository});

  Future<void> call(FilmEntity oldfilm, FilmEntity newFilm) async {
    try{
      FilmEntity updatedFilm = newFilm.copyWith(userComment: oldfilm.userComment, userRating: oldfilm.userRating);
      await filmRepository.addFilmInLocalDataSource(FilmDetailModel.fromFilmEntity(updatedFilm));
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}