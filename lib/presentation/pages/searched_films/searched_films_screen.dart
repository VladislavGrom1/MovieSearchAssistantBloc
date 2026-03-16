import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/searched_films/searched_films_bloc.dart';

@RoutePage()
class SearchedFilmsScreen extends StatefulWidget {
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
  State<SearchedFilmsScreen> createState() => _SearchedFilmsScreenState();
}

class _SearchedFilmsScreenState extends State<SearchedFilmsScreen> {
  late final SearchedFilmsBloc _searchedFilmBloc;
  final ScrollController _scrollController = ScrollController();

  bool get isCollectionSearch => widget.nameCollection != null;

  @override
  void initState() {
    super.initState();
    _searchedFilmBloc = getIt<SearchedFilmsBloc>();
    _loadFirstPage();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchedFilmBloc.close();
    super.dispose();
  }

  void _onScroll() {
    final isNearBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;

    if (!isNearBottom) return;

    if (isCollectionSearch) {
      _searchedFilmBloc.add(
        LoadNextSearchedCollectionFilmsPage(
          nameCollection: widget.nameCollection!,
        ),
      );
    } else {
      _searchedFilmBloc.add(
        LoadNextSearchedFilterFilmsPage(
          keyword: widget.keyword,
          countries: widget.countries,
          genres: widget.genres,
          yearFrom: widget.yearFrom,
          yearTo: widget.yearTo,
        ),
      );
    }
  }

  void _loadFirstPage() {
    if (isCollectionSearch) {
      _searchedFilmBloc.add(
        DisplaySearchedCollectionFilms(
          nameCollection: widget.nameCollection!,
          page: 1,
        ),
      );
    } else {
      _searchedFilmBloc.add(
        DisplaySearchedFilterFilms(
          keyword: widget.keyword,
          countries: widget.countries,
          genres: widget.genres,
          yearFrom: widget.yearFrom,
          yearTo: widget.yearTo,
          page: 1,
        ),
      );
    }
  }

  Future<void> _onRefresh() async {
    _loadFirstPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.appBarTitle,
          style: const TextStyle(
            color: Colors.white,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: BlocBuilder<SearchedFilmsBloc, SearchedFilmsState>(
            bloc: _searchedFilmBloc,
            builder: (context, state) {
              if (state is SearchedFilmsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is SearchedFilmsLoadedFailure) {
                return Center(child: Text("${state.exceptionType} ${state.statusCode}"),
                );
              }

              if (state is SearchedFilmsLoadedSuccessful) {
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: _FilmsList(
                    state: state,
                    controller: _scrollController,
                  ),
                );
              }

              return const SizedBox();
            },
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

    return ListView.separated(
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

        return _FilmCard(film: film);
      },
    );
  }
}

class _FilmCard extends StatelessWidget {
  final dynamic film;

  const _FilmCard({required this.film});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (film.kinopoiskId != null) {
          context.router.push(
            FilmInformationRoute(filmId: film.kinopoiskId!),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Не удалось получить информацию о фильме"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Card(
        color: Colors.grey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140.h,
              width: 100.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.w),
                color: Colors.purple,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 5.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      film.nameRu ?? film.nameOriginal ?? "-",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 10.h),
                    Text(film.nameOriginal ?? "-"),
                    SizedBox(height: 10.h),
                    Text(
                      film.countries!.isEmpty
                          ? "${film.year}"
                          : "${film.countries}, ${film.year}",
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}