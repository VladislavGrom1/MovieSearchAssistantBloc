import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/app/util/constants/film_collection_names.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_card_entity.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/search_films/search_films_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/search_films/widgets/custom_search_bar.dart';

@RoutePage()
class SearchFilmScreen extends StatefulWidget {
  const SearchFilmScreen({super.key});

  @override
  State<SearchFilmScreen> createState() => _SearchFilmScreenState();
}

class _SearchFilmScreenState extends State<SearchFilmScreen> {
  final _searchFilmBloc = getIt<SearchFilmsBloc>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFilmBloc.add(DisplayFilmCollectionsEvent());
    });
  }

  void onSearchSubmitted(String keyword){
    context.router.push(SearchedFilmsRoute(keyword: keyword, page: 1, appBarTitle: "Поиск: $keyword"));
  }

  void onFilterSubmitted(){
    context.router.push(FilterFilmRoute());
  }

  @override
  Widget build(BuildContext context) {
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
                      _searchFilmBloc.add(DisplayFilmCollectionsEvent());
                    },
                    child: BlocBuilder<SearchFilmsBloc, SearchFilmsState>(
                      bloc: _searchFilmBloc,
                      builder: (context, state) {
                        if (state is SearchFilmsLoading) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (state is CollectionsFilmsLoadedFailure) {
                          return Center(child: Text("${state.exceptionType} ${state.statusCode}"));
                        }

                        if (state is CollectionsFilmsLoadedSuccessful) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CustomSearchBar(onSearchSubmitted: onSearchSubmitted, onFilterSubmitted: onFilterSubmitted),
                              SizedBox(height: 10.h),
                              Expanded(child: _buildFilmCollections(state.filmCollectionsMap)),
                            ],
                          );
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

  Widget _buildFilmCollections(
      Map<String, List<FilmCardEntity>?>? filmCollectionsMap) {
    final filmCollectionsNamesList = FilmCollectionNames.filmCollectionNames;
    return ListView.separated(
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
                          page: 1, 
                          appBarTitle: filmCollectionsNamesList[index]
                        ));
                      },
                      icon: Icon(Icons.arrow_forward, color: Colors.purple))
                ],
              ),
              SizedBox(
                  height: 185.h,
                  child: _buildFilmCollection(filmCollectionsMap, filmCollectionsNamesList[index]))
            ],
          );
        },
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemCount: FilmCollectionNames.filmCollectionNames.length);
  }

  Widget _buildFilmCollection(
      Map<String, List<FilmCardEntity>?>? filmCollectionsMap,
      String filmCollectionsName) {
    List<FilmCardEntity> filmCardEntityList =
        filmCollectionsMap![filmCollectionsName]!;

    return ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return InkWell(
            // TODO: Добавить переход на экран FilmInformation
            onTap: () {
              context.router.push(FilmInformationRoute(filmId: "0"));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 140.h,
                  width: 90.w,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.w),
                      color: Colors.purple),
                ),
                SizedBox(height: 5.h),
                SizedBox(
                  width: 96.w,
                  child: Text(
                    filmCardEntityList[index].nameRu!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    style: TextStyle(
                        fontSize: 11,
                        height: 11 / 9,
                        letterSpacing: 0,
                        fontWeight: FontWeight.bold
                      ),
                  ),
                )
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => SizedBox(width: 12.w),
        itemCount: filmCollectionsMap[filmCollectionsName]!.length);
  }
}
