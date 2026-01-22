import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';

@RoutePage()
class FilterListScreen extends StatelessWidget {
  const FilterListScreen({
    super.key,
    @PathParam("filterType") required this.filterType
  });

  final String filterType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen,
      appBar: AppBar(
        title: Text(filterType, style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Text("FilterListScreen", style: TextStyle(color: Colors.white))),
            SizedBox(height: 10.h),
            TextButton(
              onPressed: () {
                context.router.pop(FilterFilmRoute());
            }, 
            child: Text("Фильтр №1", style: TextStyle(color: Colors.white))
            ),
            SizedBox(height: 10.h),
            TextButton(
              onPressed: () {
                context.router.pop(FilterFilmRoute());
            }, 
            child: Text("Фильтр №2", style: TextStyle(color: Colors.white))
            ),
            SizedBox(height: 10.h),
            TextButton(
              onPressed: () {
                context.router.pop(FilterFilmRoute());
            }, 
            child: Text("Фильтр №3", style: TextStyle(color: Colors.white))
            )
          ],
        ),
      )
    );
  }
}