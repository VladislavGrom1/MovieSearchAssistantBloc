import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/app/cache_service/film_image_cache_service.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';

class PosterFilmImage extends StatelessWidget {
  final String? urlImage;
  final num? rating;
  final bool filmIsSaved;

  const PosterFilmImage({
    super.key,
    this.urlImage,
    this.rating,
    required this.filmIsSaved
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.w),
      child: RepaintBoundary(
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: urlImage ?? '',
              cacheManager: FilmImageCacheService.instance,
              memCacheWidth: 200,
              memCacheHeight: 280,
              fit: BoxFit.fill,
              width: 100.w,
              height: 140.h,
              placeholder: (context, url) => Container(color: AppColors.primaryThemeGrey),
              errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, color: AppColors.primaryScheme),
            ),
            _RatingIcon(rating: rating),
            if(filmIsSaved)
            Positioned(
              top: 6.h,
              left: 4.w,
              child: Container(
                width: 20.w,
                height: 20.h,
                decoration: BoxDecoration(
                color: AppColors.savedFilmIcon,
                borderRadius: BorderRadius.circular(5.0.h)),
                child: Icon(
                  Icons.bookmark,
                  color: Colors.white,
                  size: 19.w,
                )
              )
            ),
          ] 
        ),
      ),
    );
  }
}

class _RatingIcon extends StatelessWidget {
  final num? rating;

  const _RatingIcon({required this.rating});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    String ratingText;
    
    if (rating == null) {
      backgroundColor = AppColors.ratingGrey;
      ratingText = "-";
    } else {
      if (rating! >= 7 && rating! <= 10) {
        backgroundColor = AppColors.ratingGreen;
      }
      else if (rating! >= 6 && rating! < 7) {
        backgroundColor = AppColors.ratingOrange;
      }
      else if (rating! >= 5 && rating! < 6) {
        backgroundColor = AppColors.ratingGrey;
      }
      else if (rating! >= 0 && rating! < 5) {
        backgroundColor = AppColors.ratingRed;
      } else {
        backgroundColor = AppColors.ratingGrey;
      }
      ratingText = rating.toString();
    }

    return Positioned(
      bottom: 6.h,
      right: 4.w,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(5.0.h),
        ),
        width: 22.w,
        height: 20.h,
        child: Center(
          child: Text(ratingText, style: CustomTextStyles.m3LabelSmall(color: AppColors.textWhite))
        ),
      ),
    );
  }
}