import 'package:hive/hive.dart';
import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';

part 'collection_model.g.dart';

@HiveType(typeId: 3)
class CollectionModel {
  @HiveField(0) String? id;
  @HiveField(1) String? name;
  @HiveField(2) DateTime? createdAt;
  @HiveField(3) int? filmCount;

  CollectionModel({
    this.id,
    this.name,
    this.createdAt,
    this.filmCount
  });

  factory CollectionModel.fromCollectionEntity(CollectionEntity collectionEntity){
    return CollectionModel(
      id: collectionEntity.id,
      name: collectionEntity.name,
      createdAt: collectionEntity.createdAt,
      filmCount: collectionEntity.filmCount
    );
  }
}