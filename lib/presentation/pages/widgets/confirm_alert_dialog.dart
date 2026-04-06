import 'package:flutter/material.dart';

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
      title: Text(titleText),
      content: Text(contentText),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Отмена'),
        ),
        TextButton(
          onPressed: () {
            actionFunc();
            Navigator.pop(context);
          },
          child: Text(actionText)
        )
      ],
    );
  }
}