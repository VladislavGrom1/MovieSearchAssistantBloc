import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_information_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/display_film_information_use_case.dart';

part 'film_information_event.dart';
part 'film_information_state.dart';

class FilmInformationBloc extends Bloc<FilmInformationEvent, FilmInformationState> {
  final DisplayFilmInformationUseCase displayFilmInformationUseCase;
  FilmInformationBloc({required this.displayFilmInformationUseCase}) : super(FilmInformationInitial()) {
    on<DisplayFilmInformationEvent>(_displayFilmInformation);
  }

  Future<void> _displayFilmInformation(DisplayFilmInformationEvent event, Emitter emit) async{
    emit(FilmInformatinonLoading());
    try{
      final FilmInformationEntity? filmInformation = await displayFilmInformationUseCase.call(event.idFilm);
      if(filmInformation != null){
        emit(FilmInformationLoadedSuccessful(filmInformation: filmInformation));
      } else{
        emit(FilmInformationLoadedFailure(exceptionType: "Не удалось загрузить информацию о фильме"));
      }
    } on RemoteDataSourceException catch(e){
      emit(FilmInformationLoadedFailure(exceptionType: e.exceptionType.name, statusCode: e.statusCode));
    } on LocalDataSourceException catch(e){
      emit(FilmInformationLoadedFailure(exceptionType: e.message));
    } catch(e){
      emit(FilmInformationLoadedFailure(exceptionType: e.toString()));
    }
  }
}
