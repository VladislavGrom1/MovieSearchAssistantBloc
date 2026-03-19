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

  @override
  List<Object?> get props => [film, filmImages, collectionIds];
}

class FilmFailure extends FilmInformationState {
  final String message;

  const FilmFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class FilmActionFailure extends FilmLoaded{
  final String message;

  const FilmActionFailure({
    required super.film,
    required super.filmImages,
    required super.collectionIds,
    required this.message
  });

  @override
  List<Object?> get props => [film, filmImages, collectionIds, message];
}

