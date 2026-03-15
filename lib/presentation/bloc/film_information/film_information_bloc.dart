
import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_images_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/add_film_to_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_film_images_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_film_information_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/remove_film_from_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/watch_film_by_id_use_case.dart';

part 'film_information_event.dart';
part 'film_information_state.dart';

class FilmInformationBloc extends Bloc<FilmInformationEvent, FilmInformationState> {
  final GetFilmInformationUseCase getFilmInformationUseCase;
  final GetFilmImagesUseCase getFilmImagesUseCase;
  final AddFilmToCollectionUseCase addFilmToCollectionUseCase;
  final RemoveFilmFromCollectionUseCase removeFilmFromCollectionUseCase;
  final WatchFilmByIdUseCase watchFilmByIdUseCase;
  StreamSubscription<FilmEntity?>? _filmSubscription;
  
  FilmInformationBloc({
    required this.getFilmInformationUseCase,
    required this.getFilmImagesUseCase,
    required this.addFilmToCollectionUseCase,
    required this.removeFilmFromCollectionUseCase,
    required this.watchFilmByIdUseCase
    }) : super(FilmInitial()) {
    on<GetFilmInformation>(_getFilmInformation);
    on<AddFilmToCollection>(_addFilmToCollection);
    on<RemoveFilmFromCollection>(_removeFilmFromCollection);
    on<UpdateFilmInformation>(_updateFilmInformation);
  }

  Future<void> _getFilmInformation(GetFilmInformation event, Emitter emit) async{
    emit(FilmLoading());
    try{
      final FilmEntity? filmInformation = await getFilmInformationUseCase.call(event.idFilm);
      final FilmImagesEntity? filmImages = await getFilmImagesUseCase.call(event.idFilm);
      if(filmInformation != null){
        emit(FilmLoaded(film: filmInformation, filmImages: filmImages));
        await _filmSubscription?.cancel();
        _filmSubscription = watchFilmByIdUseCase(event.idFilm).listen((film) {add(UpdateFilmInformation(updatedFilm: film));});
      } else{
        emit(FilmFailure("Не удалось получить информацию о фильме"));
      }
    } on RemoteDataSourceException catch(e){
      emit(FilmFailure(e.exceptionType.name));
    } on LocalDataSourceException catch(e){
      emit(FilmFailure(e.message));
    } catch(e){
      emit(FilmFailure(e.toString()));
    }
  }

  Future<void> _addFilmToCollection(AddFilmToCollection event, Emitter emit) async {
    final currentState = state;
    if(currentState is! FilmLoaded) return;
    try {
      final updatedFilm = await addFilmToCollectionUseCase(currentState.film, event.collectionId);
      emit(FilmActionSuccess(film: updatedFilm, filmImages: currentState.filmImages, message: "Фильм успешно добавлен в коллекцию"));
    } on LocalDataSourceException catch(e){
      emit(FilmActionFailure(film: currentState.film, filmImages: currentState.filmImages, message: e.message));
      emit(currentState);
    } catch (e) {
      emit(FilmActionFailure(film: currentState.film, filmImages: currentState.filmImages, message: "Не удалось добавить фильм в коллекцию"));
      emit(currentState);
    }
  }

  Future<void> _removeFilmFromCollection(RemoveFilmFromCollection event, Emitter emit) async {
    final currentState = state;
    if(currentState is! FilmLoaded) return;
    try {
      final updatedFilm = await removeFilmFromCollectionUseCase.call(currentState.film, event.collectionId);
      emit(FilmActionSuccess(film: updatedFilm, filmImages: currentState.filmImages, message: "Фильм успешно удалён из коллекции"));
    } on LocalDataSourceException catch(e){
      emit(FilmActionFailure(film: currentState.film, filmImages: currentState.filmImages, message: e.message));
      emit(currentState);
    } catch (e) {
      emit(FilmActionFailure(film: currentState.film, filmImages: currentState.filmImages, message: "Не удалось удалить фильм из коллекции"));
      emit(currentState);
    }
  }

  Future<void> _updateFilmInformation(UpdateFilmInformation event, Emitter emit) async {
    final currentState = state;
    if(currentState is! FilmLoaded) return;
    try{
      if(event.updatedFilm == null) {
        final updatedFilm = currentState.film.copyWith(updatedCollectionIds: []);
        emit(FilmLoaded(film: updatedFilm, filmImages: currentState.filmImages));
        return;
      }
      emit(FilmLoaded(film: event.updatedFilm!, filmImages: currentState.filmImages));
    } on LocalDataSourceException catch(e){
      emit(FilmActionFailure(film: currentState.film, filmImages: currentState.filmImages, message: e.message));
      emit(currentState);
    } catch(e){
      emit(FilmActionFailure(film: currentState.film, filmImages: currentState.filmImages, message: "Не удалось обновить информацию о фильме"));
      emit(currentState);
    }
  }

  @override
  Future<void> close() {
    _filmSubscription?.cancel();
    return super.close();
  }
}
