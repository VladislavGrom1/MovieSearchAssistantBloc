import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_card_entity.dart';
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
  final int page;
  
  const SearchedFilmsScreen({
    super.key,
    this.nameCollection,
    this.keyword,
    this.countries,
    this.genres,
    this.yearFrom,
    this.yearTo,
    required this.appBarTitle,
    required this.page
  });

  @override
  State<SearchedFilmsScreen> createState() => _SearchedFilmsScreenState();
}

// TODO: Реализовать пагинацию 

class _SearchedFilmsScreenState extends State<SearchedFilmsScreen> {
  final _searchedFilmsBloc = getIt<SearchedFilmsBloc>();

  @override
  void initState() {
    super.initState();
    if(widget.nameCollection != null){
      _searchedFilmsBloc.add(
        DisplaySearchedCollectionFilms(
          nameCollection: widget.nameCollection!, 
          page: 1
      ));
    } else{
      _searchedFilmsBloc.add(DisplaySearchedFilterFilms(
        keyword: widget.keyword,
        countries: widget.countries,
        genres: widget.genres,
        yearFrom: widget.yearFrom,
        yearTo: widget.yearTo,
        page: widget.page
      ));
    }
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
                      _searchedFilmsBloc.add(DisplaySearchedFilterFilms(
                        keyword: widget.keyword,
                        countries: widget.countries,
                        genres: widget.genres,
                        yearFrom: widget.yearFrom,
                        yearTo: widget.yearTo,
                        page: widget.page
                      ));
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
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(child: _buildFilterFilms(state.searchedFilms)),
                            ],
                          );
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

  Widget _buildFilterFilms(List<FilmCardEntity> filterFilms){
    return ListView.separated(
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {},
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
                          filterFilms[index].nameRu == null ? filterFilms[index].nameOriginal.toString() : filterFilms[index].nameRu.toString(), 
                          //style: CustomTextStyles.m3TitleLarge2(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2),
                        SizedBox(height: 10.h),
                        Text(
                          filterFilms[index].nameOriginal == null ? "-" : filterFilms[index].nameOriginal.toString(),
                          //style: CustomTextStyles.m3BodySmall(),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          filterFilms[index].countries!.isEmpty ? "${filterFilms[index].year}" : "${filterFilms[index].countries.toString()}, ${filterFilms[index].year}",
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
        itemCount: filterFilms.length);
  }
}