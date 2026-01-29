import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/remote/film_remote_data_source.dart';
import 'package:movie_search_assistant_bloc/data/models/film_card_model.dart';
import 'package:movie_search_assistant_bloc/data/repository_impl/film_repository_impl.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_card_entity.dart';

class MockFilmRemoteDataSource extends Mock implements FilmRemoteDataSource{}
class FakeFilmCardModel extends Fake implements FilmCardModel {}
class FakeFilmCardEntity extends Fake implements FilmCardEntity {}


FilmCardModel _buildFilmCardModel({
  int? kinopoiskId = 0,
  String? nameRu = "Фильм №1",
  String? nameEn = "Film №1",
  String? nameOriginal = "Film №1",
  List<String>? countries = const ["Россия", "США"],
  List<String>? genres = const ["Детектив"],
  num? ratingKinopoisk = 7.9,
  num? ratingImbd = 8.1,
  int? year = 1995,
  String? type = "MOVIE",
  String? posterUrl = "posterUrl",
  String? posterUrlPreview = "posterUrlPreview"
}) => FilmCardModel(
  kinopoiskId: kinopoiskId,
  nameRu: nameRu,
  nameEn: nameEn,
  nameOriginal: nameOriginal,
  countries: countries,
  genres: genres,
  ratingKinopoisk: ratingKinopoisk,
  ratingImbd: ratingImbd,
  year: year,
  type: type,
  posterUrl: posterUrl,
  posterUrlPreview: posterUrlPreview
);

FilmCardEntity _buildFilmCardEntity({
  int? kinopoiskId = 0,
  String? nameRu = "Фильм №1",
  String? nameEn = "Film №1",
  String? nameOriginal = "Film №1",
  num? ratingKinopoisk = 7.9
}) => FilmCardEntity(
  kinopoiskId: kinopoiskId,
  nameRu: nameRu,
  nameEn: nameEn,
  nameOriginal: nameOriginal,
  ratingKinopoisk: ratingKinopoisk
);

void main(){
  late FilmRepositoryImpl filmRepositoryImpl;
  late MockFilmRemoteDataSource mockFilmRemoteDataSource;

  setUpAll(() {
    registerFallbackValue(FakeFilmCardModel());
    registerFallbackValue(FakeFilmCardEntity());
  });

  setUp(() {
    mockFilmRemoteDataSource = MockFilmRemoteDataSource();
    filmRepositoryImpl = FilmRepositoryImpl(
      filmRemoteDataSource: mockFilmRemoteDataSource
    );
  });

  group("getCollectionFilmsFromRemoteDataSource", () {
    const testApiKey = "TestApiKey";
    const collectionName = "TOP_POPULAR_MOVIES";
    const page = 1;
    final List<FilmCardModel> testfilmCardModelList = List.filled(2, _buildFilmCardModel());
    final List<FilmCardEntity> testfilmCardEntityList = List.filled(2, _buildFilmCardEntity());
    
    test('should return List<FilmCardEntity> when remote data source returns List<FilmCardModel>', () async {
      when(() => mockFilmRemoteDataSource.getCollectionFilms(testApiKey, collectionName, page)).thenAnswer((_) async => testfilmCardModelList);
      final result = await filmRepositoryImpl.getCollectionFilms(testApiKey, collectionName, page);
      expect(result, equals(testfilmCardEntityList));
      verify(() => mockFilmRemoteDataSource.getCollectionFilms(testApiKey, collectionName, page)).called(1);
    });

    test('should return NULL when remote data source returns NULL', () async {
      when(() => mockFilmRemoteDataSource.getCollectionFilms(testApiKey, collectionName, page)).thenAnswer((_) async => null);
      final result = await filmRepositoryImpl.getCollectionFilms(testApiKey, collectionName, page);
      expect(result, isNull);
      verify(() => mockFilmRemoteDataSource.getCollectionFilms(testApiKey, collectionName, page)).called(1);
    });

    test('should rethrow RemoteDataSourceException when remote data source throws RemoteDataSourceException', () async {
      when(() => mockFilmRemoteDataSource.getCollectionFilms(testApiKey, collectionName, page)).thenThrow(RemoteDataSourceException(
        DioExceptionType.connectionError, 
        HttpStatus.connectionClosedWithoutResponse
      ));
      expect(() => filmRepositoryImpl.getCollectionFilms(testApiKey, collectionName, page), throwsA(isA<RemoteDataSourceException>()));
    });

    test('should rethrow Exception when remote data source throws Exception', () async {
      when(() => mockFilmRemoteDataSource.getCollectionFilms(testApiKey, collectionName, page)).thenThrow(Exception());
      expect(() => filmRepositoryImpl.getCollectionFilms(testApiKey, collectionName, page), throwsA(isA<Exception>()));
    });    
  });

  // TODO: Тесты для LocalDataSource
}