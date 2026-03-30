part of 'collections_bloc.dart';

sealed class CollectionsState extends Equatable {
  const CollectionsState();
  
  @override
  List<Object?> get props => [];
}

final class CollectionsInitial extends CollectionsState {}

final class CollectionsLoading extends CollectionsState {}

final class CollectionsLoaded extends CollectionsState {
  final List<CollectionEntity> collections;

  const CollectionsLoaded({required this.collections});

  @override
  List<Object?> get props => [collections]; 
}

final class CollectionsFailure extends CollectionsState {
  final String message;
  
  const CollectionsFailure({required this.message});

  @override
  List<Object> get props => [message];
}