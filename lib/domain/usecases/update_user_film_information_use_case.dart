import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/models/film_detail_model.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class UpdateUserFilmInformationUseCase {
  final FilmRepository filmRepository;

  UpdateUserFilmInformationUseCase({required this.filmRepository});

  Future<FilmEntity> call(FilmEntity film, int? userRating, String? userComment) async {
    try{
      final savedFilm = await filmRepository.getFilmFromLocalDataSource(film.kinopoiskId!) ?? film;

      final updated = savedFilm.copyWith(
        userRating: userRating ?? savedFilm.userRating,
        userComment: userComment ?? savedFilm.userComment,
      );

      await filmRepository.addFilmInLocalDataSource(FilmDetailModel.fromFilmEntity(updated));
      return updated;
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}