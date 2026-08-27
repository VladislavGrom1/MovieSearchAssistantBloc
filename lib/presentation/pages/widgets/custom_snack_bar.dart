import 'package:flutter/material.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';

class CustomSnackBar {
  final String message;
  final Duration? duration;

  const CustomSnackBar({
    required this.message,
    this.duration
  });

  SnackBar build(BuildContext context) {
    return SnackBar(
      content: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 1),
        curve: Curves.easeInOutCubic,
        child: Text(
          message,
          style: CustomTextStyles.m3ActionText(color: AppColors.primaryThemeBlack),
        ),
      ),
      backgroundColor: AppColors.primaryScheme,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(16)
      ),
      duration: duration ?? Duration(seconds: 2, milliseconds: 500),
      animation: null,
    );
  }

  void show(BuildContext context){
    ScaffoldMessenger.of(context).showSnackBar(build(context));
  }
}
