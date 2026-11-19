import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/error_message_widget.dart';

import '../../helpers/ai_assistant_test_harness.dart';

void main() {
  Widget buildSubject({VoidCallback? onRetry}) {
    return MaterialApp(
      home: Scaffold(
        body: ErrorMessageWidget(
          message: 'Отсутствует интернет-соединение',
          onRetry: onRetry ?? () {},
        ),
      ),
    );
  }

  testWidgets('показывает сообщение и кнопку «Повторить»', (tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('Что-то пошло не так'), findsOneWidget);
    expect(find.text('Отсутствует интернет-соединение'), findsOneWidget);
    expect(find.text('Повторить'), findsOneWidget);
    expect(tester.getSize(find.byType(InkWell)).height, 48);
  });

  testWidgets('нажатие на «Повторить» вызывает onRetry', (tester) async {
    usePhoneViewport(tester);
    var taps = 0;
    await tester.pumpWidget(buildSubject(onRetry: () => taps++));
    await tester.pump();

    await tester.tap(find.text('Повторить'));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('без onRetry кнопка не показывается', (tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ErrorMessageWidget(message: 'Ошибка'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Повторить'), findsNothing);
  });
}
