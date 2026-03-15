
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
  final _searchedFilmsBloc = getIt<SearchedFilmsBloc>();
  final _scrollController = ScrollController();
  bool isSearchCollectionFilms = false;

  @override
  void initState() {
    super.initState();
    isSearchCollectionFilms = widget.nameCollection != null;

    if(isSearchCollectionFilms){
      searchCollectionFilms();
    } else{
      searchFilterFilms();
    }

    scrollControllerAddListener();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void scrollControllerAddListener(){
    _scrollController.addListener(() {
      final isReadyToLoadMore = _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200;

      if (isReadyToLoadMore && isSearchCollectionFilms) {
        loadNextSearchedCollectionFilms();
      }
      if (isReadyToLoadMore && !isSearchCollectionFilms){
        loadNextSearchedFilterFilms();
      }
    });
  }

  void loadNextSearchedFilterFilms() {
    _searchedFilmsBloc.add(LoadNextSearchedFilterFilmsPage(
      keyword: widget.keyword,
      countries: widget.countries,
      genres: widget.genres,
      yearFrom: widget.yearFrom,
      yearTo: widget.yearTo
    ));
  }

  void loadNextSearchedCollectionFilms() {
    _searchedFilmsBloc.add(LoadNextSearchedCollectionFilmsPage(
      nameCollection: widget.nameCollection!
    ));
  }

  void searchCollectionFilms(){
    _searchedFilmsBloc.add(DisplaySearchedCollectionFilms(
        nameCollection: widget.nameCollection!, 
        page: 1
    ));
  }

  void searchFilterFilms(){
    _searchedFilmsBloc.add(DisplaySearchedFilterFilms(
        keyword: widget.keyword,
        countries: widget.countries,
        genres: widget.genres,
        yearFrom: widget.yearFrom,
        yearTo: widget.yearTo,
        page: 1
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(widget.appBarTitle, style: TextStyle(
            color: Colors.white,
            overflow: TextOverflow.ellipsis
          )),
        ),
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
                      if(isSearchCollectionFilms){
                        searchCollectionFilms();
                      } else{
                        searchFilterFilms();
                      }
                    },
                    child: BlocBuilder<SearchedFilmsBloc, SearchedFilmsState>(
                      bloc: _searchedFilmsBloc,
                      builder: (context, state) {
                        if (state is SearchedFilmsLoading) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (state is SearchedFilmsLoadedFailure) {
                          return Center(child: Text("${state.exceptionType} ${state.statusCode}"));
                        }
                        if (state is SearchedFilmsLoadedSuccessful) {
                          return _buildSearchedFilms(state);
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

  // TODO: Доработать отображение карточки фильмов (не все данные + покрытие NULL значений)

  Widget _buildSearchedFilms(SearchedFilmsLoadedSuccessful state){
    final searchedFilms = state.searchedFilms;
    
    return ListView.separated(
        controller: _scrollController,
        itemBuilder: (context, index) {
          
          if (index >= state.searchedFilms.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          
          final searchedFilm = searchedFilms[index];

          return InkWell(
            onTap: () {
              if(searchedFilm.kinopoiskId != null){
                context.router.push(FilmInformationRoute(filmId: searchedFilm.kinopoiskId!));
              } else{
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 5.h),
                        Text(
                          searchedFilm.nameRu == null 
                          ? searchedFilm.nameOriginal.toString() 
                          : searchedFilm.nameRu.toString(), 
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2),
                        SizedBox(height: 10.h),
                        Text(
                          searchedFilm.nameOriginal == null 
                          ? "-" 
                          : searchedFilm.nameOriginal.toString(),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          searchedFilm.countries!.isEmpty 
                          ? "${searchedFilm.year}" 
                          : "${searchedFilm.countries.toString()}, ${searchedFilm.year}",
                        ),
                        SizedBox(height: 10.h),
                      ]
                    ),
                  )
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemCount: state.searchedFilms.length + (state.isLoadingMore ? 1 : 0),
        );
  }
}