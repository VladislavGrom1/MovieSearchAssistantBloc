import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/app/util/cache_manager/film_image_cache_manager.dart';
import 'package:movie_search_assistant_bloc/app/util/constants/film_collection_names.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/search_films/search_films_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/search_films/widgets/custom_search_bar.dart';

@RoutePage()
class SearchFilmScreen extends StatelessWidget {
  const SearchFilmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SearchFilmsBloc>()..add(DisplayFilmCollections()),
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
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                          return Center(child: Text("${state.exceptionType} ${state.statusCode}"));
                        }

                        if (state is CollectionsFilmsLoadedSuccessful) {
                          return _SearchFilmContent(filmCollectionsMap: state.filmCollectionsMap);
                        }
                        return SizedBox();
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ));
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
        CustomSearchBar(onSearchSubmitted: onSearchSubmitted, onFilterSubmitted: onFilterSubmitted),
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
                  Text(filmCollectionsNamesList[index]),
                  IconButton(
                      onPressed: () {
                        context.router.push(SearchedFilmsRoute(
                            nameCollection: filmCollectionsNamesList[index],
                            appBarTitle: filmCollectionsNamesList[index]));
                      },
                      icon: Icon(Icons.arrow_forward, color: Colors.purple))
                ],
              ),
              SizedBox(
                  height: 185.h,
                  child: _CollectionFilmsList(filmCollectionsMap: filmCollectionsMap, filmCollectionsName: filmCollectionsNamesList[index]))
            ],
          );
        },
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemCount: FilmCollectionNames.filmCollectionNames.length);
  }
}

class _CollectionFilmsList extends StatelessWidget {
  final Map<String, List<FilmEntity>?>? filmCollectionsMap;
  final String filmCollectionsName;

  const _CollectionFilmsList({
    required this.filmCollectionsMap, 
    required this.filmCollectionsName
  });

  @override
  Widget build(BuildContext context) {
    List<FilmEntity> filmEntityList = filmCollectionsMap![filmCollectionsName]!;

    return ListView.separated(
        addAutomaticKeepAlives: false,
        addSemanticIndexes: false,
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => _FilmCard(film: filmEntityList[index]),
        separatorBuilder: (context, index) => SizedBox(width: 12.w),
        itemCount: min(filmCollectionsMap![filmCollectionsName]!.length, 10));
  }
}

class _FilmCard extends StatelessWidget {
  final FilmEntity film;
  const _FilmCard({required this.film});

  @override
  Widget build(BuildContext context) {
    return InkWell(
            onTap: () {
              if (film.kinopoiskId != null) {
                context.router.push(FilmInformationRoute(
                    filmId: film.kinopoiskId!,
                    filmName: film.nameRu ?? film.nameOriginal.toString()
                  ));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Не удалось получить информацию о фильме"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CachedImageWidget(urlImage: film.posterUrlPreview),
                SizedBox(height: 5.h),
                SizedBox(
                  width: 96.w,
                  child: Text(
                    film.nameRu!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    style: TextStyle(
                        fontSize: 11,
                        height: 11 / 9,
                        letterSpacing: 0,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          );
  }
}

class _CachedImageWidget extends StatelessWidget {
  final String? urlImage;

  const _CachedImageWidget({
    required this.urlImage
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.w),
      child: RepaintBoundary(
        child: CachedNetworkImage(
          imageUrl: urlImage ?? '',
          cacheManager: FilmImageCacheManager.instance,
          memCacheWidth: 100,
          memCacheHeight: 140,
          fit: BoxFit.cover,
          width: 100.w,
          height: 140.h,
          placeholder: (context, url) => Container(color: Colors.grey[200]),
          errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
      ),
      );
  }
}
