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

class RemoveCollection extends CollectionsEvent{
  final String collectionName;

  const RemoveCollection({required this.collectionName});

  @override
  List<Object> get props => [collectionName];
}
