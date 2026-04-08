import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';
import 'package:movie_search_assistant_bloc/app/util/constants/country_ids.dart';
import 'package:movie_search_assistant_bloc/app/util/constants/genre_ids.dart';
import 'package:movie_search_assistant_bloc/domain/entities/filter_data.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/filter_film/filter_film_bloc.dart';

@RoutePage()
class FilterFilmScreen extends StatelessWidget {
  const FilterFilmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FilterFilmBloc>()..add(LoadFilters()),
      child: _FilterFilmView(),
    );
  }
}

class _FilterFilmView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.primaryThemeBlack,
        appBar: AppBar(
          title: Text(
            "Поиск фильмов", 
            style: CustomTextStyles.m3TitleLarge()
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<FilterFilmBloc, FilterFilmState>(
              builder: (context, state) {
                if (state is FiltersLoaded) {
                  return _FilterFilmContent(
                    country: state.country,
                    genre: state.genre,
                    yearRange: state.yearRange,
                  );
                }
                return const SizedBox();
              },
            ),
        ));
  }
}

class _FilterFilmContent extends StatelessWidget {
  final int? country;
  final int? genre;
  final (int, int)? yearRange;

  const _FilterFilmContent({required this.country, required this.genre, required this.yearRange});

  void goToSearchedFilmsScreen(BuildContext context, int? country, int? genre, (int, int)? yearRange) {
    context.router.push(
      SearchedFilmsRoute(
        keyword: null,
        countries: country == null ? null : List.filled(1, country),
        genres: genre == null ? null : List.filled(1, genre),
        yearFrom: yearRange?.$1,
        yearTo: yearRange?.$2,
        appBarTitle: "Результаты"
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final filterFilmBloc = context.read<FilterFilmBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _FilterButtonsList(
          country: country,
          genre: genre,
          yearRange: yearRange,
        ),
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsetsGeometry.only(left: 20.w, right: 20.w),
          child: ElevatedButton(
            style: ButtonStyle(
                minimumSize: WidgetStatePropertyAll(Size(double.infinity, 40.h)),
                alignment: AlignmentGeometry.center,
                backgroundColor: WidgetStatePropertyAll(AppColors.primaryScheme)),
            onPressed: () {
              goToSearchedFilmsScreen(context, country, genre, yearRange);
            },
            child: Text("Показать", style: CustomTextStyles.m3BodyLarge(color: AppColors.textWhite)),
          ),
        ),
        SizedBox(height: 10.h),
        Padding(
          padding: EdgeInsetsGeometry.only(left: 20.w, right: 20.w),
          child: ElevatedButton(
            style: ButtonStyle(
                minimumSize: WidgetStatePropertyAll(Size(double.infinity, 40.h)),
                alignment: AlignmentGeometry.center,
                backgroundColor: WidgetStatePropertyAll(AppColors.primaryThemeGrey)),
            onPressed: () {
              filterFilmBloc.add(ResetFilters());
            },
            child: Text("Сбросить поиск", style: CustomTextStyles.m3BodyLarge(color: AppColors.textWhite)),
          ),
        ),
      ],
    );
  }
}

class _FilterButtonsList extends StatelessWidget {
  final int? country;
  final int? genre;
  final (int, int)? yearRange;

  const _FilterButtonsList({required this.country, required this.genre, required this.yearRange});

  @override
  Widget build(BuildContext context) {
    final filterFilmBloc = context.read<FilterFilmBloc>();

    return SizedBox(
      height: 180.h,
      child: ListView.separated(
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final filterType = FilterType.values[index];
            return InkWell(
              enableFeedback: false,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () async {
                final filterTypeString = filterType.toString().split('.').last;
                final result = await context.router.push<dynamic>(
                    FilterListRoute(filterType: filterTypeString));
                filterFilmBloc.add(
                    UpdateFilterValue(filterType: filterType, value: result));
              },
              child: Padding(
                padding: EdgeInsetsGeometry.only(left: 20.w, right: 20.w),
                child: Container(
                  height: 48.h,
                  width: double.infinity,
                  color: AppColors.primaryThemeBlack,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_filterTypeToString(filterType),
                          style: CustomTextStyles.m3BodyLarge()),
                      Text(
                          _showSelectedFilter(filterType, country, genre, yearRange),
                          style: CustomTextStyles.m3BodyLarge(color: AppColors.primaryScheme)),
                    ],
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => Divider(color: AppColors.primaryScheme),
          itemCount: 3),
    );
  }

  String _showSelectedFilter(
      FilterType type, int? country, int? genre, (int, int)? years) {
    switch (type) {
      case FilterType.countries:
        if (country == null) return "Все страны";
        final entry = CountriesIds.countriesMap.entries
            .firstWhere((entry) => entry.value == country);
        return entry.key;
      case FilterType.genres:
        if (genre == null) return "Все жанры";
        final entry = GenresIds.genresMap.entries
            .firstWhere((entry) => entry.value == genre);
        return entry.key;
      case FilterType.years:
        if (years == null) return "Все годы";
        if (years.$1 == years.$2) return years.$1.toString();
        return "${years.$1}-${years.$2}";
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
}

