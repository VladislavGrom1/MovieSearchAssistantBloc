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

final class CollectionAddedSuccess extends CollectionsLoaded {
  final String message;

  const CollectionAddedSuccess({
    required super.collections,
    required this.message
  });

  @override
  List<Object?> get props => [collections, message];
}

final class CollectionRemovedSuccess extends CollectionsLoaded {
  final String message;

  const CollectionRemovedSuccess({
    required super.collections,
    required this.message
  });

  @override
  List<Object?> get props => [collections, message];
}

final class CollectionClearedSuccess extends CollectionsLoaded {
  final String message;

  const CollectionClearedSuccess({
    required super.collections,
    required this.message
  });

  @override
  List<Object?> get props => [collections, message];
}

final class CollectionActionFailure extends CollectionsLoaded {
  final String message;

  const CollectionActionFailure({
    required super.collections,
    required this.message
  });

  @override
  List<Object?> get props => [collections, message];
}

// final class CollectionUpdatedSuccessful extends CollectionsState {}

// final class CollectionUpdatedFailure extends CollectionsState {}

// final class CollectionAddedSuccessful extends CollectionsState {}

// final class CollectionAddedFailure extends CollectionsState {}

// final class CollectionRemovedSuccessful extends CollectionsState {}

// final class CollectionRemovedFailure extends CollectionsState {}