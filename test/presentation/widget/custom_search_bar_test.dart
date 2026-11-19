import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/custom_search_bar.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

/// Иконки бара не удаляются из дерева, а прячутся через [AnimatedOpacity],
/// поэтому видимость проверяется по целевому значению opacity.
double _iconOpacity(WidgetTester tester, IconData icon) {
  final finder = find
      .ancestor(of: find.byIcon(icon), matching: find.byType(AnimatedOpacity))
      .first;
  return tester.widget<AnimatedOpacity>(finder).opacity;
}

void main() {
  group('CustomSearchBar', () {
    testWidgets('shows the search icon and hides the back icon initially', (tester) async {
      await tester.pumpWidget(_wrap(
        CustomSearchBar(
          onSearchSubmitted: (_, __) {},
          useFilterButton: false,
          useRealTimeChange: false,
        ),
      ));

      expect(_iconOpacity(tester, Icons.search), 1);
      expect(_iconOpacity(tester, Icons.arrow_back), 0);
    });

    testWidgets('shows the back icon and hides the search icon once focused', (tester) async {
      await tester.pumpWidget(_wrap(
        CustomSearchBar(
          onSearchSubmitted: (_, __) {},
          useFilterButton: false,
          useRealTimeChange: false,
        ),
      ));

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(_iconOpacity(tester, Icons.arrow_back), 1);
      expect(_iconOpacity(tester, Icons.search), 0);
    });

    testWidgets('calls onSearchSubmitted with the typed keyword when submitted', (tester) async {
      String? submittedKeyword;

      await tester.pumpWidget(_wrap(
        CustomSearchBar(
          onSearchSubmitted: (keyword, context) => submittedKeyword = keyword,
          useFilterButton: false,
          useRealTimeChange: false,
        ),
      ));

      await tester.enterText(find.byType(TextField), 'Interstellar');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(submittedKeyword, 'Interstellar');
    });

    testWidgets('does not call onSearchSubmitted when submitting an empty string', (tester) async {
      var callCount = 0;

      await tester.pumpWidget(_wrap(
        CustomSearchBar(
          onSearchSubmitted: (_, __) => callCount++,
          useFilterButton: false,
          useRealTimeChange: false,
        ),
      ));

      await tester.tap(find.byType(TextField));
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(callCount, 0);
    });

    testWidgets('calls onSearchSubmitted on every keystroke when useRealTimeChange is true',
        (tester) async {
      final receivedKeywords = <String>[];

      await tester.pumpWidget(_wrap(
        CustomSearchBar(
          onSearchSubmitted: (keyword, context) => receivedKeywords.add(keyword),
          useFilterButton: false,
          useRealTimeChange: true,
        ),
      ));

      await tester.enterText(find.byType(TextField), 'Dune');
      await tester.pump();

      expect(receivedKeywords, isNotEmpty);
      expect(receivedKeywords.last, 'Dune');
    });

    testWidgets('does not call onSearchSubmitted while typing when useRealTimeChange is false',
        (tester) async {
      var callCount = 0;

      await tester.pumpWidget(_wrap(
        CustomSearchBar(
          onSearchSubmitted: (_, __) => callCount++,
          useFilterButton: false,
          useRealTimeChange: false,
        ),
      ));

      await tester.enterText(find.byType(TextField), 'Dune');
      await tester.pump();

      expect(callCount, 0);
    });

    testWidgets('shows filter icon when useFilterButton is true and field is unfocused',
        (tester) async {
      await tester.pumpWidget(_wrap(
        CustomSearchBar(
          onSearchSubmitted: (_, __) {},
          onFilterSubmitted: (_) {},
          useFilterButton: true,
          useRealTimeChange: false,
        ),
      ));

      expect(_iconOpacity(tester, Icons.filter_alt_outlined), 1);
      expect(_iconOpacity(tester, Icons.clear), 0);
    });

    testWidgets('hides filter and shows clear icon once focused', (tester) async {
      await tester.pumpWidget(_wrap(
        CustomSearchBar(
          onSearchSubmitted: (_, __) {},
          onFilterSubmitted: (_) {},
          useFilterButton: true,
          useRealTimeChange: false,
        ),
      ));

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(_iconOpacity(tester, Icons.filter_alt_outlined), 0);
      expect(_iconOpacity(tester, Icons.clear), 1);
    });

    testWidgets('tapping the filter icon invokes onFilterSubmitted', (tester) async {
      var filterTapped = false;

      await tester.pumpWidget(_wrap(
        CustomSearchBar(
          onSearchSubmitted: (_, __) {},
          onFilterSubmitted: (_) => filterTapped = true,
          useFilterButton: true,
          useRealTimeChange: false,
        ),
      ));

      await tester.tap(find.byIcon(Icons.filter_alt_outlined));
      await tester.pumpAndSettle();

      expect(filterTapped, isTrue);
    });

    testWidgets('tapping clear icon empties the field and calls onClear', (tester) async {
      var clearCalled = false;

      await tester.pumpWidget(_wrap(
        CustomSearchBar(
          onSearchSubmitted: (_, __) {},
          onClear: () => clearCalled = true,
          useFilterButton: false,
          useRealTimeChange: false,
        ),
      ));

      await tester.enterText(find.byType(TextField), 'Dune');
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(clearCalled, isTrue);
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, isEmpty);
    });
  });
}
