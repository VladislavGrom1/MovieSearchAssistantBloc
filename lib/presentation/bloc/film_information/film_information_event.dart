part of 'film_information_bloc.dart';

sealed class FilmInformationEvent extends Equatable {
  const FilmInformationEvent();

  @override
  List<Object> get props => [];
}

class DisplayFilmInformationEvent extends FilmInformationEvent{
  final int idFilm;

  const DisplayFilmInformationEvent({required this.idFilm});
}

class SaveFilmEvent extends FilmInformationEvent{
  final FilmEntity film;

  const SaveFilmEvent({required this.film});
}

class RemoveFilmEvent extends FilmInformationEvent{
  final FilmEntity film;

  const RemoveFilmEvent({required this.film});
}