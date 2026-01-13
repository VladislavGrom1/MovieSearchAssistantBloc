import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

@RoutePage()
class ChangeApiKeyScreen extends StatelessWidget {
  const ChangeApiKeyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.brown,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Text("ChangeApiKeyScreen", style: TextStyle(color: Colors.white))),
            SizedBox(height: 10.h),
            TextButton(
              onPressed: () {
                context.router.pop();
            }, 
              child: Text("Сохранить изменения", style: TextStyle(color: Colors.white))
            ),
          ],
        ),
      )
    );
  }
}