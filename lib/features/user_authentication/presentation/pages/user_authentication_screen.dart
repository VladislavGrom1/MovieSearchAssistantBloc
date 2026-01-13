import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/core/router/app_router.gr.dart';

@RoutePage()
class UserAuthenticationScreen extends StatelessWidget {
  const UserAuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("UserAuthentication", style: TextStyle(color: Colors.white)),
            SizedBox(height: 20.h),
            TextButton(
              onPressed: () {
                context.router.replace(HomeRoute());
            }, 
            child: Text("Перейти на SearchFilmScreen", style: TextStyle(color: Colors.white))
            )
          ],
        ),
      )
    );
  }
}