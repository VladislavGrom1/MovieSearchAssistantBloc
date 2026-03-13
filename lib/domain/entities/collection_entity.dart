import 'package:equatable/equatable.dart';
import 'package:movie_search_assistant_bloc/data/models/collection_model.dart';
import 'package:uuid/uuid.dart';

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

  factory CollectionEntity.create(String collectionName){
    return CollectionEntity(
      id: Uuid().v4(),
      name: collectionName,
      createdAt: DateTime.now(),
      filmCount: 0
    );
  }
  
  @override
  List<Object?> get props => [name, createdAt, filmCount];
}