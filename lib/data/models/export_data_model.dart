import 'package:movie_search_assistant_bloc/data/models/collection_model.dart';
import 'package:movie_search_assistant_bloc/data/models/film_collection_link.dart';
import 'package:movie_search_assistant_bloc/data/models/film_detail_model.dart';

class ExportDataModel {
  final List<FilmDetailModel> films;
  final List<CollectionModel> collections;
  final List<FilmCollectionLink> links;

  ExportDataModel({
    required this.films,
    required this.collections,
    required this.links,
  });

  Map<String, dynamic> toJson() => {
    "films": films.map((e) => e.toJson()).toList(),
    "collections": collections.map((e) => e.toJson()).toList(),
    "links": links.map((e) => e.toJson()).toList(),
  };

  factory ExportDataModel.fromJson(Map<String, dynamic> json) {
    return ExportDataModel(
      films: (json["films"] as List).map((e) => FilmDetailModel.fromJson(e)).toList(),
      collections: (json["collections"] as List).map((e) => CollectionModel.fromJson(e)).toList(),
      links: (json["links"] as List).map((e) => FilmCollectionLink.fromJson(e)).toList(),
    );
  }
}