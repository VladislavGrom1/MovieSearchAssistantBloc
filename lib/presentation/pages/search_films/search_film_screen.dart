import 'dart:math';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/app/cache_service/film_image_cache_service.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';
import 'package:movie_search_assistant_bloc/app/util/constants/film_collection_names.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/search_films/cubit/watch_film_collection_links_cubit.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/search_films/search_films_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/search_films/widgets/custom_search_bar.dart';

@RoutePage()
class SearchFilmScreen extends StatelessWidget {
  const SearchFilmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<SearchFilmsBloc>()..add(DisplayFilmCollections()),
        ),
        BlocProvider(
          create: (_) => getIt<WatchFilmCollectionLinksCubit>(),
        ),
      ],
      child: _SearchFilmView(),
    );
  }
}

class _SearchFilmView extends StatelessWidget {
  const _SearchFilmView();

  @override
  Widget build(BuildContext context) {
    final searchFilmBloc = context.read<SearchFilmsBloc>();

    return Scaffold(
        backgroundColor: AppColors.primaryThemeBlack,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20.h),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      searchFilmBloc.add(DisplayFilmCollections());
                    },
                    child: BlocBuilder<SearchFilmsBloc, SearchFilmsState>(
                      builder: (context, state) {
                        if (state is SearchFilmsLoading) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (state is CollectionsFilmsLoadedFailure) {
                          return _buildError(state.message);
                        }

                        if (state is CollectionsFilmsLoadedSuccessful) {
                          return _SearchFilmContent(filmCollectionsMap: state.filmCollectionsMap);
                        }
                        return SizedBox();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildError(String message) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Image.asset("assets/icons/errorIcon.png", fit: BoxFit.cover),
              Text(
                message, 
                style: CustomTextStyles.m3TitleLarge(), 
                textAlign: TextAlign.center
              ),
              SizedBox(height: 20.h),
            ],
          )
        );
      },
    );
  }
}

class _SearchFilmContent extends StatelessWidget {
  final Map<String, List<FilmEntity>?>? filmCollectionsMap;

  const _SearchFilmContent({required this.filmCollectionsMap});

  void onSearchSubmitted(String keyword, BuildContext context) {
    context.router.push(SearchedFilmsRoute(keyword: keyword, appBarTitle: "Поиск: $keyword"));
  }

  void onFilterSubmitted(BuildContext context) {
    context.router.push(FilterFilmRoute());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomSearchBar(
            onSearchSubmitted: onSearchSubmitted,
            onFilterSubmitted: onFilterSubmitted),
        SizedBox(height: 10.h),
        Expanded(child: _CollectionsList(filmCollectionsMap: filmCollectionsMap)),
      ],
    );
  }
}

class _CollectionsList extends StatelessWidget {
  final Map<String, List<FilmEntity>?>? filmCollectionsMap;

  const _CollectionsList({required this.filmCollectionsMap});

  @override
  Widget build(BuildContext context) {
    final filmCollectionsNamesList = FilmCollectionNames.filmCollectionNames;
    return ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return Column(
            children: [
              Row(
                children: [
                  Text(
                    _switchCollectionName(filmCollectionsNamesList[index]),
                    style: CustomTextStyles.m3TitleLarge()
                  ),
                  IconButton(
                      onPressed: () {
                        context.router.push(SearchedFilmsRoute(
                            nameCollection: filmCollectionsNamesList[index],
                            appBarTitle: filmCollectionsNamesList[index]));
                      },
                      icon: Icon(Icons.arrow_forward, color: AppColors.primaryScheme))
                ],
              ),
              SizedBox(
                  height: 185.h,
                  child: _CollectionFilmsList(
                      filmCollectionsMap: filmCollectionsMap,
                      filmCollectionsName: filmCollectionsNamesList[index]))
            ],
          );
        },
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemCount: FilmCollectionNames.filmCollectionNames.length);
  }

  String _switchCollectionName(String collectionName){
    String collectionNameFormated;
    switch(collectionName){
      case("TOP_POPULAR_MOVIES"): collectionNameFormated = "Популярные фильмы"; break;
      case("POPULAR_SERIES"): collectionNameFormated = "Популярные сериалы"; break;
      case("TOP_250_MOVIES"): collectionNameFormated = "Топ 250: фильмы"; break;
      case("TOP_250_TV_SHOWS"): collectionNameFormated = "Топ 250: сериалы"; break;
      default: collectionNameFormated = collectionName;
    }
    return collectionNameFormated;
  }
}

class _CollectionFilmsList extends StatelessWidget {
  final Map<String, List<FilmEntity>?>? filmCollectionsMap;
  final String filmCollectionsName;

  const _CollectionFilmsList({required this.filmCollectionsMap, required this.filmCollectionsName});

  @override
  Widget build(BuildContext context) {
    List<FilmEntity> filmEntityList = filmCollectionsMap![filmCollectionsName]!;

    return BlocBuilder<WatchFilmCollectionLinksCubit, Set<int>>(
      builder: (context, savedFilmIds) {
        return ListView.separated(
            addAutomaticKeepAlives: false,
            addSemanticIndexes: false,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final film = filmEntityList[index];
              final isSaved = savedFilmIds.contains(film.kinopoiskId);
              return _FilmCard(film: film, isSaved: isSaved);
            },
            separatorBuilder: (context, index) => SizedBox(width: 12.w),
            itemCount: min(filmCollectionsMap![filmCollectionsName]!.length, 10));
      },
    );
  }
}

class _FilmCard extends StatelessWidget {
  final FilmEntity film;
  final bool isSaved;
  
  const _FilmCard({required this.film, required this.isSaved});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        enableFeedback: false,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          if (film.kinopoiskId != null) {
            context.router.push(FilmInformationRoute(
                filmId: film.kinopoiskId!,
                filmName: film.nameRu ?? film.nameOriginal.toString()));
          } else {
            Fluttertoast.showToast(
              backgroundColor: Colors.red,
              msg: "Не удалось получить информацию о фильме"
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CachedImageWidget(
              urlImage: film.posterUrl, 
              rating: film.ratingKinopoisk,
              filmIsSaved: isSaved,
            ),
            SizedBox(height: 5.h),
            SizedBox(
              width: 96.w,
              child: Text(
                film.nameRu!,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                style: CustomTextStyles.m3LabelLarge()
              ),
            )
          ],
        ),
    );
  }
}

class _CachedImageWidget extends StatelessWidget {
  final String? urlImage;
  final num? rating;
  final bool filmIsSaved;

  const _CachedImageWidget({
    required this.urlImage,
    required this.rating,
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
              placeholder: (context, url) => Container(color: AppColors.secondaryThemeGrey),
              errorWidget: (context, url, error) => const Icon(Icons.error, color: AppColors.secondaryThemeGrey,),
            ),
            _RatingIcon(rating: rating),
            if(filmIsSaved)
            Positioned(
              top: 6.h,
              left: 4.w,
              child: Container(
                width: 22.w,
                height: 20.h,
                decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(5.0.h)),
                child: Icon(
                  Icons.save_rounded, 
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
