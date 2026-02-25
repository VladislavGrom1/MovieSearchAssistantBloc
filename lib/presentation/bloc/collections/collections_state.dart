part of 'collections_bloc.dart';

sealed class CollectionsState extends Equatable {
  const CollectionsState();
  
  @override
  List<Object> get props => [];
}

final class CollectionsInitial extends CollectionsState {}

final class CollectionsLoading extends CollectionsState {}

final class CollectionsLoadedSuccesful extends CollectionsState {
  final List<CollectionEntity> collections;

  const CollectionsLoadedSuccesful({required this.collections});

  CollectionsLoadedSuccesful copyWith({
    List<CollectionEntity>? collections
  }) {
    return CollectionsLoadedSuccesful(
      collections: collections ?? this.collections
    );
  } 

  @override
  List<Object> get props => [collections]; 
}

final class CollectionsLoadedFailure extends CollectionsState {
  final String exceptionType;
  final int? statusCode;
  
  const CollectionsLoadedFailure({required this.exceptionType, this.statusCode});

  @override
  List<Object> get props => [exceptionType, if (statusCode != null) statusCode!];
}
