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
import 'package:movie_search_assistant_bloc/domain/usecases/update_rating_film_information_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/update_saved_film_from_server_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/watch_links_by_film_use_case.dart';

part 'film_information_event.dart';
part 'film_information_state.dart';

class FilmInformationBloc extends Bloc<FilmInformationEvent, FilmInformationState> {
  final GetFilmInformationUseCase getFilmInformationUseCase;
  final GetSavedFilmUseCase getSavedFilmUseCase;
  final GetFilmImagesUseCase getFilmImagesUseCase;
  final AddFilmToCollectionUseCase addFilmToCollectionUseCase;
  final UpdateSavedFilmFromServerUseCase updateSavedFilmUseCase;
  final UpdateRatingFilmInformationUseCase updateRatingFilmInformationUseCase;
  final RemoveFilmFromCollectionUseCase removeFilmFromCollectionUseCase;
  final WatchLinksByFilmUseCase watchLinksByFilmUseCase;
  StreamSubscription<List<String>>? _collectionIdsSubscription;

  FilmInformationBloc({
    required this.getFilmInformationUseCase,
    required this.getSavedFilmUseCase,
    required this.getFilmImagesUseCase,
    required this.addFilmToCollectionUseCase,
    required this.updateSavedFilmUseCase,
    required this.updateRatingFilmInformationUseCase,
    required this.removeFilmFromCollectionUseCase,
    required this.watchLinksByFilmUseCase
    }) : super(FilmInitial()) {
    on<GetFilmInformation>(_getFilmInformation);
    on<AddFilmToCollection>(_addFilmToCollection);
    on<RemoveFilmFromCollection>(_removeFilmFromCollection);
    on<UpdateFilmLinks>(_updateFilmLinks);
    on<UpdateFilmUserRating>(_updateFilmUserRating);
    on<RefreshFilmInformation>(_refreshFilmInformation);
  }

  Future<void> _getFilmInformation(GetFilmInformation event, Emitter emit) async{
    emit(FilmLoading());
    try{
      
      final FilmEntity? savedFilmInformation;
      List<String> collectionIds;

      final results = await Future.wait([
        getSavedFilmUseCase.call(event.idFilm),
        getFilmImagesUseCase.call(event.idFilm),
      ]);

      (savedFilmInformation, collectionIds) = results[0] as (FilmEntity?, List<String>);
      final filmImages = results[1] as FilmImagesEntity?;

      FilmEntity? film;

      if (savedFilmInformation != null) {
        film = savedFilmInformation;
      } else {
        final (filmInformation, ids) = await getFilmInformationUseCase.call(event.idFilm);
        film = filmInformation;
        collectionIds = ids;
      }

      if (film == null) {
        emit(FilmFailure("Не удалось получить информацию о фильме"));
        return;
      }

      emit(FilmLoaded(
        film: film,
        filmImages: filmImages,
        collectionIds: collectionIds,
      ));

      await _collectionIdsSubscription?.cancel();
      _collectionIdsSubscription = watchLinksByFilmUseCase(event.idFilm).listen(
        (collectionIds) {
          add(UpdateFilmLinks(updatedCollectionIds: collectionIds));
        },
      );

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

  Future<void> _updateFilmUserRating(UpdateFilmUserRating event, Emitter emit) async {
    final currentState = state;
    if(currentState is! FilmLoaded) return;
    try{
      final filmWithUpdatedRating = await updateRatingFilmInformationUseCase.call(currentState.film, event.userRating);
      emit(FilmLoaded(film: filmWithUpdatedRating, filmImages: currentState.filmImages, collectionIds: currentState.collectionIds));
    } on LocalDataSourceException catch(e){
      emit(FilmActionFailure(message: e.message));
      emit(currentState);
    } catch(e){
      emit(FilmActionFailure(message: "Не удалось обновить пользовательский рейтинг"));
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
