part of 'film_information_bloc.dart';

sealed class FilmInformationState extends Equatable {
  const FilmInformationState();
  
  @override
  List<Object> get props => [];
}

final class FilmInformationInitial extends FilmInformationState {}

final class FilmInformatinonLoading extends FilmInformationState {}

final class FilmInformationLoadedSuccessful extends FilmInformationState {
  final FilmInformationEntity filmInformation;
  final FilmImagesEntity? filmImages;
  
  const FilmInformationLoadedSuccessful({
    required this.filmInformation,
    required this.filmImages
  });

  @override
  List<Object> get props => [filmInformation, if (filmImages != null) filmImages!];
}

final class FilmInformationLoadedFailure extends FilmInformationState{
  final String exceptionType;
  final int? statusCode;
  
  const FilmInformationLoadedFailure({required this.exceptionType, this.statusCode});

  @override
  List<Object> get props => [exceptionType, if (statusCode != null) statusCode!];
}
