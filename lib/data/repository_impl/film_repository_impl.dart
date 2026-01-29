import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/remote/film_remote_data_source.dart';
import 'package:movie_search_assistant_bloc/data/models/film_card_model.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_card_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class FilmRepositoryImpl implements FilmRepository{
  final FilmRemoteDataSource filmRemoteDataSource;

  FilmRepositoryImpl({required this.filmRemoteDataSource});
  
  @override
  Future<List<FilmCardEntity>?> getCollectionFilms(String apiKey, String collectionName, int page) async {
    try{
      List<FilmCardEntity> collectionFilmsEntity = [];
      List<FilmCardModel>? collectionFilmsModel = await filmRemoteDataSource.getCollectionFilms(apiKey, collectionName, page);
      if(collectionFilmsModel != null){
        for(var film in collectionFilmsModel){
          collectionFilmsEntity.add(FilmCardEntity(
            kinopoiskId: film.kinopoiskId,
            nameRu: film.nameRu,
            nameEn: film.nameEn,
            nameOriginal: film.nameOriginal,
            ratingKinopoisk: film.ratingKinopoisk
          ));
        }
        return collectionFilmsEntity;
      }
      return null;
    } on RemoteDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}