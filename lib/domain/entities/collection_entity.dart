import 'package:equatable/equatable.dart';
import 'package:movie_search_assistant_bloc/data/models/collection_model.dart';

class CollectionEntity extends Equatable {
  final String? id;
  final String? name;
  final DateTime? createdAt;
  final int? filmCount;

  const CollectionEntity({
    this.id,
    this.name,
    this.createdAt,
    this.filmCount
  });

  factory CollectionEntity.fromCollectionModel(CollectionModel collectionModel){
    return CollectionEntity(
      id: collectionModel.id,
      name: collectionModel.name,
      createdAt: collectionModel.createdAt,
      filmCount: collectionModel.filmCount
    );
  }
  
  @override
  List<Object?> get props => [name, createdAt, filmCount];
}