
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/user_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/open_url_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/update_user_api_key_info_use_case.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/user_authentication/authentication_bloc.dart';

class MockAuthenticationUseCase extends Mock implements UpdateUserApiKeyInfoUseCase {}
class MockOpenUrlUseCase extends Mock implements OpenUrlUseCase{}

UserEntity _buildUserEntity({
  String? apiKey = "TestApiKey",
  String? accountType = "FREE",
  int? limitCount = 500,
  int? useCount = 10
}) => UserEntity(
  apiKey:  apiKey, 
  accountType: accountType, 
  limitCount: limitCount, 
  useCount: useCount
);

void main(){
  group("AuthenticationBloc", () {
    final userEntity = _buildUserEntity();
    final mockAuthenticationUseCase = MockAuthenticationUseCase();
    final mockOpenUrlUseCase = MockOpenUrlUseCase();

    setUp(() {
      reset(mockAuthenticationUseCase);
    });

    blocTest<AuthenticationBloc, AuthenticationState>(
      "emit AuthenticationSuccess when AuthenticationUseCase returns UserEntity",
      setUp: () {
        when(() => mockAuthenticationUseCase.call(apiKey: "TestApiKey")).thenAnswer((_) async => userEntity);
      },
      build: () => AuthenticationBloc(authenticationUseCase: mockAuthenticationUseCase, openUrlUseCase: mockOpenUrlUseCase),
      act: (bloc) => bloc.add(TryAuthenticationEvent(apiKey: "TestApiKey")),
      expect: () => <AuthenticationState>[
        AuthenticationLoading(),
        AuthenticationSuccess(userInfo: userEntity),
        AuthenticationInitial(),
      ],
      verify: (_) {
        verify(() => mockAuthenticationUseCase.call(apiKey: "TestApiKey")).called(1);
      }  
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      "emit AuthenticationFailure when AuthenticationUseCase returns NULL",
      setUp: () {
        when(() => mockAuthenticationUseCase.call(apiKey: "TestApiKey")).thenAnswer((_) async => null);
      },
      build: () => AuthenticationBloc(authenticationUseCase: mockAuthenticationUseCase, openUrlUseCase: mockOpenUrlUseCase),
      act: (bloc) => bloc.add(TryAuthenticationEvent(apiKey: "TestApiKey")),
      expect: () => <AuthenticationState>[
        AuthenticationLoading(),
        AuthenticationFailure(message: "API ключ отсутствует"),
        AuthenticationInitial(),
      ],
      verify: (_) {
        verify(() => mockAuthenticationUseCase.call(apiKey: "TestApiKey")).called(1);
      } 
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      "emit AuthenticationFailure when AuthenticationUseCase rethrow RemoteDataSourceException",
      setUp: () {
        when(() => mockAuthenticationUseCase.call(apiKey: "TestApiKey")).thenThrow(NetworkFailure());
      },
      build: () => AuthenticationBloc(authenticationUseCase: mockAuthenticationUseCase, openUrlUseCase: mockOpenUrlUseCase),
      act: (bloc) => bloc.add(TryAuthenticationEvent(apiKey: "TestApiKey")),
      expect: () => [
        AuthenticationLoading(),
        isA<AuthenticationFailure>(),
        AuthenticationInitial(),
      ],
      verify: (_) {
        verify(() => mockAuthenticationUseCase.call(apiKey: "TestApiKey")).called(1);
      } 
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      "emit AuthenticationFailure when AuthenticationUseCase rethrow LocalDataSourceException",
      setUp: () {
        when(() => mockAuthenticationUseCase.call(apiKey: "TestApiKey")).thenThrow(LocalDataSourceException(
          message: "Error"
        ));
      },
      build: () => AuthenticationBloc(authenticationUseCase: mockAuthenticationUseCase, openUrlUseCase: mockOpenUrlUseCase),
      act: (bloc) => bloc.add(TryAuthenticationEvent(apiKey: "TestApiKey")),
      expect: () => [
        AuthenticationLoading(),
        isA<AuthenticationFailure>(),
        AuthenticationInitial(),
      ],
      verify: (_) {
        verify(() => mockAuthenticationUseCase.call(apiKey: "TestApiKey")).called(1);
      } 
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      "emit AuthenticationFailure when AuthenticationUseCase rethrow Exception",
      setUp: () {
        when(() => mockAuthenticationUseCase.call(apiKey: "TestApiKey")).thenThrow(Exception());
      },
      build: () => AuthenticationBloc(authenticationUseCase: mockAuthenticationUseCase, openUrlUseCase: mockOpenUrlUseCase),
      act: (bloc) => bloc.add(TryAuthenticationEvent(apiKey: "TestApiKey")),
      expect: () => [
        AuthenticationLoading(),
        isA<AuthenticationFailure>(),
        AuthenticationInitial(),
      ],
      verify: (_) {
        verify(() => mockAuthenticationUseCase.call(apiKey: "TestApiKey")).called(1);
      } 
    );

  });
}