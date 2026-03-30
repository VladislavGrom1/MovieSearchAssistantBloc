part of 'film_information_bloc.dart';

sealed class FilmInformationState extends Equatable {
  const FilmInformationState();

  @override
  List<Object?> get props => [];
}

class FilmInitial extends FilmInformationState{}

class FilmLoading extends FilmInformationState{}

class FilmLoaded extends FilmInformationState{
  final FilmEntity film;
  final FilmImagesEntity? filmImages;
  final List<String> collectionIds;

  const FilmLoaded({
    required this.film,
    required this.filmImages,
    required this.collectionIds
  });

  FilmLoaded copyWith({
    FilmEntity? film,
    FilmImagesEntity? filmImages,
    List<String>? collectionIds,
  }) {
    return FilmLoaded(
      film: film ?? this.film,
      filmImages: filmImages ?? this.filmImages,
      collectionIds: collectionIds ?? this.collectionIds,
    );
  }

  @override
  List<Object?> get props => [film, filmImages, collectionIds];
}

class FilmFailure extends FilmInformationState {
  final String message;

  const FilmFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class FilmActionFailure extends FilmInformationState{
  final String message;

  const FilmActionFailure({
    required this.message
  });

  @override
  List<Object?> get props => [message];
}

