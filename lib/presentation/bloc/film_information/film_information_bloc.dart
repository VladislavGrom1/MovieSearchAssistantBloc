import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_images_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/add_film_in_user_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_film_images_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_film_information_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/remove_film_from_user_collection_use_case.dart';

part 'film_information_event.dart';
part 'film_information_state.dart';

class FilmInformationBloc extends Bloc<FilmInformationEvent, FilmInformationState> {
  final GetFilmInformationUseCase getFilmInformationUseCase;
  final GetFilmImagesUseCase getFilmImagesUseCase;
  final AddFilmInUserCollectionUseCase addFilmInUserCollectionUseCase;
  final RemoveFilmFromUserCollectionUseCase removeFilmFromUserCollectionUseCase;
  FilmInformationBloc({
    required this.getFilmInformationUseCase,
    required this.getFilmImagesUseCase,
    required this.addFilmInUserCollectionUseCase,
    required this.removeFilmFromUserCollectionUseCase
    }) : super(FilmInformationInitial()) {
    on<DisplayFilmInformationEvent>(_displayFilmInformation);
    on<SaveFilmEvent>(_saveFilm);
    on<RemoveFilmEvent>(_removeFilm);
  }

  Future<void> _displayFilmInformation(DisplayFilmInformationEvent event, Emitter emit) async{
    emit(FilmInformatinonLoading());
    try{
      final FilmEntity? filmInformation = await getFilmInformationUseCase.call(event.idFilm);
      final FilmImagesEntity? filmImages = await getFilmImagesUseCase.call(event.idFilm);
      if(filmInformation != null){
        emit(FilmInformationLoaded(
          filmInformation: filmInformation,
          filmImages: filmImages
        ));
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

  Future<void> _saveFilm(SaveFilmEvent event, Emitter emit) async{
    final currentState = state as FilmInformationLoaded;
    try{
      await addFilmInUserCollectionUseCase.call(event.film);
      emit(currentState.copyWith(
        filmInformation: currentState.filmInformation.copyWith(isSaved: true)
      ));
    // TODO: Доработать смену состояний при успешном и не успешном сохранении фильма
    } on LocalDataSourceException catch(e){
      emit(FilmInformationLoadedFailure(exceptionType: e.toString()));
    } catch(e){
      emit(FilmInformationLoadedFailure(exceptionType: "Неизвестная ошибка"));
    }
  }

  Future<void> _removeFilm(RemoveFilmEvent event, Emitter emit) async{
    final currentState = state as FilmInformationLoaded;
    try{
      await removeFilmFromUserCollectionUseCase.call(event.film);
      emit(currentState.copyWith(
        filmInformation: currentState.filmInformation.copyWith(isSaved: false)
      ));
    // TODO: Доработать смену состояний при успешном и не успешном удалении фильма
    } on LocalDataSourceException catch(e){
      emit(FilmInformationLoadedFailure(exceptionType: e.toString()));
    } catch(e){
      emit(FilmInformationLoadedFailure(exceptionType: "Неизвестная ошибка"));
    }
  }
}
