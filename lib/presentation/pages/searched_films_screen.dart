import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/search_films/cubit/watch_saved_films_status_cubit.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/searched_films/searched_films_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/custom_refresh_indicator.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/error_message_widget.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/film_list_card.dart';

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
          create: (_) => getIt<WatchSavedFilmsStatusCubit>(),
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
      floatingActionButton: FloatingActionButton(
          heroTag: 'searched-films-home',
          tooltip: 'Вернуться к началу',
          onPressed: () {
            context.router.popUntilRoot();
          },
          backgroundColor: AppColors.primaryScheme,
          foregroundColor: AppColors.primaryThemeBlack,
          child: const Icon(Icons.home),
      ),
      appBar: AppBar(
        title: Text(
          widget.appBarTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: CustomTextStyles.m3ActionText(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
            child: CustomRefreshIndicator(
              onRefresh: _onRefresh,
              child: BlocBuilder<SearchedFilmsBloc, SearchedFilmsState>(
                builder: (context, state) {
                  if (state is SearchedFilmsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
              
                  if (state is SearchedFilmsLoadedFailure) {
                    return Center(child: ErrorMessageWidget(message: state.message));
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
 
    return ListView.separated(
      addAutomaticKeepAlives: false,
      addSemanticIndexes: false,
      physics: const BouncingScrollPhysics(),
      controller: controller,
      itemCount: films.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index >= films.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return FilmListCard(film: films[index]);
      },
    );
  }
}
