import 'package:flutter/foundation.dart';

abstract final class AppTabs {
  static const int search = 0;
  static const int collections = 1;
  static const int profile = 2;
}

class ActiveTabController {
  ActiveTabController({int initialIndex = AppTabs.search})
      : index = ValueNotifier<int>(initialIndex);

  final ValueNotifier<int> index;

  void select(int value) => index.value = value;

  void dispose() => index.dispose();
}
