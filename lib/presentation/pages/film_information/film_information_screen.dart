import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

@RoutePage()
class FilmInformationScreen extends StatelessWidget {
  const FilmInformationScreen({
    super.key, 
    @PathParam('filmId') required this.filmId,
  });

  final String filmId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Text("FilmInformationScreen", style: TextStyle(color: Colors.white))),
            SizedBox(height: 10.h),
            Center(child: Text("FilmId: $filmId", style: TextStyle(color: Colors.white))),
          ],
        ),
      )
    );
  }
}