import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';

@RoutePage()
class SearchFilmScreen extends StatelessWidget {
  const SearchFilmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Text("SearchFilmScreen", style: TextStyle(color: Colors.white))),
            SizedBox(height: 10.h),
            TextButton(
              onPressed: () {
                context.router.push(SearchedFilmsRoute());
            }, 
            child: Text("Найти фильмы", style: TextStyle(color: Colors.white))
            ),
            SizedBox(height: 10.h),
            TextButton(
              onPressed: () {
                context.router.push(FilterFilmRoute());
            }, 
            child: Text("Фильтр при поиске фильмов", style: TextStyle(color: Colors.white))
            ),
            SizedBox(height: 10.h),
            TextButton(
              onPressed: () {
                context.router.push(FilmInformationRoute(filmId: "0"));
            }, 
            child: Text("Посмотреть информацию о фильме (0)", style: TextStyle(color: Colors.white))
            )
          ],
        ),
      )
    );
  }
}