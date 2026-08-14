import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movie_search_assistant_bloc/app/cache_service/film_image_cache_service.dart';
import 'package:movie_search_assistant_bloc/app/cache_service/image_path_resolver.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:skeletonizer/skeletonizer.dart';

class FilmPosterImage extends StatelessWidget {
  final String? networkImageUrl;
  final String? localImagePath;
  final num? kinopoiskRating;
  final num? userRating;
  final bool showSavedIcon;
  final bool showUserRating;
  
  const FilmPosterImage({
    super.key,
    this.networkImageUrl,
    this.localImagePath,
    this.kinopoiskRating,
    this.userRating,
    this.showSavedIcon = false,
    this.showUserRating = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: RepaintBoundary(
        child: Stack(
          children: [
            _buildImage(),
            
            _RatingIcon(
              rating: kinopoiskRating,
              position: RatingPosition.bottomRight,
            ),
            
            if (showSavedIcon)
              _SavedIcon(),
            
            if (showUserRating)
              _UserRatingIcon(rating: userRating),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (localImagePath != null && localImagePath!.isNotEmpty) {
      final fullPath = ImagePathResolver.resolve(localImagePath!);
      final file = File(fullPath);
      return Image.file(
          file,
          fit: BoxFit.cover,
          width: 100,
          height: 140,
          errorBuilder: (context, url, error) => const Icon(Icons.image_not_supported, color: AppColors.primaryScheme),
        );
    } else {
      return CachedNetworkImage(
        imageUrl: networkImageUrl ?? '',
        cacheManager: getIt<FilmImageCacheService>().instance,
        memCacheWidth: 200,
        memCacheHeight: 280,
        fit: BoxFit.cover,
        width: 100,
        height: 140,
        placeholder: (context, url) => Skeletonizer(
          enabled: true,
          effect: const ShimmerEffect(
            baseColor: AppColors.primaryThemeBlack,
            highlightColor: AppColors.primaryThemeGrey,
            duration: Duration(seconds: 4),
          ),
          child: Container(
            color: AppColors.primaryThemeGrey,
            width: 100,
            height: 140,
          )
        ),
        errorWidget: (context, url, error) => Container(
          color: AppColors.primaryThemeGrey, 
          child: Icon(Icons.image_not_supported, color: AppColors.primaryScheme)
        ),
      );
    }
  }
}

enum RatingPosition {
  bottomRight,
  bottomLeft,
  topRight,
  topLeft,
}

class _RatingIcon extends StatelessWidget {
  final num? rating;
  final RatingPosition position;

  const _RatingIcon({
    required this.rating,
    this.position = RatingPosition.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    String ratingText;
    
    if (rating == null) {
      backgroundColor = AppColors.ratingGrey;
      ratingText = "-";
    } else {
      backgroundColor = _getRatingColor(rating!);
      ratingText = rating.toString();
    }

    return Positioned(
      bottom: position == RatingPosition.bottomRight || position == RatingPosition.bottomLeft ? 6 : null,
      top: position == RatingPosition.topRight || position == RatingPosition.topLeft ? 6 : null,
      right: position == RatingPosition.bottomRight || position == RatingPosition.topRight ? 4 : null,
      left: position == RatingPosition.bottomLeft || position == RatingPosition.topLeft ? 4 : null,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(5.0),
        ),
        width: 22,
        height: 20,
        child: Center(
          child: Text(
            ratingText,
            style: CustomTextStyles.m3FilmTitle(color: AppColors.textWhite),
          ),
        ),
      ),
    );
  }

  Color _getRatingColor(num rating) {
    if (rating >= 7 && rating <= 10) return AppColors.ratingGreen;
    if (rating >= 6 && rating < 7) return AppColors.ratingOrange;
    if (rating >= 5 && rating < 6) return AppColors.ratingGrey;
    if (rating >= 0 && rating < 5) return AppColors.ratingRed;
    return AppColors.ratingGrey;
  }
}

class _SavedIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 6,
      left: 4,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: AppColors.savedFilmIcon,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Icon(
          Icons.bookmark,
          color: Colors.white,
          size: 19,
        ),
      ),
    );
  }
}

class _UserRatingIcon extends StatelessWidget {
  final num? rating;

  const _UserRatingIcon({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 6,
      right: 30,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryScheme,
          borderRadius: BorderRadius.circular(5.0),
        ),
        width: 22,
        height: 20,
        child: Center(
          child: Text(
            "${rating ?? "-"}",
            style: CustomTextStyles.m3FilmRating(color: AppColors.textWhite),
          ),
        ),
      ),
    );
  }
}