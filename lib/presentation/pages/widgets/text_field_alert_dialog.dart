import 'package:flutter/material.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';

class TextFieldAlertDialog extends StatefulWidget {
  final String titleText;
  final String hintText;
  final int? maxLenght;
  final int? maxLines;
  final String actionText;
  final Function(String) actionFunc;

  const TextFieldAlertDialog({
    super.key,
    required this.titleText,
    required this.hintText,
    this.maxLenght,
    this.maxLines,
    required this.actionText,
    required this.actionFunc,
  });

  @override
  State<TextFieldAlertDialog> createState() => _TextFieldAlertDialogState();
}

class _TextFieldAlertDialogState extends State<TextFieldAlertDialog> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
          backgroundColor: AppColors.primaryThemeBlack,
          title: Text(widget.titleText, style: CustomTextStyles.m3Title()),
          content: SizedBox(
            width: double.maxFinite,
            child: TextField(
              maxLength: widget.maxLenght,
              maxLines: widget.maxLines,
              controller: controller,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: OutlineInputBorder(),
              ),
              style: CustomTextStyles.m3ActionText(),
              autofocus: true,
              onChanged: (_) => setState(() {})
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Отмена', style: CustomTextStyles.m3Body()),
            ),
            TextButton(
              onPressed: controller.text.isEmpty
              ? null
              : () {
                widget.actionFunc(controller.text);
                Navigator.pop(context);
              },
              child: Text(
                widget.actionText,
                style: controller.text.isEmpty
                ? CustomTextStyles.m3Body(color: AppColors.primaryThemeGrey)
                : CustomTextStyles.m3Body(color: AppColors.primaryScheme)
              )
            )
          ],
        );
  }
}