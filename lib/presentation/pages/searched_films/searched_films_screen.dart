import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';
import 'package:movie_search_assistant_bloc/app/util/data_formatter.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/search_films/cubit/watch_film_collection_links_cubit.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/searched_films/searched_films_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/custom_refresh_indicator.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/error_message_widget.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/poster_film_image.dart';

@RoutePage()
class SearchedFilmsScreen extends StatelessWidget {
  final String? nameCollection;
  final String? keyword;
  final List<int>? countries;
  final List<int>? genres;
  final int? yearFrom;
  final int? yearTo;
  final String appBarTitle;

  const SearchedFilmsScreen({
    super.key,
    this.nameCollection,
    this.keyword,
    this.countries,
    this.genres,
    this.yearFrom,
    this.yearTo,
    required this.appBarTitle,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<SearchedFilmsBloc>()..add(LoadSearchedFilms(
                nameCollection: nameCollection,
                keyword: keyword,
                countries: countries,
                genres: genres,
                yearFrom: yearFrom,
                yearTo: yearTo)),
        ),
        BlocProvider(
          create: (_) => getIt<WatchFilmCollectionLinksCubit>(),
        ),
      ],
      child: _SearchedFilmView(appBarTitle: appBarTitle),
    );
  }
}

class _SearchedFilmView extends StatefulWidget {
  final String appBarTitle;

  const _SearchedFilmView({required this.appBarTitle});

  @override
  State<_SearchedFilmView> createState() => _SearchedFilmViewState();
}

class _SearchedFilmViewState extends State<_SearchedFilmView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<SearchedFilmsBloc>().add(LoadNextPage());
    }
  }

  Future<void> _onRefresh() async {
    context.read<SearchedFilmsBloc>().add(RefreshFilmsPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryThemeBlack,
      appBar: AppBar(
        title: Text(
          widget.appBarTitle,
          style: CustomTextStyles.m3TitleLarge(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: CustomRefreshIndicator(
              onRefresh: _onRefresh,
              child: BlocBuilder<SearchedFilmsBloc, SearchedFilmsState>(
                builder: (context, state) {
                  if (state is SearchedFilmsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
              
                  if (state is SearchedFilmsLoadedFailure) {
                    return ErrorMessageWidget(message: state.message);
                  }
              
                  if (state is SearchedFilmsLoadedSuccessful) {
                    return _FilmsList(
                        state: state,
                        controller: _scrollController,
                    );
                  }
              
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
    );
  }
}

class _FilmsList extends StatelessWidget {
  final SearchedFilmsLoadedSuccessful state;
  final ScrollController controller;

  const _FilmsList({
    required this.state,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final films = state.searchedFilms;

    return BlocBuilder<WatchFilmCollectionLinksCubit, Set<int>>(
      builder: (context, savedFilmIds) {
        return ListView.separated(
          addAutomaticKeepAlives: false,
          addSemanticIndexes: false,
          physics: const BouncingScrollPhysics(),
          controller: controller,
          itemCount: films.length + (state.isLoadingMore ? 1 : 0),
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            if (index >= films.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
    
            final film = films[index];
            final isSaved = savedFilmIds.contains(film.kinopoiskId);
    
            return _FilmCard(film: film, isSaved: isSaved);
          },
        );
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
          context.router.push(
            FilmInformationRoute(
                filmId: film.kinopoiskId!,
                filmName: film.nameRu ?? film.nameOriginal.toString()),
          );
        } else {
          Fluttertoast.showToast(
            backgroundColor: Colors.red,
            msg: "Не удалось получить информацию о фильме"
          );
        }
      },
      child: Card(
        color: AppColors.primaryThemeGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.w),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilmPosterImage(
              networkImageUrl: film.posterUrlPreview,
              kinopoiskRating: film.ratingKinopoisk,
              showSavedIcon: isSaved,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 5.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      film.nameRu ?? film.nameOriginal ?? "-",
                      maxLines: 2,
                      style: CustomTextStyles.m3TitleLarge2(),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      film.nameOriginal ?? film.nameRu ?? "-",
                      maxLines: 2,
                      style: CustomTextStyles.m3BodyMedium(),
                      overflow: TextOverflow.ellipsis,
                      ),
                    SizedBox(height: 10.h),
                    Text(
                      DataFormatter.formatCountriesAndYear(film.countries, film.year),
                      maxLines: 1,
                      style: CustomTextStyles.m3BodyMedium(color: AppColors.primaryScheme).copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      DataFormatter.formatGenres(film.genres),
                      maxLines: 1,
                      style: CustomTextStyles.m3BodyMedium().copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 7.w)
          ],
        ),
      ),
    );
  }
}
