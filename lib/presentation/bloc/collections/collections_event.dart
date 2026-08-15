part of 'collections_bloc.dart';

sealed class CollectionsEvent extends Equatable {
  const CollectionsEvent();

  @override
  List<Object> get props => [];
}

class GetCollections extends CollectionsEvent{}

class AddNewCollection extends CollectionsEvent{
  final String collectionName;

  const AddNewCollection({required this.collectionName});

  @override
  List<Object> get props => [collectionName];
}

class RemoveCollection extends CollectionsEvent{
  final String collectionId;

  const RemoveCollection({required this.collectionId});

  @override
  List<Object> get props => [collectionId];
}

class UpdateCollections extends CollectionsEvent{
  final List<CollectionEntity> updatedCollections;

  const UpdateCollections({required this.updatedCollections});

  @override
  List<Object> get props => [updatedCollections];
}

class ClearCollection extends CollectionsEvent{
  final String collectionId;

  const ClearCollection({required this.collectionId});

  @override
  List<Object> get props => [collectionId];
}

class RenameCollection extends CollectionsEvent{
  final CollectionEntity collection;
  final String updatedName;

  const RenameCollection({required this.collection, required this.updatedName});

  @override
  List<Object> get props => [collection, updatedName];
}

class UploadCollectionImage extends CollectionsEvent{
  final CollectionEntity collection;

  const UploadCollectionImage({required this.collection});

  @override
  List<Object> get props => [collection];
}

class RemoveCollectionImage extends CollectionsEvent{
  final CollectionEntity collection;
 
  const RemoveCollectionImage({required this.collection});
 
  @override
  List<Object> get props => [collection];
}
