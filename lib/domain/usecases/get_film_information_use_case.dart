import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_collection_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';

class GetFilmInformationUseCase {
  final FilmRepository filmRepository;
  final FilmCollectionRepository filmCollectionRepository;

  GetFilmInformationUseCase({
    required this.filmRepository,
    required this.filmCollectionRepository,
  });

  Future<(FilmEntity?, List<String> collectionIds)> call(int idFilm) async{
    try{
      List<String> collectionIds = [];
      FilmEntity? filmEntity = await filmRepository.getFilmInformation(idFilm);
      collectionIds = await filmCollectionRepository.getCollectionIdsByFilmId(idFilm);
      return (filmEntity, collectionIds); 
    } on RemoteDataSourceException{
      rethrow;
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}