// TODO: Доработать тесты

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/local/flim_local_data_source.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/remote/film_remote_data_source.dart';
import 'package:movie_search_assistant_bloc/data/models/film_base_model.dart';
import 'package:movie_search_assistant_bloc/data/models/film_images_model.dart';
import 'package:movie_search_assistant_bloc/data/models/film_detail_model.dart';
import 'package:movie_search_assistant_bloc/data/repository_impl/film_repository_impl.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_images_entity.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_information_entity.dart';

class MockFilmRemoteDataSource extends Mock implements FilmRemoteDataSource{}
class MockFilmLocalDataSource extends Mock implements FilmLocalDataSource{}
class FakeFilmBaseModel extends Fake implements FilmBaseModel {}
class FakeFilmDetailModel extends Fake implements FilmDetailModel {}
class FakeFilmEntity extends Fake implements FilmEntity {}
class FakeFilmImagesModel extends Fake implements FilmImagesModel {}
class FakeFilmImagesEntity extends Fake implements FilmImagesEntity {}


FilmBaseModel _buildFilmBaseModel({
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
  String? posterUrlPreview = "posterUrlPreview",
  bool? isSaved = false,
}) => FilmBaseModel(
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
  posterUrlPreview: posterUrlPreview,
  isSaved: isSaved,
);

// Функция для создания FilmEntity из FilmBaseModel (только базовые поля)
FilmEntity _buildFilmEntityFromBaseModel({
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
  String? posterUrlPreview = "posterUrlPreview",
  bool? isSaved = false,
}) => FilmEntity(
  // FilmBaseInformation
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
  posterUrlPreview: posterUrlPreview,
  isSaved: isSaved,
  // FilmDetailInformation (все null)
  kinopoiskHDId: null,
  imdbId: null,
  coverUrl: null,
  logoUrl: null,
  reviewsCount: null,
  ratingGoodReview: null,
  ratingGoodReviewVoteCount: null,
  ratingKinopoiskVoteCount: null,
  ratingImdbVoteCount: null,
  ratingFilmCritics: null,
  ratingFilmCriticsVoteCount: null,
  ratingAwait: null,
  ratingAwaitCount: null,
  ratingRfCritics: null,
  ratingRfCriticsVoteCount: null,
  webUrl: null,
  filmLength: null,
  slogan: null,
  description: null,
  shortDescription: null,
  editorAnnotation: null,
  isTicketsAvailable: null,
  productionStatus: null,
  ratingMpaa: null,
  ratingAgeLimits: null,
  hasImax: null,
  has3D: null,
  lastSync: null,
  startYear: null,
  endYear: null,
  serial: null,
  shortFilm: null,
  completed: null,
);

// Функция для создания полной FilmEntity (из FilmDetailModel)
FilmEntity _buildFullFilmEntity({
  // FilmBaseInformation
  int? kinopoiskId = 301,
  String? nameRu = "Матрица",
  String? nameEn = "The Matrix",
  String? nameOriginal = "The Matrix",
  List<String>? countries = const ["США"],
  List<String>? genres = const ["Фантастика"],
  num? ratingKinopoisk = 8.5,
  num? ratingImbd = 8.7,
  int? year = 1999,
  String? type = "FILM",
  String? posterUrl = "https://kinopoiskapiunofficial.tech/images/posters/kp/301.jpg",
  String? posterUrlPreview = "https://kinopoiskapiunofficial.tech/images/posters/kp_small/301.jpg",
  bool? isSaved = false,
  // FilmDetailInformation
  String? kinopoiskHDId = "4824a95e60a7db7e86f14137516ba590",
  String? imdbId = "tt0133093",
  String? coverUrl = "https://avatars.mds.yandex.net/get-ott/1672343/2a0000016cc7177239d4025185c488b1bf43/orig",
  String? logoUrl = "https://avatars.mds.yandex.net/get-ott/1648503/2a00000170a5418408119bc802b53a03007b/orig",
  int? reviewsCount = 293,
  num? ratingGoodReview = 88.9,
  int? ratingGoodReviewVoteCount = 257,
  int? ratingKinopoiskVoteCount = 524108,
  int? ratingImdbVoteCount = 1729087,
  num? ratingFilmCritics = 7.8,
  int? ratingFilmCriticsVoteCount = 155,
  num? ratingAwait = 7.8,
  int? ratingAwaitCount = 2,
  num? ratingRfCritics = 7.8,
  int? ratingRfCriticsVoteCount = 31,
  String? webUrl = "https://www.kinopoisk.ru/film/301/",
  int? filmLength = 136,
  String? slogan = "Добро пожаловать в реальный мир",
  String? description = "Жизнь Томаса Андерсона разделена на две части:",
  String? shortDescription = "Хакер Нео узнает, что его мир — виртуальный. Выдающийся экшен, доказавший, что зрелищное кино может быть умным",
  String? editorAnnotation = "Фильм доступен только на языке оригинала с русскими субтитрами",
  bool? isTicketsAvailable = false,
  String? productionStatus = "POST_PRODUCTION",
  String? ratingMpaa = "r",
  String? ratingAgeLimits = "age16",
  bool? hasImax = false,
  bool? has3D = false,
  String? lastSync = "2021-07-29T20:07:49.109817",
  int? startYear = 1996,
  int? endYear = 1996,
  bool? serial = false,
  bool? shortFilm = false,
  bool? completed = false,
}) => FilmEntity(
  // FilmBaseInformation
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
  posterUrlPreview: posterUrlPreview,
  isSaved: isSaved,
  // FilmDetailInformation
  kinopoiskHDId: kinopoiskHDId,
  imdbId: imdbId,
  coverUrl: coverUrl,
  logoUrl: logoUrl,
  reviewsCount: reviewsCount,
  ratingGoodReview: ratingGoodReview,
  ratingGoodReviewVoteCount: ratingGoodReviewVoteCount,
  ratingKinopoiskVoteCount: ratingKinopoiskVoteCount,
  ratingImdbVoteCount: ratingImdbVoteCount,
  ratingFilmCritics: ratingFilmCritics,
  ratingFilmCriticsVoteCount: ratingFilmCriticsVoteCount,
  ratingAwait: ratingAwait,
  ratingAwaitCount: ratingAwaitCount,
  ratingRfCritics: ratingRfCritics,
  ratingRfCriticsVoteCount: ratingRfCriticsVoteCount,
  webUrl: webUrl,
  filmLength: filmLength,
  slogan: slogan,
  description: description,
  shortDescription: shortDescription,
  editorAnnotation: editorAnnotation,
  isTicketsAvailable: isTicketsAvailable,
  productionStatus: productionStatus,
  ratingMpaa: ratingMpaa,
  ratingAgeLimits: ratingAgeLimits,
  hasImax: hasImax,
  has3D: has3D,
  lastSync: lastSync,
  startYear: startYear,
  endYear: endYear,
  serial: serial,
  shortFilm: shortFilm,
  completed: completed,
);

FilmDetailModel _buildFilmDetailModel({
  // FilmBaseModel параметры
  int? kinopoiskId = 301,
  String? nameRu = "Матрица",
  String? nameEn = "The Matrix",
  String? nameOriginal = "The Matrix",
  List<String>? countries = const ["США"],
  List<String>? genres = const ["Фантастика"],
  num? ratingKinopoisk = 8.5,
  num? ratingImbd = 8.7,
  int? year = 1999,
  String? type = "FILM",
  String? posterUrl = "https://kinopoiskapiunofficial.tech/images/posters/kp/301.jpg",
  String? posterUrlPreview = "https://kinopoiskapiunofficial.tech/images/posters/kp_small/301.jpg",
  bool? isSaved = false,
  // Дополнительные параметры FilmDetailModel
  String? kinopoiskHDId = "4824a95e60a7db7e86f14137516ba590",
  String? imdbId = "tt0133093",
  String? coverUrl = "https://avatars.mds.yandex.net/get-ott/1672343/2a0000016cc7177239d4025185c488b1bf43/orig",
  String? logoUrl = "https://avatars.mds.yandex.net/get-ott/1648503/2a00000170a5418408119bc802b53a03007b/orig",
  int? reviewsCount = 293,
  num? ratingGoodReview = 88.9,
  int? ratingGoodReviewVoteCount = 257,
  int? ratingKinopoiskVoteCount = 524108,
  int? ratingImdbVoteCount = 1729087,
  num? ratingFilmCritics = 7.8,
  int? ratingFilmCriticsVoteCount = 155,
  num? ratingAwait = 7.8,
  int? ratingAwaitCount = 2,
  num? ratingRfCritics = 7.8,
  int? ratingRfCriticsVoteCount = 31,
  String? webUrl = "https://www.kinopoisk.ru/film/301/",
  int? filmLength = 136,
  String? slogan = "Добро пожаловать в реальный мир",
  String? description = "Жизнь Томаса Андерсона разделена на две части:",
  String? shortDescription = "Хакер Нео узнает, что его мир — виртуальный. Выдающийся экшен, доказавший, что зрелищное кино может быть умным",
  String? editorAnnotation = "Фильм доступен только на языке оригинала с русскими субтитрами",
  bool? isTicketsAvailable = false,
  String? productionStatus = "POST_PRODUCTION",
  String? ratingMpaa = "r",
  String? ratingAgeLimits = "age16",
  bool? hasImax = false,
  bool? has3D = false,
  String? lastSync = "2021-07-29T20:07:49.109817",
  int? startYear = 1996,
  int? endYear = 1996,
  bool? serial = false,
  bool? shortFilm = false,
  bool? completed = false,
}) {
  final filmBaseModel = FilmBaseModel(
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
    posterUrlPreview: posterUrlPreview,
    isSaved: isSaved,
  );

  return FilmDetailModel(
    filmBaseModel: filmBaseModel,
    kinopoiskHDId: kinopoiskHDId,
    imdbId: imdbId,
    coverUrl: coverUrl,
    logoUrl: logoUrl,
    reviewsCount: reviewsCount,
    ratingGoodReview: ratingGoodReview,
    ratingGoodReviewVoteCount: ratingGoodReviewVoteCount,
    ratingKinopoiskVoteCount: ratingKinopoiskVoteCount,
    ratingImdbVoteCount: ratingImdbVoteCount,
    ratingFilmCritics: ratingFilmCritics,
    ratingFilmCriticsVoteCount: ratingFilmCriticsVoteCount,
    ratingAwait: ratingAwait,
    ratingAwaitCount: ratingAwaitCount,
    ratingRfCritics: ratingRfCritics,
    ratingRfCriticsVoteCount: ratingRfCriticsVoteCount,
    webUrl: webUrl,
    filmLength: filmLength,
    slogan: slogan,
    description: description,
    shortDescription: shortDescription,
    editorAnnotation: editorAnnotation,
    isTicketsAvailable: isTicketsAvailable,
    productionStatus: productionStatus,
    ratingMpaa: ratingMpaa,
    ratingAgeLimits: ratingAgeLimits,
    hasImax: hasImax,
    has3D: has3D,
    lastSync: lastSync,
    startYear: startYear,
    endYear: endYear,
    serial: serial,
    shortFilm: shortFilm,
    completed: completed,
  );
}

FilmImagesModel _buildFilmImagesModel({
  List<String> imageUrls = const [
    "https://avatars.mds.yandex.net/get-kinopoisk-image/10809116/1fee8dfa-7c3f-412a-aa1c-f3d2700d2e85/orig",
    "https://avatars.mds.yandex.net/get-kinopoisk-image/9784475/4e394795-b31d-451b-9e04-989bf813a050/orig"
  ],
  List<String> previewUrls = const [
    "https://avatars.mds.yandex.net/get-kinopoisk-image/10809116/1fee8dfa-7c3f-412a-aa1c-f3d2700d2e85/300x",
    "https://avatars.mds.yandex.net/get-kinopoisk-image/9784475/4e394795-b31d-451b-9e04-989bf813a050/300x"
  ]
}) => FilmImagesModel(
  imageUrls: imageUrls,
  previewUrls: previewUrls
);

FilmImagesEntity _buildFilmImagesEntity({
  List<String> imageUrls = const [
    "https://avatars.mds.yandex.net/get-kinopoisk-image/10809116/1fee8dfa-7c3f-412a-aa1c-f3d2700d2e85/orig",
    "https://avatars.mds.yandex.net/get-kinopoisk-image/9784475/4e394795-b31d-451b-9e04-989bf813a050/orig"
  ],
  List<String> previewUrls = const [
    "https://avatars.mds.yandex.net/get-kinopoisk-image/10809116/1fee8dfa-7c3f-412a-aa1c-f3d2700d2e85/300x",
    "https://avatars.mds.yandex.net/get-kinopoisk-image/9784475/4e394795-b31d-451b-9e04-989bf813a050/300x"
  ]
}) => FilmImagesEntity(
  imageUrls: imageUrls,
  previewUrls: previewUrls 
);

void main(){
  late FilmRepositoryImpl filmRepositoryImpl;
  late MockFilmRemoteDataSource mockFilmRemoteDataSource;
  late MockFilmLocalDataSource mockFilmLocalDataSource;

  setUpAll(() {
    registerFallbackValue(FakeFilmBaseModel());
    registerFallbackValue(FakeFilmDetailModel());
    registerFallbackValue(FakeFilmEntity());
    registerFallbackValue(FakeFilmImagesModel());
    registerFallbackValue(FakeFilmImagesEntity());
  });

  setUp(() {
    mockFilmRemoteDataSource = MockFilmRemoteDataSource();
    mockFilmLocalDataSource = MockFilmLocalDataSource();
    filmRepositoryImpl = FilmRepositoryImpl(
      filmRemoteDataSource: mockFilmRemoteDataSource, 
      filmLocalDataSource: mockFilmLocalDataSource
    );
  });

  group("getCollectionFilms", () {
    const collectionName = "TOP_POPULAR_MOVIES";
    const page = 1;
    
    final testFilmBaseModel1 = _buildFilmBaseModel(kinopoiskId: 1, nameRu: "Фильм 1");
    final testFilmBaseModel2 = _buildFilmBaseModel(kinopoiskId: 2, nameRu: "Фильм 2");
    final List<FilmBaseModel> testFilmBaseModelList = [testFilmBaseModel1, testFilmBaseModel2];
    
    test('should return List<FilmEntity> when remote data source returns List<FilmBaseModel>', () async {
      when(() => mockFilmRemoteDataSource.getCollectionFilms(collectionName, page))
          .thenAnswer((_) async => testFilmBaseModelList);
      when(() => mockFilmLocalDataSource.filmIsSaved(1)).thenAnswer((_) async => false);
      when(() => mockFilmLocalDataSource.filmIsSaved(2)).thenAnswer((_) async => false);
      
      final expectedEntity1 = _buildFilmEntityFromBaseModel(
        kinopoiskId: 1, 
        nameRu: "Фильм 1",
        isSaved: false
      );
      final expectedEntity2 = _buildFilmEntityFromBaseModel(
        kinopoiskId: 2, 
        nameRu: "Фильм 2",
        isSaved: false
      );
      final expectedList = [expectedEntity1, expectedEntity2];
      
      final result = await filmRepositoryImpl.getCollectionFilms(collectionName, page);
      
      expect(result, equals(expectedList));
      verify(() => mockFilmRemoteDataSource.getCollectionFilms(collectionName, page)).called(1);
      verify(() => mockFilmLocalDataSource.filmIsSaved(1)).called(1);
      verify(() => mockFilmLocalDataSource.filmIsSaved(2)).called(1);
    });

    test('should set isSaved=true for films that are saved locally', () async {
      when(() => mockFilmRemoteDataSource.getCollectionFilms(collectionName, page))
          .thenAnswer((_) async => testFilmBaseModelList);
      when(() => mockFilmLocalDataSource.filmIsSaved(1)).thenAnswer((_) async => true);
      when(() => mockFilmLocalDataSource.filmIsSaved(2)).thenAnswer((_) async => false);
      
      final expectedEntity1 = _buildFilmEntityFromBaseModel(
        kinopoiskId: 1, 
        nameRu: "Фильм 1",
        isSaved: true
      );
      final expectedEntity2 = _buildFilmEntityFromBaseModel(
        kinopoiskId: 2, 
        nameRu: "Фильм 2",
        isSaved: false
      );
      final expectedList = [expectedEntity1, expectedEntity2];
      
      final result = await filmRepositoryImpl.getCollectionFilms(collectionName, page);
      
      expect(result, equals(expectedList));
    });

    test('should return NULL when remote data source returns NULL', () async {
      when(() => mockFilmRemoteDataSource.getCollectionFilms(collectionName, page))
          .thenAnswer((_) async => null);
      
      final result = await filmRepositoryImpl.getCollectionFilms(collectionName, page);
      
      expect(result, isNull);
      verify(() => mockFilmRemoteDataSource.getCollectionFilms(collectionName, page)).called(1);
      verifyNever(() => mockFilmLocalDataSource.filmIsSaved(any()));
    });

    test('should rethrow RemoteDataSourceException when remote data source throws RemoteDataSourceException', () async {
      when(() => mockFilmRemoteDataSource.getCollectionFilms(collectionName, page))
          .thenThrow(RemoteDataSourceException(
            DioExceptionType.connectionError, 
            HttpStatus.connectionClosedWithoutResponse
          ));
      
      expect(
        () => filmRepositoryImpl.getCollectionFilms(collectionName, page), 
        throwsA(isA<RemoteDataSourceException>())
      );
    });

    test('should rethrow Exception when remote data source throws Exception', () async {
      when(() => mockFilmRemoteDataSource.getCollectionFilms(collectionName, page))
          .thenThrow(Exception());
      
      expect(
        () => filmRepositoryImpl.getCollectionFilms(collectionName, page), 
        throwsA(isA<Exception>())
      );
    });    
  });

  group("getFilmInformation", () {
    const idFilm = 301;
    final testFilmDetailModel = _buildFilmDetailModel();
    final testFilmEntity = _buildFullFilmEntity();

    test('should return FilmEntity when remote data source returns FilmDetailModel', () async {
      when(() => mockFilmRemoteDataSource.getFilmInformation(idFilm))
          .thenAnswer((_) async => testFilmDetailModel);
      
      final result = await filmRepositoryImpl.getFilmInformation(idFilm);
      
      expect(result, equals(testFilmEntity));
      verify(() => mockFilmRemoteDataSource.getFilmInformation(idFilm)).called(1);
    });

    test('should return NULL when remote data source returns NULL', () async {
      when(() => mockFilmRemoteDataSource.getFilmInformation(idFilm))
          .thenAnswer((_) async => null);
      
      final result = await filmRepositoryImpl.getFilmInformation(idFilm);
      
      expect(result, isNull);
      verify(() => mockFilmRemoteDataSource.getFilmInformation(idFilm)).called(1);
    });

    test('should rethrow RemoteDataSourceException when remote data source throws RemoteDataSourceException', () async {
      when(() => mockFilmRemoteDataSource.getFilmInformation(idFilm))
          .thenThrow(RemoteDataSourceException(
            DioExceptionType.connectionError, 
            HttpStatus.connectionClosedWithoutResponse
          ));
      
      expect(
        () => filmRepositoryImpl.getFilmInformation(idFilm), 
        throwsA(isA<RemoteDataSourceException>())
      );
    });

    test('should rethrow Exception when remote data source throws Exception', () async {
      when(() => mockFilmRemoteDataSource.getFilmInformation(idFilm))
          .thenThrow(Exception());
      
      expect(
        () => filmRepositoryImpl.getFilmInformation(idFilm), 
        throwsA(isA<Exception>())
      );
    });    
  });

  group("getFilmImages", () {
    const idFilm = 301;
    final testFilmImagesModel = _buildFilmImagesModel();
    final testFilmImagesEntity = _buildFilmImagesEntity();

    test('should return FilmImagesEntity when remote data source returns FilmImagesModel', () async {
      when(() => mockFilmRemoteDataSource.getFilmImageUrls(idFilm))
          .thenAnswer((_) async => testFilmImagesModel);
      
      final result = await filmRepositoryImpl.getFilmImages(idFilm);
      
      expect(result, equals(testFilmImagesEntity));
      verify(() => mockFilmRemoteDataSource.getFilmImageUrls(idFilm)).called(1);
    });

    test('should return NULL when remote data source returns NULL', () async {
      when(() => mockFilmRemoteDataSource.getFilmImageUrls(idFilm))
          .thenAnswer((_) async => null);
      
      final result = await filmRepositoryImpl.getFilmImages(idFilm);
      
      expect(result, isNull);
      verify(() => mockFilmRemoteDataSource.getFilmImageUrls(idFilm)).called(1);
    });

    test('should rethrow RemoteDataSourceException when remote data source throws RemoteDataSourceException', () async {
      when(() => mockFilmRemoteDataSource.getFilmImageUrls(idFilm))
          .thenThrow(RemoteDataSourceException(
            DioExceptionType.connectionError, 
            HttpStatus.connectionClosedWithoutResponse
          ));
      
      expect(
        () => filmRepositoryImpl.getFilmImages(idFilm), 
        throwsA(isA<RemoteDataSourceException>())
      );
    });

    test('should rethrow Exception when remote data source throws Exception', () async {
      when(() => mockFilmRemoteDataSource.getFilmImageUrls(idFilm))
          .thenThrow(Exception());
      
      expect(
        () => filmRepositoryImpl.getFilmImages(idFilm), 
        throwsA(isA<Exception>())
      );
    });    
  });

  group("filmIsSaved", () {
    const idFilm = 301;

    test('should return true when film is saved locally', () async {
      when(() => mockFilmLocalDataSource.filmIsSaved(idFilm))
          .thenAnswer((_) async => true);
      
      final result = await filmRepositoryImpl.filmIsSaved(idFilm);
      
      expect(result, true);
      verify(() => mockFilmLocalDataSource.filmIsSaved(idFilm)).called(1);
    });

    test('should return false when film is not saved locally', () async {
      when(() => mockFilmLocalDataSource.filmIsSaved(idFilm))
          .thenAnswer((_) async => false);
      
      final result = await filmRepositoryImpl.filmIsSaved(idFilm);
      
      expect(result, false);
      verify(() => mockFilmLocalDataSource.filmIsSaved(idFilm)).called(1);
    });

    test('should rethrow LocalDataSourceException when local data source throws LocalDataSourceException', () async {
      when(() => mockFilmLocalDataSource.filmIsSaved(idFilm))
          .thenThrow(LocalDataSourceException(message: "Error"));

      expect(
        () => filmRepositoryImpl.filmIsSaved(idFilm), 
        throwsA(isA<LocalDataSourceException>())
      );
    });

    test('should rethrow Exception when local data source throws Exception', () async {
      when(() => mockFilmLocalDataSource.filmIsSaved(idFilm))
          .thenThrow(Exception());
      
      expect(
        () => filmRepositoryImpl.filmIsSaved(idFilm), 
        throwsA(isA<Exception>())
      );
    });
  });

  group("addFilmInLocalDataSource", () {
    final testFilmDetailModel = _buildFilmDetailModel();
    final savedFilmsList = [testFilmDetailModel];

    test('should add film and update stream', () async {
      when(() => mockFilmLocalDataSource.addFilm(testFilmDetailModel))
          .thenAnswer((_) async => {});
      when(() => mockFilmLocalDataSource.getAllFilms())
          .thenAnswer((_) async => savedFilmsList);
      
      final streamEvents = <List<FilmDetailModel>>[];
      final subscription = filmRepositoryImpl.watchSavedFilms().listen((event) {
        streamEvents.add(event);
      });

      await filmRepositoryImpl.addFilmInLocalDataSource(testFilmDetailModel);
      
      await Future.delayed(Duration.zero);
      
      verify(() => mockFilmLocalDataSource.addFilm(testFilmDetailModel)).called(1);
      verify(() => mockFilmLocalDataSource.getAllFilms()).called(1);
      expect(streamEvents, contains(savedFilmsList));
      
      await subscription.cancel();
    });

    test('should rethrow LocalDataSourceException when local data source throws LocalDataSourceException', () async {
      when(() => mockFilmLocalDataSource.addFilm(testFilmDetailModel))
          .thenThrow(LocalDataSourceException(message: "Error"));

      expect(
        () => filmRepositoryImpl.addFilmInLocalDataSource(testFilmDetailModel), 
        throwsA(isA<LocalDataSourceException>())
      );
    });

    test('should rethrow Exception when local data source throws Exception', () async {
      when(() => mockFilmLocalDataSource.addFilm(testFilmDetailModel))
          .thenThrow(Exception());
      
      expect(
        () => filmRepositoryImpl.addFilmInLocalDataSource(testFilmDetailModel), 
        throwsA(isA<Exception>())
      );
    });
  });

  group("getFilmFromLocalDataSource", () {
    const idFilm = 301;
    final testFilmDetailModel = _buildFilmDetailModel();

    test('should return FilmDetailModel when film exists in local storage', () async {
      when(() => mockFilmLocalDataSource.getFilm(idFilm))
          .thenAnswer((_) async => testFilmDetailModel);
      
      final result = await filmRepositoryImpl.getFilmFromLocalDataSource(idFilm);
      
      expect(result, equals(testFilmDetailModel));
      verify(() => mockFilmLocalDataSource.getFilm(idFilm)).called(1);
    });

    test('should return NULL when film does not exist in local storage', () async {
      when(() => mockFilmLocalDataSource.getFilm(idFilm))
          .thenAnswer((_) async => null);
      
      final result = await filmRepositoryImpl.getFilmFromLocalDataSource(idFilm);
      
      expect(result, isNull);
      verify(() => mockFilmLocalDataSource.getFilm(idFilm)).called(1);
    });

    test('should rethrow LocalDataSourceException when local data source throws LocalDataSourceException', () async {
      when(() => mockFilmLocalDataSource.getFilm(idFilm))
          .thenThrow(LocalDataSourceException(message: "Error"));
      
      expect(
        () => filmRepositoryImpl.getFilmFromLocalDataSource(idFilm), 
        throwsA(isA<LocalDataSourceException>())
      );
    });

    test('should rethrow Exception when local data source throws Exception', () async {
      when(() => mockFilmLocalDataSource.getFilm(idFilm))
          .thenThrow(Exception());
      
      expect(
        () => filmRepositoryImpl.getFilmFromLocalDataSource(idFilm), 
        throwsA(isA<Exception>())
      );
    });
  });

  group("getAllFilmsFromLocalDataSource", () {
    final testFilmDetailModel1 = _buildFilmDetailModel(kinopoiskId: 1);
    final testFilmDetailModel2 = _buildFilmDetailModel(kinopoiskId: 2);
    final savedFilmsList = [testFilmDetailModel1, testFilmDetailModel2];

    test('should return list of saved films', () async {
      when(() => mockFilmLocalDataSource.getAllFilms())
          .thenAnswer((_) async => savedFilmsList);
      
      final result = await filmRepositoryImpl.getAllFilmsFromLocalDataSource();
      
      expect(result, equals(savedFilmsList));
      verify(() => mockFilmLocalDataSource.getAllFilms()).called(1);
    });

    test('should return NULL when no films saved', () async {
      when(() => mockFilmLocalDataSource.getAllFilms())
          .thenAnswer((_) async => null);
      
      final result = await filmRepositoryImpl.getAllFilmsFromLocalDataSource();
      
      expect(result, isNull);
      verify(() => mockFilmLocalDataSource.getAllFilms()).called(1);
    });

    test('should rethrow LocalDataSourceException when local data source throws LocalDataSourceException', () async {
      when(() => mockFilmLocalDataSource.getAllFilms())
          .thenThrow(LocalDataSourceException(message: "Error"));
      
      expect(
        () => filmRepositoryImpl.getAllFilmsFromLocalDataSource(), 
        throwsA(isA<LocalDataSourceException>())
      );
    });

    test('should rethrow Exception when local data source throws Exception', () async {
      when(() => mockFilmLocalDataSource.getAllFilms())
          .thenThrow(Exception());
      
      expect(
        () => filmRepositoryImpl.getAllFilmsFromLocalDataSource(), 
        throwsA(isA<Exception>())
      );
    });
  });

  group("removeFilmFromLocalDataSource", () {
    const idFilm = 301;
    final remainingFilmsList = [_buildFilmDetailModel(kinopoiskId: 2)];

    test('should remove film and update stream', () async {
      when(() => mockFilmLocalDataSource.removeFilm(idFilm))
          .thenAnswer((_) async => {});
      when(() => mockFilmLocalDataSource.getAllFilms())
          .thenAnswer((_) async => remainingFilmsList);
      
      final streamEvents = <List<FilmDetailModel>>[];
      final subscription = filmRepositoryImpl.watchSavedFilms().listen((event) {
        streamEvents.add(event);
      });
      
      await filmRepositoryImpl.removeFilmFromLocalDataSource(idFilm);
      
      await Future.delayed(Duration.zero);
      
      verify(() => mockFilmLocalDataSource.removeFilm(idFilm)).called(1);
      verify(() => mockFilmLocalDataSource.getAllFilms()).called(1);
      expect(streamEvents, contains(remainingFilmsList));
      
      await subscription.cancel();
    });

    test('should rethrow LocalDataSourceException when local data source throws LocalDataSourceException', () async {
      when(() => mockFilmLocalDataSource.removeFilm(idFilm))
          .thenThrow(LocalDataSourceException(message: "Error"));
      
      expect(
        () => filmRepositoryImpl.removeFilmFromLocalDataSource(idFilm), 
        throwsA(isA<LocalDataSourceException>())
      );
    });

    test('should rethrow Exception when local data source throws Exception', () async {
      when(() => mockFilmLocalDataSource.removeFilm(idFilm))
          .thenThrow(Exception());
      
      expect(
        () => filmRepositoryImpl.removeFilmFromLocalDataSource(idFilm), 
        throwsA(isA<Exception>())
      );
    });
  });

  group("removeAllFilmsFromLocalDataSource", () {
    test('should remove all films and update stream with empty list', () async {
      when(() => mockFilmLocalDataSource.removeAllFilms())
          .thenAnswer((_) async => {});
      
      final streamEvents = <List<FilmDetailModel>>[];
      final subscription = filmRepositoryImpl.watchSavedFilms().listen((event) {
        streamEvents.add(event);
      });
      
      await filmRepositoryImpl.removeAllFilmsFromLocalDataSource();
      
      await Future.delayed(Duration.zero);
      
      verify(() => mockFilmLocalDataSource.removeAllFilms()).called(1);
      expect(streamEvents.isNotEmpty, true);
      expect(streamEvents.last, []);
      
      await subscription.cancel();
    });

    test('should rethrow LocalDataSourceException when local data source throws LocalDataSourceException', () async {
      when(() => mockFilmLocalDataSource.removeAllFilms())
          .thenThrow(LocalDataSourceException(message: "Error"));

      expect(
        () => filmRepositoryImpl.removeAllFilmsFromLocalDataSource(), 
        throwsA(isA<LocalDataSourceException>())
      );
    });

    test('should rethrow Exception when local data source throws Exception', () async {
      when(() => mockFilmLocalDataSource.removeAllFilms())
          .thenThrow(Exception());
      
      expect(
        () => filmRepositoryImpl.removeAllFilmsFromLocalDataSource(), 
        throwsA(isA<Exception>())
      );
    });
  });

  group("getFilterFilms", () {
    const keyword = "matrix";
    const page = 1;
    
    final testFilmBaseModel1 = _buildFilmBaseModel(kinopoiskId: 1, nameRu: "Фильм 1");
    final testFilmBaseModel2 = _buildFilmBaseModel(kinopoiskId: 2, nameRu: "Фильм 2");
    final List<FilmBaseModel> testFilmBaseModelList = [testFilmBaseModel1, testFilmBaseModel2];
    
    test('should return List<FilmEntity> when remote data source returns List<FilmBaseModel>', () async {
      when(() => mockFilmRemoteDataSource.getFilterFilms(keyword, any(), any(), any(), any(), page))
          .thenAnswer((_) async => testFilmBaseModelList);
      when(() => mockFilmLocalDataSource.filmIsSaved(1)).thenAnswer((_) async => false);
      when(() => mockFilmLocalDataSource.filmIsSaved(2)).thenAnswer((_) async => false);
      
      final expectedEntity1 = _buildFilmEntityFromBaseModel(
        kinopoiskId: 1, 
        nameRu: "Фильм 1",
        isSaved: false
      );
      final expectedEntity2 = _buildFilmEntityFromBaseModel(
        kinopoiskId: 2, 
        nameRu: "Фильм 2",
        isSaved: false
      );
      final expectedList = [expectedEntity1, expectedEntity2];
      
      final result = await filmRepositoryImpl.getFilterFilms(keyword, null, null, null, null, page);
      
      expect(result, equals(expectedList));
      verify(() => mockFilmRemoteDataSource.getFilterFilms(keyword, any(), any(), any(), any(), page)).called(1);
      verify(() => mockFilmLocalDataSource.filmIsSaved(1)).called(1);
      verify(() => mockFilmLocalDataSource.filmIsSaved(2)).called(1);
    });

    test('should return NULL when remote data source returns NULL', () async {
      when(() => mockFilmRemoteDataSource.getFilterFilms(keyword, any(), any(), any(), any(), page))
          .thenAnswer((_) async => null);
      
      final result = await filmRepositoryImpl.getFilterFilms(keyword, null, null, null, null, page);
      
      expect(result, isNull);
      verify(() => mockFilmRemoteDataSource.getFilterFilms(keyword, any(), any(), any(), any(), page)).called(1);
      verifyNever(() => mockFilmLocalDataSource.filmIsSaved(any()));
    });
  });
}