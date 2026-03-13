part of 'collection_films_bloc.dart';

sealed class CollectionFilmsState extends Equatable {
  const CollectionFilmsState();
  
  @override
  List<Object?> get props => [];
}

final class CollectionFilmsInitial extends CollectionFilmsState {}

final class CollectionFilmsLoading extends CollectionFilmsState {}

final class CollectionFilmsLoaded extends CollectionFilmsState {
  final String collectionId;
  final List<FilmEntity>? savedFilms;

  const CollectionFilmsLoaded({
    required this.collectionId,
    required this.savedFilms
  });

  @override
  List<Object?> get props => [savedFilms];
}

final class CollectionFilmsFailure extends CollectionFilmsState {
  final String message;

  const CollectionFilmsFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
