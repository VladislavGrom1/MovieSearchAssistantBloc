import 'package:flutter/material.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';

class CustomRefreshIndicator extends StatelessWidget {
  final RefreshCallback onRefresh;
  final Widget child;

  const CustomRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      backgroundColor: AppColors.primaryThemeGrey,
      color: AppColors.primaryScheme,
      onRefresh: onRefresh,
      child: child
    );
  }
}