import 'package:flutter/material.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';

class ConfirmAlertDialog extends StatelessWidget {
  final String titleText;
  final String contentText;
  final String actionText;
  final VoidCallback actionFunc;

  const ConfirmAlertDialog({
    super.key,
    required this.titleText,
    required this.contentText,
    required this.actionText,
    required this.actionFunc
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.primaryThemeBlack,
      title: Text(titleText, style: CustomTextStyles.m3TitleLarge()),
      content: Text(contentText, style: CustomTextStyles.m3BodyLarge()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Отмена', style: CustomTextStyles.m3BodyMedium()),
        ),
        TextButton(
          onPressed: () {
            actionFunc();
            Navigator.pop(context);
          },
          child: Text(actionText, style: CustomTextStyles.m3BodyMedium(color: AppColors.primaryScheme))
        )
      ],
    );
  }
}