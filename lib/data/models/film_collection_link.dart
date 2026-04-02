import 'package:hive_flutter/hive_flutter.dart';
part "film_collection_link.g.dart";

@HiveType(typeId: 4)
class FilmCollectionLink {
  @HiveField(0) final int filmId;
  @HiveField(1) final String collectionId;

  const FilmCollectionLink({
    required this.filmId,
    required this.collectionId
  });

  Map<String, dynamic> toJson() => {
    "filmId": filmId,
    "collectionId": collectionId,
  };

  factory FilmCollectionLink.fromJson(Map<String, dynamic> json) {
    return FilmCollectionLink(
      filmId: json["filmId"],
      collectionId: json["collectionId"],
    );
  }
}