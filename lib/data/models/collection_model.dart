import 'package:hive/hive.dart';
import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';

part 'collection_model.g.dart';

@HiveType(typeId: 3)
class CollectionModel {
  @HiveField(0) String? collectionName;
  @HiveField(1) DateTime? createdAt;
  @HiveField(2) int? filmCount;

  CollectionModel({
    this.collectionName,
    this.createdAt,
    this.filmCount
  });

  factory CollectionModel.fromCollectionEntity(CollectionEntity collectionEntity){
    return CollectionModel(
      collectionName: collectionEntity.collectionName,
      createdAt: collectionEntity.createdAt,
      filmCount: collectionEntity.filmCount
    );
  }
}