import 'package:flutter/material.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';

class CustomTextStyles {
  
  static TextStyle m3FilmTitle({Color? color}){
    return TextStyle(
      fontSize: 12,
      height: 1,
      letterSpacing: 0.1,
      fontWeight: FontWeight.w800,
      color: color ?? AppColors.textGrey,
    );
  }

  static TextStyle m3FilmRating({Color? color}){
    return TextStyle(
      fontSize: 12,
      height: 1,
      letterSpacing: 0.1,
      fontWeight: FontWeight.w800,
      color: color ?? AppColors.textGrey,
    );
  }

  static TextStyle m3ActionText({Color? color}){
    return TextStyle(
      fontSize: 16,
      height: 1,
      letterSpacing: 0.1,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.textGrey
    );
  }

  static TextStyle m3Content({Color? color}){
    return TextStyle(
      fontSize: 16,
      height: 1.3,
      letterSpacing: 0.1,
      fontWeight: FontWeight.w500,
      color: color ?? AppColors.textGrey
    );
  }

  static TextStyle m3Title({Color? color}){
    return TextStyle(
      fontSize: 22,
      height: 1,
      letterSpacing: 0,
      fontWeight: FontWeight.w800,
      color: color ?? AppColors.textGrey,
    );
  }

  static TextStyle m3Headline({Color? color}){
    return TextStyle(
      fontSize: 28,
      height: 28/36,
      letterSpacing: 0,
      fontWeight: FontWeight.w700,
      color: color ?? AppColors.textGrey
    ); 
  }

  static TextStyle m3Body({Color? color}){
    return TextStyle(
      fontSize: 15,
      height: 1.2,
      letterSpacing: 0.25,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.textGrey
    );
  }
}
