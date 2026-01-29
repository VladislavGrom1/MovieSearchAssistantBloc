
import 'dart:io';
import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/user_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/authentication_use_case.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/user_authentication/bloc/authentication_bloc.dart';

class MockAuthenticationUseCase extends Mock implements AuthenticationUseCase {}

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

    setUp(() {
      reset(mockAuthenticationUseCase);
    });

    blocTest<AuthenticationBloc, AuthenticationState>(
      "emit AuthenticationSuccess when AuthenticationUseCase returns UserEntity",
      setUp: () {
        when(() => mockAuthenticationUseCase.call(apiKey: "TestApiKey")).thenAnswer((_) async => userEntity);
      },
      build: () => AuthenticationBloc(authenticationUseCase: mockAuthenticationUseCase),
      act: (bloc) => bloc.add(TryAuthenticationEvent(apiKey: "TestApiKey")),
      expect: () => <AuthenticationState>[
        AuthenticationLoading(),
        AuthenticationSuccess(userInfo: userEntity)
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
      build: () => AuthenticationBloc(authenticationUseCase: mockAuthenticationUseCase),
      act: (bloc) => bloc.add(TryAuthenticationEvent(apiKey: "TestApiKey")),
      expect: () => <AuthenticationState>[
        AuthenticationLoading(),
        AuthenticationFailure(exceptionType: "Информация об ApiKey отсутствует")
      ],
      verify: (_) {
        verify(() => mockAuthenticationUseCase.call(apiKey: "TestApiKey")).called(1);
      } 
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      "emit AuthenticationFailure when AuthenticationUseCase rethrow RemoteDataSourceException",
      setUp: () {
        when(() => mockAuthenticationUseCase.call(apiKey: "TestApiKey")).thenThrow(RemoteDataSourceException(
          DioExceptionType.values.first,
          HttpStatus.badRequest
        ));
      },
      build: () => AuthenticationBloc(authenticationUseCase: mockAuthenticationUseCase),
      act: (bloc) => bloc.add(TryAuthenticationEvent(apiKey: "TestApiKey")),
      expect: () => [
        AuthenticationLoading(),
        isA<AuthenticationFailure>()
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
      build: () => AuthenticationBloc(authenticationUseCase: mockAuthenticationUseCase),
      act: (bloc) => bloc.add(TryAuthenticationEvent(apiKey: "TestApiKey")),
      expect: () => [
        AuthenticationLoading(),
        isA<AuthenticationFailure>()
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
      build: () => AuthenticationBloc(authenticationUseCase: mockAuthenticationUseCase),
      act: (bloc) => bloc.add(TryAuthenticationEvent(apiKey: "TestApiKey")),
      expect: () => [
        AuthenticationLoading(),
        isA<AuthenticationFailure>()
      ],
      verify: (_) {
        verify(() => mockAuthenticationUseCase.call(apiKey: "TestApiKey")).called(1);
      } 
    );

  });
}