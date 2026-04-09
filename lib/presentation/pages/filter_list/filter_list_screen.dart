import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';
import 'package:movie_search_assistant_bloc/domain/entities/filter_data.dart';

@RoutePage()
class FilterListScreen extends StatelessWidget {
  const FilterListScreen({
    super.key,
    @PathParam("filterType") required this.filterType
  });

  final String filterType;

  @override
  Widget build(BuildContext context) {
    final filterData = FilterData.fromType(filterType);
    return Scaffold(
        backgroundColor: AppColors.primaryThemeBlack,
        appBar: AppBar(
          title: Text(_filterTypeToString(), style: CustomTextStyles.m3TitleLarge()),
        ),
        body: SafeArea(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.separated(
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) => InkWell(
                    enableFeedback: false,
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      context.router.pop(filterData.items.values.elementAt(index));
                    },
                    child: Padding(
                      padding: EdgeInsetsGeometry.only(left: 20.w, right: 20.w),
                      child: Container(
                          height: 48.h,
                          width: double.maxFinite,
                          color: AppColors.primaryThemeBlack,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(filterData.items.keys.elementAt(index), style: CustomTextStyles.m3BodyLarge()),
                            ],
                          ),
                      ),
                    ),
                  ),
                  separatorBuilder: (context, index) => Divider(color: AppColors.primaryScheme), 
                  itemCount: filterData.items.length
                ),
            )
          ]
        ),
        ));
  }

  FilterType _stringToFilterType(String type) {
    switch (type) {
      case 'countries':
        return FilterType.countries;
      case 'genres':
        return FilterType.genres;
      case 'years':
        return FilterType.years;
      default:
        throw ArgumentError('Unknown filter type: $type');
    }
  }

  String _filterTypeToString() {
    switch (_stringToFilterType(filterType)) {
      case FilterType.countries:
        return 'Страны';
      case FilterType.genres:
        return 'Жанры';
      case FilterType.years:
        return 'Годы';
    }
  }
}