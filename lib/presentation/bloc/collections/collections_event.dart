part of 'collections_bloc.dart';

sealed class CollectionsEvent extends Equatable {
  const CollectionsEvent();

  @override
  List<Object> get props => [];
}

class DisplayCollections extends CollectionsEvent{}

class AddNewCollection extends CollectionsEvent{
  final String nameCollection;

  const AddNewCollection({required this.nameCollection});

  @override
  List<Object> get props => [nameCollection];
}

class UpdateCollection extends CollectionsEvent{
  final CollectionEntity collection;

  const UpdateCollection({required this.collection});

  @override
  List<Object> get props => [collection];
}

class RemoveCollection extends CollectionsEvent{
  final String collectionId;

  const RemoveCollection({required this.collectionId});

  @override
  List<Object> get props => [collectionId];
}
