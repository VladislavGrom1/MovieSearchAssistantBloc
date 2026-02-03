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

  final String filterType;

  @override
  State<FilterListScreen> createState() => _FilterListScreenState();
}

class _FilterListScreenState extends State<FilterListScreen> {
  late FilterData filterData;

  @override
  void initState() {
    filterData = FilterData.fromType(widget.filterType);
    super.initState();
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
    switch (_stringToFilterType(widget.filterType)) {
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
          title: Text(_filterTypeToString(), style: TextStyle(color: Colors.white)),
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