import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/domain/entities/filter_data.dart';

@RoutePage()
class FilterListScreen extends StatefulWidget {
  const FilterListScreen({
    super.key,
    @PathParam("filterType") required this.filterType
  });

  final dynamic filterType;

  @override
  State<FilterListScreen> createState() => _FilterListScreenState();
}

class _FilterListScreenState extends State<FilterListScreen> {
  late FilterData filterData;

  @override
  void initState() {
    filterData = FilterData.fromType(widget.filterType.name);
    super.initState();
  }

  FilterData getFilterData(String filterType) {
    return FilterData.fromType(filterType);
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
          title: Text(_filterTypeToString(widget.filterType), style: TextStyle(color: Colors.white)),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.separated(
                  itemBuilder: (context, index) => InkWell(
                    onTap: () {
                      context.router.pop(filterData.items.values.elementAt(index));
                    },
                    child: Container(
                        height: 48.h,
                        width: double.maxFinite,
                        color: Colors.purple,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(filterData.items.keys.elementAt(index), style: TextStyle(color: Colors.white)),
                          ],
                        ),
                    ),
                  ),
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.white,
                  ), 
                  itemCount: filterData.items.length
                ),
            )
          ]
        ),
          ),
        ));
  }
}