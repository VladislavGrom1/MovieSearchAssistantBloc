import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/core/router/app_router.gr.dart';

@RoutePage()
class WatchedCollectionScreen extends StatelessWidget {
  const WatchedCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Text("WatchedCollectionScreen", style: TextStyle(color: Colors.white))),
            SizedBox(height: 10.h),
            TextButton(
              onPressed: () {
                context.router.push(FilmInformationRoute(filmId: "2"));
            }, 
            child: Text("Посмотреть информацию о фильме (2)", style: TextStyle(color: Colors.white))
            )
          ],
        ),
      )
    );
  }
}