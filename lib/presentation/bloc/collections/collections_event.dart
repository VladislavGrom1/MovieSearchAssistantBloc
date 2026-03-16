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
