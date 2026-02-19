part of 'film_information_bloc.dart';

sealed class FilmInformationState extends Equatable {
  const FilmInformationState();
  
  @override
  List<Object> get props => [];
}

final class FilmInformationInitial extends FilmInformationState {}

final class FilmInformatinonLoading extends FilmInformationState {}

final class FilmInformationLoaded extends FilmInformationState {
  final FilmEntity filmInformation;
  final FilmImagesEntity? filmImages;
  
  const FilmInformationLoaded({
    required this.filmInformation,
    required this.filmImages,
  });

  FilmInformationLoaded copyWith({
    FilmEntity? filmInformation,
    FilmImagesEntity? filmImages,
  }) {
    return FilmInformationLoaded(
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

// final class FilmSavedSuccesful extends FilmInformationLoaded{
//    const FilmSavedSuccesful({
//     required super.filmInformation,
//     super.filmImages
//    });

//   @override
//   List<Object> get props => [super.props];
// }

// final class FilmSavedFailure extends FilmInformationLoaded{
//   final String message;

//   const FilmSavedFailure({
//     required super.filmInformation,
//     super.filmImages,
//     required this.message
//   });

//   @override
//   List<Object> get props => [super.props, message];
// }
