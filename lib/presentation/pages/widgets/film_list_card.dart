import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';
import 'package:movie_search_assistant_bloc/app/util/data_formatter.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/custom_snack_bar.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/film_poster_with_library_status.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/soft_gradient_card.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/tap_scale.dart';


class FilmListCard extends StatelessWidget {
  final FilmEntity film;
 
  const FilmListCard({super.key, required this.film});
 
  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: () {
        if (film.kinopoiskId != null) {
          context.router.push(
            FilmInformationRoute(
                filmId: film.kinopoiskId!,
                filmName: film.nameRu ?? film.nameOriginal.toString()),
          );
        } else {
          CustomSnackBar(message: "Не удалось получить информацию о фильме").show(context);
        }
      },
      child: SoftGradientCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilmPosterWithLibraryStatus(film: film),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    film.nameRu ?? film.nameOriginal ?? "-",
                    maxLines: 2,
                    style: CustomTextStyles.m3Title(color: AppColors.textWhite).copyWith(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    film.nameOriginal ?? film.nameRu ?? "-",
                    maxLines: 2,
                    style: CustomTextStyles.m3Body(color: AppColors.cardSecondaryText).copyWith(fontWeight: FontWeight.w400),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DataFormatter.formatCountriesAndYear(film.countries, film.year),
                    maxLines: 1,
                    style: CustomTextStyles.m3Body(color: AppColors.cardAccentText).copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DataFormatter.formatGenres(film.genres),
                    maxLines: 1,
                    style: CustomTextStyles.m3Body(color: AppColors.cardSecondaryText).copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 7),
          ],
        ),
      ),
    );
  }
}