import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/app/util/constants/country_ids.dart';
import 'package:movie_search_assistant_bloc/app/util/constants/filter_labels.dart';
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

  // TODO: Реализовать передачу параметра (Тип фильтрации) при роуте на FilterListScreen
  // TODO: Реализовать получение результата при переходе обратно

  @override
  void initState() {
    super.initState();
    // Загружаем фильтры при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _filterFilmBloc.add(LoadFilters());
    });
  }

  String _showSelectedFilter(FilterType type, FiltersLoaded state) {
    switch (type) {
      case FilterType.countries:
        if(state.country == -1) return "Все страны";
        final entry = CountriesIds.countriesMap.entries.firstWhere((entry) => entry.value == state.country);
        return entry.key;
      case FilterType.genres:
        if(state.genre == -1) return "Все жанры";
        final entry = GenresIds.genresMap.entries.firstWhere((entry) => entry.value == state.genre);
        return entry.key;
      case FilterType.years:
        return state.years;
    }
  }

  String _filterTypeToString(FilterType type) {
    switch (type) {
      case FilterType.countries: return 'Страны';
      case FilterType.genres: return 'Жанры';
      case FilterType.years: return 'Годы';
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                BlocBuilder<FilterFilmBloc, FilterFilmState>(
                  bloc: _filterFilmBloc,
                  builder: (context, state) {

                    if(state is FiltersLoaded){
                      return SizedBox(
                        height: 180.h,
                        child: ListView.separated(
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final filterType = FilterType.values[index];

                              return InkWell(
                                  onTap: () async {
                                    final result = await context.router.push<dynamic>(FilterListRoute(filterType: filterType));
                                    if (result != null){
                                      _filterFilmBloc.add(UpdateFilterValue(filterType: filterType, value: result));
                                    }
                                  },
                                  child: Container(
                                    height: 48.h,
                                    width: double.infinity,
                                    color: Colors.purple,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _filterTypeToString(filterType),
                                          style:TextStyle(color: Colors.white)
                                        ),
                                        Text(
                                          _showSelectedFilter(filterType, state), 
                                          style:TextStyle(color: Colors.white)
                                        ),
                                        // Obx(() => Text(
                                        //   controller.switchFilterData(index),
                                        //   style: CustomTextStyles.m3BodyLarge(color: AppColors.primaryScheme)))
                                      ],
                                    ),
                                  ),
                                );
                            },
                            separatorBuilder: (context, index) => Divider(
                                  color: Colors.purple,
                                ),
                            itemCount: 3)
                      );
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                ),
                SizedBox(height: 20.h),
                ElevatedButton(
                  style: ButtonStyle(
                      minimumSize:
                          WidgetStatePropertyAll(Size(double.infinity, 40.h)),
                      alignment: AlignmentGeometry.center,
                      backgroundColor: WidgetStatePropertyAll(Colors.purple)),
                  onPressed: () {
                    // Get.toNamed(
                    //   Routes.searchFiltersScreen,
                    //   arguments: {
                    //     "id": "SwitchFilterScreen",
                    //     "countries": controller.countryValueToBuiltList(),
                    //     "genres": controller.genreValueToBuiltList(),
                    //     "years": controller.getYearsValue()
                    //     },
                    //   id: NavigatorIds.searchHome);
                  },
                  child:
                      Text("Показать", style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      minimumSize:
                          WidgetStatePropertyAll(Size(double.infinity, 40.h)),
                      alignment: AlignmentGeometry.center,
                      backgroundColor: WidgetStatePropertyAll(Colors.purple)),
                  onPressed: () {
                    //controller.resetFilters();
                  },
                  child: Text("Сбросить поиск",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        )
      );
  }
}
