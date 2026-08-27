
import 'package:movie_search_assistant_bloc/app/api/dio_api_client.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/entities/user_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/film_repository.dart';
import 'package:movie_search_assistant_bloc/domain/repository/user_repository.dart';

class GetCollectionsFilmsUseCase {
  final UserRepository userRepository;
  final FilmRepository filmRepository;
  final DioApiClient apiClient;

  GetCollectionsFilmsUseCase({
    required this.userRepository,
    required this.filmRepository, 
    required this.apiClient
  });

  Future<Map<String, List<FilmEntity>?>?> call(List<String> collectionNames) async{
    try{
      final results = await Future.wait(
        collectionNames.map((name) => filmRepository.getCollectionFilms(name, 1))
      );

      return Map.fromIterables(collectionNames, results);
    } on RemoteDataSourceException{
      rethrow;
    } on LocalDataSourceException{
      rethrow;
    } catch(e){
      rethrow;
    }
  }
}