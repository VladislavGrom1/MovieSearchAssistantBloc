import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/search_films/cubit/watch_saved_films_status_cubit.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/film_poster_image.dart';

class FilmPosterWithLibraryStatus extends StatelessWidget {
  final FilmEntity film;
 
  const FilmPosterWithLibraryStatus({super.key, required this.film});
 
  @override
  Widget build(BuildContext context) {
    return BlocSelector<WatchSavedFilmsStatusCubit, SavedFilmsStatusState, FilmLibraryStatus>(
      selector: (state) => state.statusOf(film.kinopoiskId),
      builder: (context, status) {
        return FilmPosterImage(
          networkImageUrl: film.posterUrlPreview,
          kinopoiskRating: film.ratingKinopoisk,
          showSavedIcon: status.isSaved,
          showUserRating: status.isSaved,
          userRating: status.userRating,
        );
      },
    );
  }
}