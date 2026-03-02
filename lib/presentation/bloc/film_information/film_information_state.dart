part of 'film_information_bloc.dart';

sealed class FilmInformationState extends Equatable {
  const FilmInformationState();
  
  @override
  List<Object> get props => [];
}

final class FilmInformationInitial extends FilmInformationState {}

final class FilmInformatinonLoading extends FilmInformationState {}

final class FilmInformationLoadedSuccessful extends FilmInformationState {
  final FilmEntity filmInformation;
  final FilmImagesEntity? filmImages;
  
  const FilmInformationLoadedSuccessful({
    required this.filmInformation,
    required this.filmImages,
  });

  FilmInformationLoadedSuccessful copyWith({
    FilmEntity? filmInformation,
    FilmImagesEntity? filmImages,
  }) {
    return FilmInformationLoadedSuccessful(
      filmInformation: filmInformation ?? this.filmInformation,
      filmImages: filmImages ?? this.filmImages,
    );
  }

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

final class FilmSavedSuccesful extends FilmInformationState {}

final class FilmRemovedSuccesful extends FilmInformationState {}

final class FilmSavedFailure extends FilmInformationState{
  final String message;

  const FilmSavedFailure({
    required this.message
  });

  @override
  List<Object> get props => [message];
}

final class FilmRemovedFailure extends FilmInformationState{
  final String message;

  const FilmRemovedFailure({
    required this.message
  });

  @override
  List<Object> get props => [message];
}