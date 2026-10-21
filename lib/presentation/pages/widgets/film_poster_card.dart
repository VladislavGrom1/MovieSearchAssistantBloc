import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/custom_snack_bar.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/film_poster_with_library_status.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/tap_scale.dart';

class FilmPosterCard extends StatelessWidget {
  final FilmEntity film;
  final bool showRating;
 
  const FilmPosterCard({
    super.key,
    required this.film,
    this.showRating = true,
  });
 
  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: () {
        if (film.kinopoiskId != null) {
          context.router.push(FilmInformationRoute(
              filmId: film.kinopoiskId!,
              filmName: film.nameRu ?? film.nameOriginal.toString()));
        } else {
          CustomSnackBar(message: "Не удалось получить информацию о фильме").show(context);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FilmPosterWithLibraryStatus(film: film, showRating: showRating),
          const SizedBox(height: 5),
          SizedBox(
            width: 96,
            child: Text(
              film.nameRu ?? film.nameOriginal ?? "-",
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
              style: CustomTextStyles.m3FilmTitle(),
            ),
          ),
        ],
      ),
    );
  }
}