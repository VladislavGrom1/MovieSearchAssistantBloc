import 'package:hive_flutter/hive_flutter.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/util/constants/hive_storage_keys.dart';
import 'package:movie_search_assistant_bloc/data/models/collection_model.dart';
import 'package:movie_search_assistant_bloc/data/models/film_base_model.dart';
import 'package:movie_search_assistant_bloc/data/models/film_collection_link.dart';
import 'package:movie_search_assistant_bloc/data/models/film_detail_model.dart';
import 'package:movie_search_assistant_bloc/data/models/user_model.dart';

class HiveInit {
  static Future<void> init() async {
    try {
      await Hive.initFlutter();

      Hive.registerAdapter(UserModelAdapter());
      Hive.registerAdapter(FilmBaseModelAdapter());
      Hive.registerAdapter(FilmDetailModelAdapter());
      Hive.registerAdapter(CollectionModelAdapter());
      Hive.registerAdapter(FilmCollectionLinkAdapter());

      await Hive.openBox<UserModel>(HiveStorageKeys.userModelBox);
      await Hive.openBox<FilmDetailModel>(HiveStorageKeys.filmDetailModelBox);
      await Hive.openBox<CollectionModel>(HiveStorageKeys.collectionModelBox);
      await Hive.openBox<FilmCollectionLink>(HiveStorageKeys.filmCollectionLinkBox);
       
    } catch (e) {
      throw LocalDataSourceException(message: 'Hive initialization failed: $e');
    }
  }
}