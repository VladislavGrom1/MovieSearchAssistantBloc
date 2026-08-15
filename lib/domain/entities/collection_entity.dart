import 'package:equatable/equatable.dart';
import 'package:movie_search_assistant_bloc/data/models/collection_model.dart';
import 'package:uuid/uuid.dart';

class CollectionEntity extends Equatable {
  final String? id;
  final String? name;
  final DateTime? createdAt;
  final int? filmCount;
  final String? imagePath;

  const CollectionEntity({
    this.id,
    this.name,
    this.createdAt,
    this.filmCount,
    this.imagePath
  });

  factory CollectionEntity.fromCollectionModel(CollectionModel collectionModel){
    return CollectionEntity(
      id: collectionModel.id,
      name: collectionModel.name,
      createdAt: collectionModel.createdAt,
      filmCount: 0,
      imagePath: collectionModel.imagePath
    );
  }

  factory CollectionEntity.create(String collectionName){
    return CollectionEntity(
      id: Uuid().v4(),
      name: collectionName,
      createdAt: DateTime.now(),
      filmCount: 0,
      imagePath: null
    );
  }

  CollectionEntity copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    int? filmCount,
    String? imagePath,
    bool clearImagePath = false
  }) {
    return CollectionEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      filmCount: filmCount ?? this.filmCount,
      imagePath: clearImagePath ? null : (imagePath ?? this.imagePath)
    );
  }
  
  @override
  List<Object?> get props => [name, createdAt, filmCount, imagePath];
}