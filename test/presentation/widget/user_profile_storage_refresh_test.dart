import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_search_assistant_bloc/app/navigation/active_tab_controller.dart';
import 'package:movie_search_assistant_bloc/domain/entities/storage_usage.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/clear_cache_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/clear_library_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/export_library_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_api_key_info_from_storage_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_app_info_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_storage_usage_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/import_library_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/import_old_library_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/open_url_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/share_library_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/update_user_api_key_info_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/use_shared_api_key_use_case.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/user_profile/user_profile_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/user_profile_screen.dart';

class MockGetApiKeyInfoFromStorageUseCase extends Mock
    implements GetApiKeyInfoFromStorageUseCase {}

class MockUpdateUserApiKeyInfoUseCase extends Mock
    implements UpdateUserApiKeyInfoUseCase {}

class MockImportLibraryUseCase extends Mock implements ImportLibraryUseCase {}

class MockImportOldLibraryUseCase extends Mock
    implements ImportOldLibraryUseCase {}

class MockExportLibraryUseCase extends Mock implements ExportLibraryUseCase {}

class MockClearLibraryUseCase extends Mock implements ClearLibraryUseCase {}

class MockGetStorageUsageUseCase extends Mock
    implements GetStorageUsageUseCase {}

class MockClearCacheUseCase extends Mock implements ClearCacheUseCase {}

class MockOpenUrlUseCase extends Mock implements OpenUrlUseCase {}

class MockGetAppInfoUseCase extends Mock implements GetAppInfoUseCase {}

class MockShareLibraryUseCase extends Mock implements ShareLibraryUseCase {}

class MockUseSharedApiKeyUseCase extends Mock
    implements UseSharedApiKeyUseCase {}

void main() {
  late MockGetStorageUsageUseCase getStorageUsageUseCase;
  late MockClearCacheUseCase clearCacheUseCase;

  setUp(() async {
    getStorageUsageUseCase = MockGetStorageUsageUseCase();
    when(() => getStorageUsageUseCase.call()).thenAnswer(
      (_) async => const StorageUsage(cacheBytes: 0, libraryBytes: 0),
    );
    clearCacheUseCase = MockClearCacheUseCase();
    when(() => clearCacheUseCase.call()).thenAnswer((_) async {});

    final getApiKeyInfo = MockGetApiKeyInfoFromStorageUseCase();
    when(getApiKeyInfo.call).thenAnswer((_) async => null);
    final getAppInfo = MockGetAppInfoUseCase();
    when(getAppInfo.call).thenAnswer((_) async => const <String, String>{});

    await getIt.reset();
    getIt.registerLazySingleton(() => ActiveTabController());
    getIt.registerFactory<UserProfileBloc>(
      () => UserProfileBloc(
        getApiKeyInfoFromStorageUseCase: getApiKeyInfo,
        updateUserApiKeyInfoUseCase: MockUpdateUserApiKeyInfoUseCase(),
        importLibraryUseCase: MockImportLibraryUseCase(),
        importOldLibraryUseCase: MockImportOldLibraryUseCase(),
        exportLibraryUseCase: MockExportLibraryUseCase(),
        clearLibraryUseCase: MockClearLibraryUseCase(),
        getStorageUsageUseCase: getStorageUsageUseCase,
        clearCacheUseCase: clearCacheUseCase,
        openUrlUseCase: MockOpenUrlUseCase(),
        getAppInfoUseCase: getAppInfo,
        shareLibraryUseCase: MockShareLibraryUseCase(),
        useSharedApiKeyUseCase: MockUseSharedApiKeyUseCase(),
      ),
    );
  });

  tearDown(() async => getIt.reset());

  testWidgets('размер библиотеки обновляется, когда фильм сохранили',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: UserProfileScreen()));
    await tester.pump();
    await tester.pump();

    expect(find.text('Библиотека фильмов: 0 Б', findRichText: true),
        findsOneWidget);

    // Пользователь сохранил фильм на другом экране. Профиль при этом открыт
    // в соседней вкладке: ни одного события в блок не приходит.
    when(() => getStorageUsageUseCase.call()).thenAnswer(
      (_) async => const StorageUsage(cacheBytes: 0, libraryBytes: 5000000),
    );

    // Пока вкладка не показана, цифры не трогаем.
    getIt<ActiveTabController>().select(AppTabs.search);
    await tester.pump();
    await tester.pump();
    expect(find.text('Библиотека фильмов: 0 Б', findRichText: true),
        findsOneWidget);

    // Вернулись на «Профиль» — размеры пересчитаны.
    getIt<ActiveTabController>().select(AppTabs.profile);
    await tester.pump();
    await tester.pump();

    expect(find.text('Библиотека фильмов: 5 МБ', findRichText: true),
        findsOneWidget);
  });

  testWidgets('очистка кэша не уничтожает экран и сохраняет прокрутку',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(600, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // До очистки кэш непустой, после — ноль. Пересчёт после очистки
    // придержим, чтобы поймать промежуточное состояние «успех».
    var usageCalls = 0;
    final usageAfterClear = Completer<StorageUsage>();
    when(() => getStorageUsageUseCase.call()).thenAnswer((_) {
      usageCalls++;
      if (usageCalls <= 2) {
        return Future.value(
          const StorageUsage(cacheBytes: 1200000, libraryBytes: 500),
        );
      }
      return usageAfterClear.future;
    });

    final clearCache = Completer<void>();
    when(() => clearCacheUseCase.call()).thenAnswer((_) => clearCache.future);

    await tester.pumpWidget(const MaterialApp(home: UserProfileScreen()));
    await tester.pump();
    await tester.pump();
    await tester.pump();

    final position = tester
        .state<ScrollableState>(find.byType(Scrollable))
        .position;

    // Прокручиваем список настроек. Смещение меньше реальной высоты контента,
    // поэтому позиция не упирается в край и не пружинит при пересборке.
    position.jumpTo(400);
    await tester.pump();

    final offsetBefore = position.pixels;
    expect(offsetBefore, greaterThan(0));
    expect(offsetBefore, lessThan(position.maxScrollExtent));

    await tester.tap(find.text('Очистить кэш'));
    await tester.pump();
    await tester.pump();

    // Пока идёт очистка, экран на месте.
    expect(find.text('Очистить кэш'), findsOneWidget);

    clearCache.complete();
    await tester.pump();
    await tester.pump();

    // Блок сообщает об успехе отдельным состоянием. Экран не должен на нём
    // исчезать: иначе ListView уничтожается и прокрутка теряется.
    expect(find.text('Очистить кэш'), findsOneWidget);
    expect(
      tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels,
      offsetBefore,
    );

    usageAfterClear.complete(
      const StorageUsage(cacheBytes: 0, libraryBytes: 500),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Размер кэша: 0 Б', findRichText: true), findsOneWidget);
    expect(
      tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels,
      offsetBefore,
    );
  });
}
