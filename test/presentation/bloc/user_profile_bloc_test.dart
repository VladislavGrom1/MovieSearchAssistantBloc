import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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
import 'package:movie_search_assistant_bloc/presentation/bloc/user_profile/user_profile_bloc.dart';

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
  late MockGetApiKeyInfoFromStorageUseCase getApiKeyInfoFromStorageUseCase;
  late MockUpdateUserApiKeyInfoUseCase updateUserApiKeyInfoUseCase;
  late MockImportLibraryUseCase importLibraryUseCase;
  late MockImportOldLibraryUseCase importOldLibraryUseCase;
  late MockExportLibraryUseCase exportLibraryUseCase;
  late MockClearLibraryUseCase clearLibraryUseCase;
  late MockGetStorageUsageUseCase getStorageUsageUseCase;
  late MockClearCacheUseCase clearCacheUseCase;
  late MockOpenUrlUseCase openUrlUseCase;
  late MockGetAppInfoUseCase getAppInfoUseCase;
  late MockShareLibraryUseCase shareLibraryUseCase;
  late MockUseSharedApiKeyUseCase useSharedApiKeyUseCase;
  late UserProfileBloc bloc;

  setUp(() {
    getApiKeyInfoFromStorageUseCase = MockGetApiKeyInfoFromStorageUseCase();
    updateUserApiKeyInfoUseCase = MockUpdateUserApiKeyInfoUseCase();
    importLibraryUseCase = MockImportLibraryUseCase();
    importOldLibraryUseCase = MockImportOldLibraryUseCase();
    exportLibraryUseCase = MockExportLibraryUseCase();
    clearLibraryUseCase = MockClearLibraryUseCase();
    getStorageUsageUseCase = MockGetStorageUsageUseCase();
    clearCacheUseCase = MockClearCacheUseCase();
    openUrlUseCase = MockOpenUrlUseCase();
    getAppInfoUseCase = MockGetAppInfoUseCase();
    shareLibraryUseCase = MockShareLibraryUseCase();
    useSharedApiKeyUseCase = MockUseSharedApiKeyUseCase();

    bloc = UserProfileBloc(
      getApiKeyInfoFromStorageUseCase: getApiKeyInfoFromStorageUseCase,
      updateUserApiKeyInfoUseCase: updateUserApiKeyInfoUseCase,
      importLibraryUseCase: importLibraryUseCase,
      importOldLibraryUseCase: importOldLibraryUseCase,
      exportLibraryUseCase: exportLibraryUseCase,
      clearLibraryUseCase: clearLibraryUseCase,
      getStorageUsageUseCase: getStorageUsageUseCase,
      clearCacheUseCase: clearCacheUseCase,
      openUrlUseCase: openUrlUseCase,
      getAppInfoUseCase: getAppInfoUseCase,
      shareLibraryUseCase: shareLibraryUseCase,
      useSharedApiKeyUseCase: useSharedApiKeyUseCase,
    );

    when(() => getApiKeyInfoFromStorageUseCase.call())
        .thenAnswer((_) async => null);
    when(() => getStorageUsageUseCase.call()).thenAnswer(
      (_) async => const StorageUsage(cacheBytes: 0, libraryBytes: 0),
    );
    when(() => getAppInfoUseCase.call())
        .thenAnswer((_) async => const <String, String>{});
  });

  tearDown(() => bloc.close());

  test('отдаёт размеры кэша и библиотеки вместе с профилем', () async {
    when(() => getStorageUsageUseCase.call()).thenAnswer(
      (_) async => const StorageUsage(cacheBytes: 1200, libraryBytes: 3400),
    );

    final states = <UserProfileState>[];
    final subscription = bloc.stream.listen(states.add);

    bloc.add(GetUserProfileInfo());
    await Future<void>.delayed(const Duration(milliseconds: 50));

    await subscription.cancel();

    expect(states[0], isA<UserProfileLoading>());
    final loaded = states.last as UserProfileLoaded;
    expect(loaded.cacheBytes, 1200);
    expect(loaded.libraryBytes, 3400);
  });

  test('RefreshStorageUsage обновляет цифры на экране', () async {
    bloc.emit(const UserProfileLoaded(cacheBytes: 10, libraryBytes: 20));
    when(() => getStorageUsageUseCase.call()).thenAnswer(
      (_) async => const StorageUsage(cacheBytes: 500, libraryBytes: 700),
    );

    final states = <UserProfileState>[];
    final subscription = bloc.stream.listen(states.add);

    bloc.add(RefreshStorageUsage());
    await Future<void>.delayed(const Duration(milliseconds: 50));

    await subscription.cancel();

    final loaded = states.last as UserProfileLoaded;
    expect(loaded.cacheBytes, 500);
    expect(loaded.libraryBytes, 700);
  });

  test('ошибка подсчёта не превращается в снекбар об ошибке', () async {
    bloc.emit(const UserProfileLoaded(cacheBytes: 10, libraryBytes: 20));
    when(() => getStorageUsageUseCase.call())
        .thenAnswer((_) async => throw Exception('диск недоступен'));

    final states = <UserProfileState>[];
    final subscription = bloc.stream.listen(states.add);

    bloc.add(RefreshStorageUsage());
    await Future<void>.delayed(const Duration(milliseconds: 50));

    await subscription.cancel();

    expect(states, isEmpty);
    final state = bloc.state as UserProfileLoaded;
    expect(state.cacheBytes, 10);
    expect(state.libraryBytes, 20);
  });

  test('очистка кэша сообщает освобождённый объём и обнуляет цифру', () async {
    bloc.emit(const UserProfileLoaded(cacheBytes: 1200000, libraryBytes: 500));

    var calls = 0;
    when(() => getStorageUsageUseCase.call()).thenAnswer((_) async {
      calls++;
      return StorageUsage(
        cacheBytes: calls == 1 ? 1200000 : 0,
        libraryBytes: 500,
      );
    });
    when(() => clearCacheUseCase.call()).thenAnswer((_) async {});

    final states = <UserProfileState>[];
    final subscription = bloc.stream.listen(states.add);

    bloc.add(ClearCacheDirectory());
    await Future<void>.delayed(const Duration(milliseconds: 50));

    await subscription.cancel();

    expect(
      states[0],
      const UserProfileActionSuccess(message: 'Очищено 1.2 МБ'),
    );
    final loaded = states.last as UserProfileLoaded;
    expect(loaded.cacheBytes, 0);
    expect(loaded.libraryBytes, 500);
    verify(() => clearCacheUseCase.call()).called(1);
  });

  test('пустой кэш не очищается и сообщает об этом', () async {
    bloc.emit(const UserProfileLoaded(cacheBytes: 0, libraryBytes: 500));

    final states = <UserProfileState>[];
    final subscription = bloc.stream.listen(states.add);

    bloc.add(ClearCacheDirectory());
    await Future<void>.delayed(const Duration(milliseconds: 50));

    await subscription.cancel();

    expect(
      states.first,
      const UserProfileActionSuccess(message: 'Кэш отсутствует'),
    );
    verifyNever(() => clearCacheUseCase.call());
  });
}
