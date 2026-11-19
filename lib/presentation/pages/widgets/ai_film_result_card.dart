import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';
import 'package:movie_search_assistant_bloc/app/util/data_formatter.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_film_recommendation.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/custom_snack_bar.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/film_poster_with_library_status.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/soft_gradient_card.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/tap_scale.dart';

class AiFilmResultCard extends StatelessWidget {
  final AiFilmRecommendation recommendation;

  const AiFilmResultCard({super.key, required this.recommendation});

  void _openDetails(BuildContext context) {
    final film = recommendation.film;
    final kinopoiskId = film.kinopoiskId;

    if (kinopoiskId == null) {
      CustomSnackBar(
        message: 'Не удалось получить информацию о фильме',
      ).show(context);
      return;
    }

    context.router.push(
      FilmInformationRoute(
        filmId: kinopoiskId,
        filmName: film.nameOriginal ?? film.nameRu ?? '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final film = recommendation.film;
    final description = recommendation.description;
    final meta = DataFormatter.formatYearWithGenres(film.year, film.genres);
    final nameRu = film.nameRu;
    final nameOriginal = film.nameOriginal;
    final title = nameRu ?? nameOriginal ?? '-';
    final hasSecondTitle = nameOriginal != null && nameOriginal.isNotEmpty && nameOriginal != title;

    return TapScale(
      onTap: () => _openDetails(context),
      child: SoftGradientCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilmPosterWithLibraryStatus(
              film: film,
              localImagePath: film.localPosterImagePath,
              localImageCategory: 'sessions',
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    title,
                    maxLines: 2,
                    style: CustomTextStyles.m3Title(color: AppColors.textWhite).copyWith(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hasSecondTitle) ...[
                    const SizedBox(height: 10),
                    Text(
                      nameOriginal,
                      maxLines: 1,
                      style: CustomTextStyles.m3Body(color: AppColors.cardSecondaryText).copyWith(fontWeight: FontWeight.w400),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyles.m3Body(
                      color: AppColors.cardAccentText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyles.m3Body(color: AppColors.cardAccentText),
                  ),
                ],
              )
            ),
            const SizedBox(width: 7),
          ]
        )
      )
    );
  }
}
