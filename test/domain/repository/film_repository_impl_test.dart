import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/remote/film_remote_data_source.dart';
import 'package:movie_search_assistant_bloc/data/models/film_card_model.dart';
import 'package:movie_search_assistant_bloc/data/models/film_information_model.dart';
import 'package:movie_search_assistant_bloc/data/repository_impl/film_repository_impl.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_card_entity.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_information_entity.dart';

class MockFilmRemoteDataSource extends Mock implements FilmRemoteDataSource{}
class FakeFilmCardModel extends Fake implements FilmCardModel {}
class FakeFilmCardEntity extends Fake implements FilmCardEntity {}
class FakeFilmInformationModel extends Fake implements FilmInformationModel {}
class FakeFilmInformationEntity extends Fake implements FilmInformationEntity {}


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
  List<String>? countries = const ["Россия", "США"],
  List<String>? genres = const ["Детектив"],
  num? ratingKinopoisk = 7.9,
  num? ratingImbd = 8.1,
  int? year = 1995,
  String? type = "MOVIE",
  String? posterUrl = "posterUrl",
  String? posterUrlPreview = "posterUrlPreview"
}) => FilmCardEntity(
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

FilmInformationModel _buildFilmInformationModel({
  int? kinopoiskId = 301,
  String? kinopoiskHDId = "4824a95e60a7db7e86f14137516ba590",
  String? imdbId = "tt0133093",
  String? nameRu = "Матрица",
  String? nameEn = "The Matrix",
  String? nameOriginal = "The Matrix",
  String? posterUrl = "https://kinopoiskapiunofficial.tech/images/posters/kp/301.jpg",
  String? posterUrlPreview = "https://kinopoiskapiunofficial.tech/images/posters/kp_small/301.jpg",
  String? coverUrl = "https://avatars.mds.yandex.net/get-ott/1672343/2a0000016cc7177239d4025185c488b1bf43/orig",
  String? logoUrl = "https://avatars.mds.yandex.net/get-ott/1648503/2a00000170a5418408119bc802b53a03007b/orig",
  int? reviewsCount = 293,
  num? ratingGoodReview = 88.9,
  int? ratingGoodReviewVoteCount = 257,
  num? ratingKinopoisk = 8.5,
  int? ratingKinopoiskVoteCount = 524108,
  num? ratingImdb = 8.7,
  int? ratingImdbVoteCount = 1729087,
  num? ratingFilmCritics = 7.8,
  int? ratingFilmCriticsVoteCount = 155,
  num? ratingAwait = 7.8,
  int? ratingAwaitCount = 2,
  num? ratingRfCritics = 7.8,
  int? ratingRfCriticsVoteCount = 31,
  String? webUrl = "https://www.kinopoisk.ru/film/301/",
  int? year = 1999,
  int? filmLength = 136,
  String? slogan = "Добро пожаловать в реальный мир",
  String? description = "Жизнь Томаса Андерсона разделена на две части:",
  String? shortDescription = "Хакер Нео узнает, что его мир — виртуальный. Выдающийся экшен, доказавший, что зрелищное кино может быть умным",
  String? editorAnnotation = "Фильм доступен только на языке оригинала с русскими субтитрами",
  bool? isTicketsAvailable = false,
  String? productionStatus = "POST_PRODUCTION",
  String? type = "FILM",
  String? ratingMpaa = "r",
  String? ratingAgeLimits = "age16",
  bool? hasImax = false,
  bool? has3D = false,
  String? lastSync = "2021-07-29T20:07:49.109817",
  List<String>? countries = const ["США"],
  List<String>? genres = const ["Фантастика"],
  int? startYear = 1996,
  int? endYear = 1996,
  bool? serial = false,
  bool? shortFilm = false,
  bool? completed = false,
}) => FilmInformationModel(
  kinopoiskId: kinopoiskId,
  kinopoiskHDId: kinopoiskHDId,
  imdbId: imdbId,
  nameRu: nameRu,
  nameEn: nameEn,
  nameOriginal: nameOriginal,
  posterUrl: posterUrl,
  posterUrlPreview: posterUrlPreview,
  coverUrl: coverUrl,
  logoUrl: logoUrl,
  reviewsCount: reviewsCount,
  ratingGoodReview: ratingGoodReview,
  ratingGoodReviewVoteCount: ratingGoodReviewVoteCount,
  ratingKinopoisk: ratingKinopoisk,
  ratingKinopoiskVoteCount: ratingKinopoiskVoteCount,
  ratingImdb: ratingImdb,
  ratingImdbVoteCount: ratingImdbVoteCount,
  ratingFilmCritics: ratingFilmCritics,
  ratingFilmCriticsVoteCount: ratingFilmCriticsVoteCount,
  ratingAwait: ratingAwait,
  ratingAwaitCount: ratingAwaitCount,
  ratingRfCritics: ratingRfCritics,
  ratingRfCriticsVoteCount: ratingRfCriticsVoteCount,
  webUrl: webUrl,
  year: year,
  filmLength: filmLength,
  slogan: slogan,
  description: description,
  shortDescription: shortDescription,
  editorAnnotation: editorAnnotation,
  isTicketsAvailable: isTicketsAvailable,
  productionStatus: productionStatus,
  type: type,
  ratingMpaa: ratingMpaa,
  ratingAgeLimits: ratingAgeLimits,
  hasImax: hasImax,
  has3D: has3D,
  lastSync: lastSync,
  countries: countries,
  genres: genres,
  startYear: startYear,
  endYear: endYear,
  serial: serial,
  shortFilm: shortFilm,
  completed: completed,
);

FilmInformationEntity _buildFilmInformationEntity({
  int? kinopoiskId = 301,
  String? nameRu = "Матрица",
  String? nameOriginal = "The Matrix",
  String? posterUrl = "https://kinopoiskapiunofficial.tech/images/posters/kp/301.jpg",
  num? ratingKinopoisk = 8.5,
  int? ratingKinopoiskVoteCount = 524108,
  num? ratingImdb = 8.7, 
  int? ratingImdbVoteCount = 1729087,
  String? webUrl = "https://www.kinopoisk.ru/film/301/",
  int? year = 1999,
  String? slogan = "Добро пожаловать в реальный мир",
  String? description = "Жизнь Томаса Андерсона разделена на две части:",
  List<String>? countries = const ["США"],
  List<String>? genres = const ["Фантастика"],
  int? startYear = 1996,
  int? endYear = 1996,
  bool? serial = false
}) => FilmInformationEntity(
  kinopoiskId: kinopoiskId,
  nameRu: nameRu,
  nameOriginal: nameOriginal,
  posterUrl: posterUrl,
  ratingKinopoisk: ratingKinopoisk,
  ratingKinopoiskVoteCount: ratingKinopoiskVoteCount,
  ratingImdb: ratingImdb,
  ratingImdbVoteCount: ratingImdbVoteCount,
  webUrl: webUrl,
  year: year,
  slogan: slogan,
  description: description,
  countries: countries,
  genres: genres,
  startYear: startYear,
  endYear: endYear,
  serial: serial
);

void main(){
  late FilmRepositoryImpl filmRepositoryImpl;
  late MockFilmRemoteDataSource mockFilmRemoteDataSource;

  setUpAll(() {
    registerFallbackValue(FakeFilmCardModel());
    registerFallbackValue(FakeFilmCardEntity());
    registerFallbackValue(FakeFilmInformationModel());
    registerFallbackValue(FakeFilmInformationEntity());
  });

  setUp(() {
    mockFilmRemoteDataSource = MockFilmRemoteDataSource();
    filmRepositoryImpl = FilmRepositoryImpl(
      filmRemoteDataSource: mockFilmRemoteDataSource
    );
  });

  group("getCollectionFilmsFromRemoteDataSource", () {
    const collectionName = "TOP_POPULAR_MOVIES";
    const page = 1;
    final List<FilmCardModel> testfilmCardModelList = List.filled(2, _buildFilmCardModel());
    final List<FilmCardEntity> testfilmCardEntityList = List.filled(2, _buildFilmCardEntity());
    
    test('should return List<FilmCardEntity> when remote data source returns List<FilmCardModel>', () async {
      when(() => mockFilmRemoteDataSource.getCollectionFilms(collectionName, page)).thenAnswer((_) async => testfilmCardModelList);
      final result = await filmRepositoryImpl.getCollectionFilms(collectionName, page);
      expect(result, equals(testfilmCardEntityList));
      verify(() => mockFilmRemoteDataSource.getCollectionFilms(collectionName, page)).called(1);
    });

    test('should return NULL when remote data source returns NULL', () async {
      when(() => mockFilmRemoteDataSource.getCollectionFilms(collectionName, page)).thenAnswer((_) async => null);
      final result = await filmRepositoryImpl.getCollectionFilms(collectionName, page);
      expect(result, isNull);
      verify(() => mockFilmRemoteDataSource.getCollectionFilms(collectionName, page)).called(1);
    });

    test('should rethrow RemoteDataSourceException when remote data source throws RemoteDataSourceException', () async {
      when(() => mockFilmRemoteDataSource.getCollectionFilms(collectionName, page)).thenThrow(RemoteDataSourceException(
        DioExceptionType.connectionError, 
        HttpStatus.connectionClosedWithoutResponse
      ));
      expect(() => filmRepositoryImpl.getCollectionFilms(collectionName, page), throwsA(isA<RemoteDataSourceException>()));
    });

    // test('should rethrow LocalDataSourceException when remote data source throws LocalDataSourceException', () async {
    //   when(() => mockFilmRemoteDataSource.getCollectionFilms(collectionName, page)).thenThrow(LocalDataSourceException(
    //     message: "Error"
    //   ));
    //   expect(() => filmRepositoryImpl.getCollectionFilms(collectionName, page), throwsA(isA<RemoteDataSourceException>()));
    // });

    test('should rethrow Exception when remote data source throws Exception', () async {
      when(() => mockFilmRemoteDataSource.getCollectionFilms(collectionName, page)).thenThrow(Exception());
      expect(() => filmRepositoryImpl.getCollectionFilms(collectionName, page), throwsA(isA<Exception>()));
    });    
  });

  group("getFilmInformation", () {
    const idFilm = 301;
    final testFilmInformationModel = _buildFilmInformationModel();
    final testFilmInformationEntity = _buildFilmInformationEntity();

    test('should return FilmInformationEntity when remote data source returns FilmInformationModel', () async {
      when(() => mockFilmRemoteDataSource.getFilmInformation(idFilm)).thenAnswer((_) async => testFilmInformationModel);
      final result = await filmRepositoryImpl.getFilmInformation(idFilm);
      expect(result, equals(testFilmInformationEntity));
      verify(() => mockFilmRemoteDataSource.getFilmInformation(idFilm)).called(1);
    });

    test('should return NULL when remote data source returns NULL', () async {
      when(() => mockFilmRemoteDataSource.getFilmInformation(idFilm)).thenAnswer((_) async => null);
      final result = await filmRepositoryImpl.getFilmInformation(idFilm);
      expect(result, isNull);
      verify(() => mockFilmRemoteDataSource.getFilmInformation(idFilm)).called(1);
    });

    test('should rethrow RemoteDataSourceException when remote data source throws RemoteDataSourceException', () async {
      when(() => mockFilmRemoteDataSource.getFilmInformation(idFilm)).thenThrow(RemoteDataSourceException(
        DioExceptionType.connectionError, 
        HttpStatus.connectionClosedWithoutResponse
      ));
      expect(() => filmRepositoryImpl.getFilmInformation(idFilm), throwsA(isA<RemoteDataSourceException>()));
    });

    // test('should rethrow LocalDataSourceException when remote data source throws LocalDataSourceException', () async {
    //   when(() => mockFilmRemoteDataSource.getFilmInformation(idFilm)).thenThrow(LocalDataSourceException(
    //     message: "Error"
    //   ));
    //   expect(() => filmRepositoryImpl.getFilmInformation(idFilm), throwsA(isA<RemoteDataSourceException>()));
    // });

    test('should rethrow Exception when remote data source throws Exception', () async {
      when(() => mockFilmRemoteDataSource.getFilmInformation(idFilm)).thenThrow(Exception());
      expect(() => filmRepositoryImpl.getFilmInformation(idFilm), throwsA(isA<Exception>()));
    });    
    
  });

  // TODO: Тесты для getFilterFilmsFromRemoteDataSource и LocalStorage

}