import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/app/util/constants/country_ids.dart';
import 'package:movie_search_assistant_bloc/app/util/constants/genre_ids.dart';
import 'package:movie_search_assistant_bloc/domain/entities/filter_data.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/filter_film/filter_film_bloc.dart';

@RoutePage()
class FilterFilmScreen extends StatefulWidget {
  const FilterFilmScreen({super.key});

  @override
  State<FilterFilmScreen> createState() => _FilterFilmScreenState();
}

class _FilterFilmScreenState extends State<FilterFilmScreen> {
  final _filterFilmBloc = getIt<FilterFilmBloc>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _filterFilmBloc.add(LoadFilters());
    });
  }

  String _showSelectedFilter(FilterType type, FiltersLoaded state) {
    switch (type) {
      case FilterType.countries:
        if (state.country == null) return "Все страны";
        final entry = CountriesIds.countriesMap.entries.firstWhere((entry) => entry.value == state.country);
        return entry.key;
      case FilterType.genres:
        if (state.genre == null) return "Все жанры";
        final entry = GenresIds.genresMap.entries
            .firstWhere((entry) => entry.value == state.genre);
        return entry.key;
      case FilterType.years:
        if (state.years == null) return "Все годы";
        return state.years!;
    }
  }

  String _filterTypeToString(FilterType type) {
    switch (type) {
      case FilterType.countries:
        return 'Страны';
      case FilterType.genres:
        return 'Жанры';
      case FilterType.years:
        return 'Годы';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Поиск фильмов", style: TextStyle(color: Colors.white)),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w),
            child: BlocBuilder<FilterFilmBloc, FilterFilmState>(
              bloc: _filterFilmBloc,
              builder: (context, state) {
                if (state is FiltersLoaded) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: 180.h,
                          child: ListView.separated(
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final filterType = FilterType.values[index];

                                return InkWell(
                                  onTap: () async {
                                    final filterTypeString = filterType.toString().split('.').last;
                                    final result = await context.router.push<dynamic>(FilterListRoute(filterType: filterTypeString));
                                    _filterFilmBloc.add(UpdateFilterValue(
                                          filterType: filterType,
                                          value: result
                                    ));
                                  },
                                  child: Container(
                                    height: 48.h,
                                    width: double.infinity,
                                    color: Colors.purple,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(_filterTypeToString(filterType),
                                            style:
                                                TextStyle(color: Colors.white)),
                                        Text(
                                            _showSelectedFilter(
                                                filterType, state),
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) => Divider(
                                    color: Colors.purple,
                                  ),
                              itemCount: 3)),
                      SizedBox(height: 20.h),
                      ElevatedButton(
                        style: ButtonStyle(
                            minimumSize: WidgetStatePropertyAll(
                                Size(double.infinity, 40.h)),
                            alignment: AlignmentGeometry.center,
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.purple)),
                        onPressed: () {
                          context.router.push(SearchedFilmsRoute(
                              keyword: null,
                              countries: state.country == null ? null : List.filled(1, state.country!),
                              genres: state.genre == null ? null : List.filled(1, state.genre!),
                              page: 1,
                              appBarTitle: "Результаты"
                              ));
                        },
                        child: Text("Показать",
                            style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                            minimumSize: WidgetStatePropertyAll(
                                Size(double.infinity, 40.h)),
                            alignment: AlignmentGeometry.center,
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.purple)),
                        onPressed: () {
                          _filterFilmBloc.add(ResetFilters());
                        },
                        child: Text("Сбросить поиск",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  );
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ));
  }
}
