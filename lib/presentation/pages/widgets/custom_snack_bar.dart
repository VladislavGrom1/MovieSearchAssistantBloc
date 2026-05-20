import 'package:flutter/material.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';

class CustomSnackBar {
  final String message;
  final Color color;
  final Duration? duration;

  const CustomSnackBar({
    required this.message,
    required this.color,
    this.duration
  });

  SnackBar build(BuildContext context) {
    return SnackBar(
      content: Text(
        message,
        style: CustomTextStyles.m3Content(color: AppColors.textWhite),
      ),
      backgroundColor: color,
      duration: duration ?? Duration(seconds: 3),
    );
  }

  void show(BuildContext context){
    ScaffoldMessenger.of(context).showSnackBar(build(context));
  }
}