import 'package:equatable/equatable.dart';
import 'package:movie_search_assistant_bloc/data/models/collection_model.dart';

class CollectionEntity extends Equatable {
  final String? collectionName;
  final DateTime? createdAt;
  final int? filmCount;

  const CollectionEntity({
    this.collectionName,
    this.createdAt,
    this.filmCount
  });

  factory CollectionEntity.fromCollectionModel(CollectionModel collectionModel){
    return CollectionEntity(
      collectionName: collectionModel.collectionName,
      createdAt: collectionModel.createdAt,
      filmCount: collectionModel.filmCount
    );
  }
  
  @override
  List<Object?> get props => [collectionName, createdAt, filmCount];
}