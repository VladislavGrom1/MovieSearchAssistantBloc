import 'package:flutter/material.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';

class ErrorMessageWidget extends StatelessWidget {
  final String message;

  const ErrorMessageWidget({
    super.key,
    required this.message
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsetsGeometry.symmetric(horizontal: 20),
            child: Column(
              children: [
                Image.asset(
                  width: 350,
                  "assets/icons/errorIcon.png", 
                  fit: BoxFit.cover
                ),
                Text(
                  "Что-то пошло не так",
                  style: CustomTextStyles.m3Title(),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  message, 
                  style: CustomTextStyles.m3Body(), 
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
                const SizedBox(height: 20)
              ],
            ),
          )
        );
      },
    );
  }
}