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
import 'package:movie_search_assistant_bloc/domain/usecases/update_user_film_information_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/update_saved_film_from_server_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/watch_links_by_film_use_case.dart';

part 'film_information_event.dart';
part 'film_information_state.dart';

class FilmInformationBloc extends Bloc<FilmInformationEvent, FilmInformationState> {
  final GetFilmInformationUseCase getFilmInformationUseCase;
  final GetSavedFilmUseCase getSavedFilmUseCase;
  final GetFilmImagesUseCase getFilmImagesUseCase;
  final AddFilmToCollectionUseCase addFilmToCollectionUseCase;
  final UpdateSavedFilmFromServerUseCase updateSavedFilmFromServerUseCase;
  final UpdateUserFilmInformationUseCase updateUserFilmInformationUseCase;
  final RemoveFilmFromCollectionUseCase removeFilmFromCollectionUseCase;
  final WatchLinksByFilmUseCase watchLinksByFilmUseCase;
  StreamSubscription<List<String>>? _collectionIdsSubscription;

  FilmInformationBloc({
    required this.getFilmInformationUseCase,
    required this.getSavedFilmUseCase,
    required this.getFilmImagesUseCase,
    required this.addFilmToCollectionUseCase,
    required this.updateSavedFilmFromServerUseCase,
    required this.updateUserFilmInformationUseCase,
    required this.removeFilmFromCollectionUseCase,
    required this.watchLinksByFilmUseCase
    }) : super(FilmInitial()) {
    on<GetFilmInformation>(_getFilmInformation);
    on<AddFilmToCollection>(_addFilmToCollection);
    on<RemoveFilmFromCollection>(_removeFilmFromCollection);
    on<UpdateFilmLinks>(_updateFilmLinks);
    on<UpdateUserFilmInformation>(_updateUserFilmInformation);
    on<RefreshFilmInformation>(_refreshFilmInformation);
  }

  Future<void> _getFilmInformation(GetFilmInformation event, Emitter emit) async {
  emit(FilmLoading());

  try {
    FilmEntity? savedFilm;
    List<String>? collectionIds; 
    
    (savedFilm, collectionIds) = await getSavedFilmUseCase.call(event.idFilm);

    FilmImagesEntity? filmImages;

    try {
      filmImages = await getFilmImagesUseCase.call(event.idFilm);
    } catch (_) {
      filmImages = null;
    }

    FilmEntity? film = savedFilm;

    if (film == null) {
      final (remoteFilm, ids) = await getFilmInformationUseCase.call(event.idFilm);
      film = remoteFilm;
      collectionIds = collectionIds;
    }

    if (film == null) {
      emit(FilmFailure(message: "Не удалось получить информацию о фильме"));
      return;
    }

    emit(FilmLoaded(
      film: film,
      filmImages: filmImages,
      collectionIds: collectionIds,
      status: FilmStatus.success
    ));

    await _collectionIdsSubscription?.cancel();
    _collectionIdsSubscription =
        watchLinksByFilmUseCase(event.idFilm).listen(
      (collectionIds) {
        add(UpdateFilmLinks(updatedCollectionIds: collectionIds));
      },
    );
  } on RemoteDataSourceException catch (e) {
    emit(FilmFailure(message: e.message));
  } on LocalDataSourceException catch (e) {
    emit(FilmFailure(message: e.message));
  } catch (e) {
    emit(FilmFailure(message: "Неизвестная ошибка"));
  }
}

  Future<void> _addFilmToCollection(AddFilmToCollection event, Emitter emit) async {
    final currentState = state;
    if(currentState is! FilmLoaded) return;
    emit(currentState.copyWith(status: FilmStatus.loading));
    try {
      await addFilmToCollectionUseCase(currentState.film, currentState.filmImages, event.collectionId);
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
      emit(currentState.copyWith(film: currentState.film, filmImages: currentState.filmImages, collectionIds: event.updatedCollectionIds, status: FilmStatus.success));
    } on LocalDataSourceException catch(e){
      emit(FilmActionFailure(message: e.message));
      emit(currentState);
    } catch(e){
      emit(FilmActionFailure(message: "Не удалось обновить информацию о текущих коллекциях"));
      emit(currentState);
    }
  }

  Future<void> _updateUserFilmInformation(UpdateUserFilmInformation event, Emitter emit) async {
    final currentState = state;
    if(currentState is! FilmLoaded) return;
    try{
      final filmWithUpdatedUserInformation = await updateUserFilmInformationUseCase.call(currentState.film, event.userRating, event.userComment);
      emit(currentState.copyWith(
        film: filmWithUpdatedUserInformation, 
        filmImages: currentState.filmImages, 
        collectionIds: currentState.collectionIds, 
        status: FilmStatus.success
      ));
    } on LocalDataSourceException catch(e){
      emit(FilmActionFailure(message: e.message));
      emit(currentState);
    } catch(e){
      emit(FilmActionFailure(message: "Не удалось обновить пользовательскую информацию"));
      emit(currentState);
    }
  }

  Future<void> _refreshFilmInformation(RefreshFilmInformation event, Emitter emit) async {
    final currentState = state;
    try{
      final (newFilm, collectionIds) = await getFilmInformationUseCase(event.film.kinopoiskId!);
      final newFilmImages = await getFilmImagesUseCase.call(event.film.kinopoiskId!);
      
      if(currentState is FilmLoaded) {
        emit(FilmLoading());
        if(newFilm == null){
          emit(FilmActionFailure(message: "Не удалось обновить информацию о фильме"));
          emit(currentState);
          return;
        }
        final updatedFilm = await updateSavedFilmFromServerUseCase.call(event.film, newFilm, newFilmImages);
        emit(currentState.copyWith(film: updatedFilm, filmImages: newFilmImages, collectionIds: collectionIds, status: FilmStatus.success));
      }

      if(currentState is FilmFailure){
        if(newFilm != null) {
          emit(FilmLoaded(film: newFilm, filmImages: newFilmImages, collectionIds: collectionIds, status: FilmStatus.success));
        } else{
          emit(currentState);
        }
      }
    } on LocalDataSourceException {
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
