import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/core/router/app_router.gr.dart';

@RoutePage()
class FilterFilmScreen extends StatelessWidget {
  const FilterFilmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Text("FilmFilterScreen", style: TextStyle(color: Colors.white))),
            SizedBox(height: 10.h),
            TextButton(
              onPressed: () {
                context.router.push(FilterListRoute(filterType: "Страны"));
            }, 
              child: Text("Фильтр \"Страны\"", style: TextStyle(color: Colors.white))
            ),
            SizedBox(height: 10.h),
            TextButton(
              onPressed: () {
                context.router.push(FilterListRoute(filterType: "Жанры"));
            }, 
              child: Text("Фильтр \"Жанры\"", style: TextStyle(color: Colors.white))
            ),
            SizedBox(height: 10.h),
            TextButton(
              onPressed: () {
                context.router.push(FilterListRoute(filterType: "Годы"));
            }, 
              child: Text("Фильтр \"Годы\"", style: TextStyle(color: Colors.white))
            ),
            SizedBox(height: 10.h),
            TextButton(
              onPressed: () {
                context.router.push(SearchedFilmsRoute());
            }, 
              child: Text("Показать найденные фильмы", style: TextStyle(color: Colors.white))
            )
          ],
        ),
      )
    );
  }
}