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
import 'package:movie_search_assistant_bloc/domain/usecases/watch_links_by_film_use_case.dart';

part 'film_information_event.dart';
part 'film_information_state.dart';

class FilmInformationBloc extends Bloc<FilmInformationEvent, FilmInformationState> {
  final GetFilmInformationUseCase getFilmInformationUseCase;
  final GetFilmImagesUseCase getFilmImagesUseCase;
  final AddFilmToCollectionUseCase addFilmToCollectionUseCase;
  final RemoveFilmFromCollectionUseCase removeFilmFromCollectionUseCase;
  final WatchLinksByFilmUseCase watchLinksByFilmUseCase;
  StreamSubscription<List<String>>? _collectionIdsSubscription;

  FilmInformationBloc({
    required this.getFilmInformationUseCase,
    required this.getFilmImagesUseCase,
    required this.addFilmToCollectionUseCase,
    required this.removeFilmFromCollectionUseCase,
    required this.watchLinksByFilmUseCase
    }) : super(FilmInitial()) {
    on<GetFilmInformation>(_getFilmInformation);
    on<AddFilmToCollection>(_addFilmToCollection);
    on<RemoveFilmFromCollection>(_removeFilmFromCollection);
    on<UpdateFilmLinks>(_updateFilmLinks);
  }

  Future<void> _getFilmInformation(GetFilmInformation event, Emitter emit) async{
    emit(FilmLoading());
    try{
      final (filmInformation, collectionIds) = await getFilmInformationUseCase.call(event.idFilm);
      final FilmImagesEntity? filmImages = await getFilmImagesUseCase.call(event.idFilm);
      if(filmInformation != null && collectionIds != null){
        emit(FilmLoaded(film: filmInformation, filmImages: filmImages, collectionIds: collectionIds));
        await _collectionIdsSubscription?.cancel();
        _collectionIdsSubscription = watchLinksByFilmUseCase(event.idFilm).listen((collectionIds) {
          add(UpdateFilmLinks(updatedCollectionIds: collectionIds));
        });
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
      await addFilmToCollectionUseCase(currentState.film, event.collectionId);
    } on LocalDataSourceException catch(e){
      emit(FilmActionFailure(film: currentState.film, filmImages: currentState.filmImages, collectionIds: currentState.collectionIds, message: e.message));
      emit(currentState);
    } catch (e) {
      emit(FilmActionFailure(
        film: currentState.film, 
        filmImages: currentState.filmImages, 
        collectionIds: currentState.collectionIds, 
        message: "Не удалось добавить фильм в коллекцию"
      ));
      emit(currentState);
    }
  }

  Future<void> _removeFilmFromCollection(RemoveFilmFromCollection event, Emitter emit) async {
    final currentState = state;
    if(currentState is! FilmLoaded) return;
    try {
      await removeFilmFromCollectionUseCase.call(currentState.film, event.collectionId);
    } on LocalDataSourceException catch(e){
      emit(FilmActionFailure(film: currentState.film, filmImages: currentState.filmImages, collectionIds: currentState.collectionIds, message: e.message));
      emit(currentState);
    } catch (e) {
      emit(FilmActionFailure(film: currentState.film, filmImages: currentState.filmImages, collectionIds: currentState.collectionIds, message: "Не удалось удалить фильм из коллекции"));
      emit(currentState);
    }
  }

  Future<void> _updateFilmLinks(UpdateFilmLinks event, Emitter emit) async {
    final currentState = state;
    if(currentState is! FilmLoaded) return;
    try{
      emit(FilmLoaded(film: currentState.film, filmImages: currentState.filmImages, collectionIds: event.updatedCollectionIds));
    } on LocalDataSourceException catch(e){
      emit(FilmActionFailure(film: currentState.film, filmImages: currentState.filmImages, collectionIds: currentState.collectionIds, message: e.message));
      emit(currentState);
    } catch(e){
      emit(FilmActionFailure(film: currentState.film, filmImages: currentState.filmImages, collectionIds: currentState.collectionIds, message: "Не удалось обновить информацию о текущих коллекциях"));
      emit(currentState);
    }
  }

  @override
  Future<void> close() {
    _collectionIdsSubscription?.cancel();
    return super.close();
  }
}
