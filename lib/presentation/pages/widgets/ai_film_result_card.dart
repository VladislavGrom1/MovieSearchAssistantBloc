import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';
import 'package:movie_search_assistant_bloc/domain/entities/ai_film_recommendation.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/custom_snack_bar.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/film_poster_with_library_status.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/soft_gradient_card.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/tap_scale.dart';

/// Карточка одной AI-рекомендации: постер по центру, название и описание.
///
/// Описание живёт только на этом экране, поэтому оно свёрнуто до трёх строк
/// и раскрывается на месте — на экран деталей оно не передаётся.
class AiFilmResultCard extends StatefulWidget {
  final AiFilmRecommendation recommendation;

  const AiFilmResultCard({super.key, required this.recommendation});

  @override
  State<AiFilmResultCard> createState() => _AiFilmResultCardState();
}

class _AiFilmResultCardState extends State<AiFilmResultCard> {
  static const int _collapsedLines = 3;
  static const double _posterWidth = 140;
  static const double _posterHeight = 200;

  bool _isExpanded = false;

  AiFilmRecommendation get _recommendation => widget.recommendation;

  void _openDetails(BuildContext context) {
    final film = _recommendation.film;
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
    final film = _recommendation.film;
    final title = film.nameOriginal ?? film.nameRu ?? '';
    final description = _recommendation.description;

    return TapScale(
      onTap: () => _openDetails(context),
      child: SoftGradientCard(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: FilmPosterWithLibraryStatus(
                  film: film,
                  width: _posterWidth,
                  height: _posterHeight,
                ),
              ),
              if (title.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: CustomTextStyles.m3Title(color: AppColors.textWhite)
                      .copyWith(fontSize: 16),
                ),
              ],
              if (description.isNotEmpty) ...[
                const SizedBox(height: 8),
                _Description(
                  description: description,
                  isExpanded: _isExpanded,
                  collapsedLines: _collapsedLines,
                  onToggle: () => setState(() => _isExpanded = !_isExpanded),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Description extends StatelessWidget {
  final String description;
  final bool isExpanded;
  final int collapsedLines;
  final VoidCallback onToggle;

  const _Description({
    required this.description,
    required this.isExpanded,
    required this.collapsedLines,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final style = CustomTextStyles.m3Body(
      color: AppColors.cardSecondaryText,
    ).copyWith(fontWeight: FontWeight.w400);

    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: description, style: style),
          maxLines: collapsedLines,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);
        final isLong = textPainter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              textAlign: TextAlign.left,
              maxLines: isExpanded ? null : collapsedLines,
              overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: style,
            ),
            if (isLong)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: onToggle,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: AppColors.primaryScheme,
                  ),
                  child: Text(
                    isExpanded ? 'Свернуть' : 'Читать полностью',
                    style: CustomTextStyles.m3Body(
                      color: AppColors.primaryScheme,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
