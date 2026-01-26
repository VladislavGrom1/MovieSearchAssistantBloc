
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/local/user_local_data_source.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/remote/user_remote_data_source.dart';
import 'package:movie_search_assistant_bloc/data/models/user_model.dart';
import 'package:movie_search_assistant_bloc/data/repository_impl/user_repository_impl.dart';
import 'package:movie_search_assistant_bloc/domain/entities/user_entity.dart';

class MockUserRemoteDataSource extends Mock implements UserRemoteDataSource{}
class MockUserLocalDataSource extends Mock implements UserLocalDataSource{}
class FakeUserModel extends Fake implements UserModel {}
class FakeUserEntity extends Fake implements UserEntity {}

UserModel buildUserModel({
  String? apiKey = "TestApiKey", 
  String? accountType = "FREE", 
  int? limitCount = 500, 
  int? useCount = 10
  }) => UserModel(
    apiKey: apiKey, 
    accountType: accountType, 
    limitCount: limitCount, 
    useCount: useCount
  );

UserEntity buildUserEntity({
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
  late UserRepositoryImpl userRepositoryImpl;
  late MockUserRemoteDataSource mockUserRemoteDataSource;
  late MockUserLocalDataSource mockUserLocalDataSource;

  setUpAll(() {
    registerFallbackValue(FakeUserModel());
    registerFallbackValue(FakeUserEntity());
  });

  setUp(() {
    mockUserRemoteDataSource = MockUserRemoteDataSource();
    mockUserLocalDataSource = MockUserLocalDataSource();
    userRepositoryImpl = UserRepositoryImpl(
      userApiService: mockUserRemoteDataSource, 
      userLocalStorage: mockUserLocalDataSource
    );
  });

  group("getUserApiKeyInfoFromRemoteDataSource", () {
    const testApiKey = "TestApiKey";
    final testUserModel = buildUserModel();
    final testUserEntity = buildUserEntity();

    test('should return UserEntity when remote data source returns UserModel', () async {
      when(() => mockUserRemoteDataSource.getUserApiKeyInfo(testApiKey)).thenAnswer((_) async => testUserModel);
      final result = await userRepositoryImpl.getUserApiKeyInfoFromService(testApiKey);
      expect(result, equals(testUserEntity));
      verify(() => mockUserRemoteDataSource.getUserApiKeyInfo("TestApiKey")).called(1);
    });

    test('should return NULL when remote data source returns NULL', () async {
      when(() => mockUserRemoteDataSource.getUserApiKeyInfo(testApiKey)).thenAnswer((_) async => null);
      final result = await userRepositoryImpl.getUserApiKeyInfoFromService(testApiKey);
      expect(result, isNull);
      verify(() => mockUserRemoteDataSource.getUserApiKeyInfo("TestApiKey")).called(1);
    });

    test('should rethrow RemoteDataSourceException when remote data source throws RemoteDataSourceException', () async {
      when(() => mockUserRemoteDataSource.getUserApiKeyInfo(testApiKey)).thenThrow(RemoteDataSourceException(
        DioExceptionType.connectionError, 
        HttpStatus.connectionClosedWithoutResponse
      ));
      expect(() => userRepositoryImpl.getUserApiKeyInfoFromService(testApiKey), throwsA(isA<RemoteDataSourceException>()));
    });

    test('should rethrow Exception when remote data source throws Exception', () async {
      when(() => mockUserRemoteDataSource.getUserApiKeyInfo(testApiKey)).thenThrow(Exception());
      expect(() => userRepositoryImpl.getUserApiKeyInfoFromService(testApiKey), throwsA(isA<Exception>()));
    });    
  });

  group("getUserApiKeyInfoFromLocalDataSource", () {
    final testUserModel = buildUserModel();
    final testUserEntity = buildUserEntity();

    test('should return UserEntity when local data source returns UserModel', () async {
      when(() => mockUserLocalDataSource.getUserApiKeyInfo()).thenReturn(testUserModel);
      final result = await userRepositoryImpl.getUserApiKeyInfoFromStorage();
      expect(result, equals(testUserEntity));
    });

    test('should return NULL when local data source returns NULL', () async {
      when(() => mockUserLocalDataSource.getUserApiKeyInfo()).thenReturn(null);
      final result = await userRepositoryImpl.getUserApiKeyInfoFromStorage();
      expect(result, isNull);
    });

    test('should rethrow LocalDataSourceException when remote data source throws LocalDataSourceException', () async {
      when(() => mockUserLocalDataSource.getUserApiKeyInfo()).thenThrow(LocalDataSourceException(message: ""));
      expect(() => userRepositoryImpl.getUserApiKeyInfoFromStorage(), throwsA(isA<LocalDataSourceException>()));
    });  

    test('should rethrow Exception when remote data source throws Exception', () async {
      when(() => mockUserLocalDataSource.getUserApiKeyInfo()).thenThrow(Exception());
      expect(() => userRepositoryImpl.getUserApiKeyInfoFromStorage(), throwsA(isA<Exception>()));
    });      
  });

  group("addUserApiKeyInfoInLocalDataSource", () {
    final testUserEntity = buildUserEntity();

    test('should rethrow LocalDataSourceException when remote data source throws LocalDataSourceException', () async {
      when(() => mockUserLocalDataSource.addUserApiKeyInfo(any())).thenThrow(LocalDataSourceException(message: ""));
      expect(() => userRepositoryImpl.addUserApiKeyInfoInStorage(testUserEntity), throwsA(isA<LocalDataSourceException>()));
    });

    test('should rethrow Exception when remote data source throws Exception', () async {
      when(() => mockUserLocalDataSource.addUserApiKeyInfo(any())).thenThrow(Exception());
      expect(() => userRepositoryImpl.addUserApiKeyInfoInStorage(testUserEntity), throwsA(isA<Exception>()));
    });
  });

  group("removeUserApiKeyInfoFromLocalDataSource", () {
    test('should rethrow LocalDataSourceException when remote data source throws LocalDataSourceException', () async {
      when(() => mockUserLocalDataSource.removeUserApiKeyInfo()).thenThrow(LocalDataSourceException(message: ""));
      expect(() => userRepositoryImpl.removeUserApiKeyInfoFromStorage(), throwsA(isA<LocalDataSourceException>()));
    });

    test('should rethrow Exception when remote data source throws Exception', () async {
      when(() => mockUserLocalDataSource.removeUserApiKeyInfo()).thenThrow(Exception());
      expect(() => userRepositoryImpl.removeUserApiKeyInfoFromStorage(), throwsA(isA<Exception>()));
    });
  });

}


