import 'package:flutter/material.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.textButton,
    required this.enabled, 
    required this.onPressed,
  });
 
  final bool enabled;
  final String textButton;
  final VoidCallback? onPressed;
  
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: enabled
            ? const LinearGradient(
                colors: [AppColors.primaryScheme, Color(0xFFb583f2)],
              )
            : null,
        color: enabled ? null : AppColors.primaryThemeGrey,
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: AppColors.primaryScheme.withOpacity(0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Center(
            child: Text(
              textButton,
              style: CustomTextStyles.m3Content(
                color: enabled ? Colors.white : AppColors.textDarkGrey,
              ).copyWith(letterSpacing: 0.3, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}