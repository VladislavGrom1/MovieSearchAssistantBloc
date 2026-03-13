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

  const FilmLoaded({
    required this.film,
    required this.filmImages
  });

  @override
  List<Object?> get props => [film, filmImages];
}

class FilmFailure extends FilmInformationState {
  final String message;

  const FilmFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class FilmActionSuccess extends FilmLoaded{
  final String message;

  const FilmActionSuccess({
    required super.film,
    required super.filmImages,
    required this.message
  });

  @override
  List<Object?> get props => [film, filmImages, message];
}

class FilmActionFailure extends FilmLoaded{
  final String message;

  const FilmActionFailure({
    required super.film,
    required super.filmImages,
    required this.message
  });

  @override
  List<Object?> get props => [film, filmImages, message];
}

