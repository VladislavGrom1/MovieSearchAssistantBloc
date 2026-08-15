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
  final focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      setState(() {
        _focused = focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _focused ? AppColors.primaryScheme : Colors.white.withOpacity(0.12),
              width: _focused ? 1.4 : 1,
            ),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: AppColors.primaryScheme.withOpacity(0.35),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryThemeBlack.withOpacity(0.55),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLength: widget.maxLenght,
                maxLines: widget.maxLines,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: CustomTextStyles.m3ActionText(color: AppColors.textDarkGrey),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  counterText: ""
                ),
                style: CustomTextStyles.m3ActionText(color: AppColors.textWhite),
                cursorColor: AppColors.primaryScheme,
                autofocus: true,
                onChanged: (_) => setState(() {})
              ),
            ),
          ),
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