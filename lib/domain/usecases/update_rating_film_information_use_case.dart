import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/models/film_detail_model.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class UpdateRatingFilmInformationUseCase {
  final FilmRepository filmRepository;

  UpdateRatingFilmInformationUseCase({required this.filmRepository});

  Future<FilmEntity> call(FilmEntity film, int userRating) async {
    try{
      final filmWithUpdatedUserRating = film.copyWith(userRating: userRating);
      await filmRepository.addFilmInLocalDataSource(FilmDetailModel.fromFilmEntity(filmWithUpdatedUserRating));
      return filmWithUpdatedUserRating;
    } on LocalDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}