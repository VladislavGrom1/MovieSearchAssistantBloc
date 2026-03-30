part of 'film_information_bloc.dart';

enum FilmStatus {
  initial,
  loading,
  success,
  failure,
}

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
  final FilmStatus status;

  const FilmLoaded({
    required this.film,
    required this.filmImages,
    required this.collectionIds,
    required this.status
  });

  FilmLoaded copyWith({
    FilmEntity? film,
    FilmImagesEntity? filmImages,
    List<String>? collectionIds,
    FilmStatus? status
  }) {
    return FilmLoaded(
      film: film ?? this.film,
      filmImages: filmImages ?? this.filmImages,
      collectionIds: collectionIds ?? this.collectionIds,
      status: status ?? this.status
    );
  }

  @override
  List<Object?> get props => [film, filmImages, collectionIds, status];
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

