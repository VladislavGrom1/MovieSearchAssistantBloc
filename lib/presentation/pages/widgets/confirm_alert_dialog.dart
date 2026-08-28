import 'package:flutter/material.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';

class ConfirmAlertDialog extends StatelessWidget {
  final String titleText;
  final Widget content;
  final String actionText;
  final VoidCallback actionFunc;

  const ConfirmAlertDialog({
    super.key,
    required this.titleText,
    required this.content,
    required this.actionText,
    required this.actionFunc,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.primaryThemeBlack,
      title: Text(titleText, style: CustomTextStyles.m3Title()),
      content: content,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Отмена', style: CustomTextStyles.m3Body()),
        ),
        TextButton(
          onPressed: () {
            actionFunc();
            Navigator.pop(context);
          },
          child: Text(actionText, style: CustomTextStyles.m3Body(color: AppColors.primaryScheme)),
        )
      ],
    );
  }
}