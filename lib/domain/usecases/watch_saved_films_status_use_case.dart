import 'package:movie_search_assistant_bloc/data/models/film_collection_link.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_collection_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';
import 'package:rxdart/rxdart.dart';

class WatchSavedFilmsStatusUseCase {
  final FilmRepository filmRepository;
  final FilmCollectionRepository filmCollectionRepository;
 
  WatchSavedFilmsStatusUseCase({
    required this.filmRepository,
    required this.filmCollectionRepository,
  });
 
  Stream<Map<int, int?>> call() {
    return Rx.combineLatest2(
      filmCollectionRepository.watchLinks(),
      filmRepository.watchFilms(),
      (List<FilmCollectionLink> links, List<FilmEntity> films) {
        final savedIds = links.map((link) => link.filmId).toSet();
        final result = <int, int?>{};
 
        for (final film in films) {
          final id = film.kinopoiskId;
          if (id != null && savedIds.contains(id)) {
            result[id] = film.userRating;
          }
        }

        for (final id in savedIds) {
          result.putIfAbsent(id, () => null);
        }
        return result;
      },
    );
  }
}