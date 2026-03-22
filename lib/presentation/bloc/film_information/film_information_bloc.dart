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
import 'package:movie_search_assistant_bloc/domain/usecases/get_saved_film_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/remove_film_from_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/update_saved_film_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/watch_links_by_film_use_case.dart';

part 'film_information_event.dart';
part 'film_information_state.dart';

class FilmInformationBloc extends Bloc<FilmInformationEvent, FilmInformationState> {
  final GetFilmInformationUseCase getFilmInformationUseCase;
  final GetSavedFilmUseCase getSavedFilmUseCase;
  final GetFilmImagesUseCase getFilmImagesUseCase;
  final AddFilmToCollectionUseCase addFilmToCollectionUseCase;
  final UpdateSavedFilmUseCase updateSavedFilmUseCase;
  final RemoveFilmFromCollectionUseCase removeFilmFromCollectionUseCase;
  final WatchLinksByFilmUseCase watchLinksByFilmUseCase;
  StreamSubscription<List<String>>? _collectionIdsSubscription;

  FilmInformationBloc({
    required this.getFilmInformationUseCase,
    required this.getSavedFilmUseCase,
    required this.getFilmImagesUseCase,
    required this.addFilmToCollectionUseCase,
    required this.updateSavedFilmUseCase,
    required this.removeFilmFromCollectionUseCase,
    required this.watchLinksByFilmUseCase
    }) : super(FilmInitial()) {
    on<GetFilmInformation>(_getFilmInformation);
    on<AddFilmToCollection>(_addFilmToCollection);
    on<RemoveFilmFromCollection>(_removeFilmFromCollection);
    on<UpdateFilmLinks>(_updateFilmLinks);
    on<RefreshFilmInformation>(_refreshFilmInformation);
  }

  Future<void> _getFilmInformation(GetFilmInformation event, Emitter emit) async{
    emit(FilmLoading());
    try{
      final FilmEntity? savedFilmInformation;
      List<String> collectionIds;
      (savedFilmInformation, collectionIds) = await getSavedFilmUseCase.call(event.idFilm);
      // TODO: Реализовать загрузку изображений с локального хранилища сначала
      final FilmImagesEntity? filmImages = await getFilmImagesUseCase.call(event.idFilm);
      
      if(savedFilmInformation != null) {
        emit(FilmLoaded(film: savedFilmInformation, filmImages: filmImages, collectionIds: collectionIds));
      } else{
        final FilmEntity? filmInformation;
        (filmInformation, collectionIds) = await getFilmInformationUseCase.call(event.idFilm);
        if(filmInformation != null) {
          emit(FilmLoaded(film: filmInformation, filmImages: filmImages, collectionIds: collectionIds));
          await _collectionIdsSubscription?.cancel();
          _collectionIdsSubscription = watchLinksByFilmUseCase(event.idFilm).listen((collectionIds) {
            add(UpdateFilmLinks(updatedCollectionIds: collectionIds));
          });
        } else{
          emit(FilmFailure("Не удалось получить информацию о фильме"));
        }
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
      emit(FilmActionFailure(message: e.message));
      emit(currentState);
    } catch (e) {
      emit(FilmActionFailure(message: "Не удалось добавить фильм в коллекцию"));
      emit(currentState);
    }
  }

  Future<void> _removeFilmFromCollection(RemoveFilmFromCollection event, Emitter emit) async {
    final currentState = state;
    if(currentState is! FilmLoaded) return;
    try {
      await removeFilmFromCollectionUseCase.call(currentState.film, event.collectionId);
    } on LocalDataSourceException catch(e){
      emit(FilmActionFailure(message: e.message));
      emit(currentState);
    } catch (e) {
      emit(FilmActionFailure(message: "Не удалось удалить фильм из коллекции"));
      emit(currentState);
    }
  }

  Future<void> _updateFilmLinks(UpdateFilmLinks event, Emitter emit) async {
    final currentState = state;
    if(currentState is! FilmLoaded) return;
    try{
      emit(FilmLoaded(film: currentState.film, filmImages: currentState.filmImages, collectionIds: event.updatedCollectionIds));
    } on LocalDataSourceException catch(e){
      emit(FilmActionFailure(message: e.message));
      emit(currentState);
    } catch(e){
      emit(FilmActionFailure(message: "Не удалось обновить информацию о текущих коллекциях"));
      emit(currentState);
    }
  }

  Future<void> _refreshFilmInformation(RefreshFilmInformation event, Emitter emit) async {
    final currentState = state;
    try{
      final (newFilm, collectionIds) = await getFilmInformationUseCase(event.film.kinopoiskId!);
      final newFilmImages = await getFilmImagesUseCase.call(event.film.kinopoiskId!);
      
      if(currentState is FilmLoaded) {
        if(newFilm == null){
          emit(FilmActionFailure(message: "Не удалось обновить информацию о фильме"));
          emit(currentState);
          return;
        }
        if(newFilm.equalsWithoutUserData(event.film)){
          emit(currentState);
          return;
        }
        await updateSavedFilmUseCase.call(event.film, newFilm);
        emit(FilmLoaded(film: newFilm, filmImages: newFilmImages, collectionIds: collectionIds));
      }

      if(currentState is FilmFailure){
        if(newFilm != null) {
          emit(FilmLoaded(film: newFilm, filmImages: newFilmImages, collectionIds: collectionIds));
        } else{
          emit(currentState);
        }
      }
    } on LocalDataSourceException catch(e){
      emit(FilmActionFailure(message: "Не удалось обновить информацию о фильме"));
      emit(currentState);
    } catch(e){
      emit(FilmActionFailure(message: "Не удалось обновить информацию о фильме"));
      emit(currentState);
    }
  }

  @override
  Future<void> close() {
    _collectionIdsSubscription?.cancel();
    return super.close();
  }
}
