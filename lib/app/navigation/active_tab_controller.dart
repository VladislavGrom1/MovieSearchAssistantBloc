import 'package:flutter/foundation.dart';

/// Индексы вкладок нижней навигации. Держим их в одном месте, чтобы экраны
/// не зашивали числа и не разъезжались при добавлении вкладки.
abstract final class AppTabs {
  static const int search = 0;
  static const int collections = 1;
  static const int profile = 2;
}

/// Текущая вкладка нижней навигации.
///
/// Пишет [HomeScreen], читают экраны, которым нужно знать, что их показали:
/// вкладки живут постоянно, поэтому «открытие экрана» не всегда совпадает
/// с созданием виджета.
class ActiveTabController {
  ActiveTabController({int initialIndex = AppTabs.search})
      : index = ValueNotifier<int>(initialIndex);

  final ValueNotifier<int> index;

  void select(int value) => index.value = value;

  void dispose() => index.dispose();
}
