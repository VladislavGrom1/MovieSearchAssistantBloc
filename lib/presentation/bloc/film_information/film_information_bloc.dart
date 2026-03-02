
import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_images_entity.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/add_film_in_collection_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_film_images_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/get_film_information_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/remove_film_from_library_use_case.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/watch_saved_collections_use_case.dart';

part 'film_information_event.dart';
part 'film_information_state.dart';

class FilmInformationBloc extends Bloc<FilmInformationEvent, FilmInformationState> {
  final GetFilmInformationUseCase getFilmInformationUseCase;
  final GetFilmImagesUseCase getFilmImagesUseCase;
  final AddFilmInCollectionUseCase addFilmInUserCollectionUseCase;
  final RemoveFilmFromLibraryUseCase removeFilmFromUserCollectionUseCase;
  final WatchSavedCollectionsUseCase watchSavedCollectionsUseCase;
  late final StreamSubscription _onChangeSavedCollectionsSubscription;
  
  FilmInformationBloc({
    required this.getFilmInformationUseCase,
    required this.getFilmImagesUseCase,
    required this.addFilmInUserCollectionUseCase,
    required this.removeFilmFromUserCollectionUseCase,
    required this.watchSavedCollectionsUseCase
    }) : super(FilmInformationInitial()) {
    on<DisplayFilmInformationEvent>(_displayFilmInformation);
    on<AddFilmInCollectionEvent>(_addFilmInCollection);
    on<RemoveFilmFromCollectionEvent>(_removeFilmFromCollection);
    on<OnSavedCollectionsUpdated>(_onSavedCollectionsUpdated);

    _onChangeSavedCollectionsSubscription = watchSavedCollectionsUseCase().listen((collections) {
      add(OnSavedCollectionsUpdated(collections: collections));
    });
  }

  Future<void> _displayFilmInformation(DisplayFilmInformationEvent event, Emitter emit) async{
    emit(FilmInformatinonLoading());
    try{
      final FilmEntity? filmInformation = await getFilmInformationUseCase.call(event.idFilm);
      final FilmImagesEntity? filmImages = await getFilmImagesUseCase.call(event.idFilm);
      if(filmInformation != null){
        emit(FilmInformationLoadedSuccessful(
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

  Future<void> _addFilmInCollection(AddFilmInCollectionEvent event, Emitter emit) async {
    final currentState = state as FilmInformationLoadedSuccessful;
    try{
      final currentIds = currentState.filmInformation.collectionIds ?? [];
      final updatedCollectionIds = [...currentIds, event.collectionId];
      
      final filmInformationWithUpdatedIds = currentState.filmInformation.copyWith(
        updatedCollectionIds: updatedCollectionIds,
      );

      emit(currentState.copyWith(
        filmInformation: filmInformationWithUpdatedIds
      ));

      await addFilmInUserCollectionUseCase.call(filmInformationWithUpdatedIds);
      emit(FilmSavedSuccesful());

      emit(FilmInformationLoadedSuccessful(
        filmInformation: filmInformationWithUpdatedIds,
        filmImages: currentState.filmImages,
      ));
    } on LocalDataSourceException catch(e){
      emit(FilmSavedFailure(message: e.message));
      emit(FilmInformationLoadedSuccessful(
        filmInformation: currentState.filmInformation,
        filmImages: currentState.filmImages,
      ));
    } catch(e){
      emit(FilmSavedFailure(message: e.toString()));
      emit(FilmInformationLoadedSuccessful(
        filmInformation: currentState.filmInformation,
        filmImages: currentState.filmImages,
      ));
    }
  }

  Future<void> _removeFilmFromCollection(RemoveFilmFromCollectionEvent event, Emitter emit) async{
    final currentState = state as FilmInformationLoadedSuccessful;
    try{
      final currentIds = currentState.filmInformation.collectionIds ?? [];
      final updatedCollectionIds = currentIds.where((id) => id != event.collectionId).toList();

      final filmInformationWithUpdatedIds = currentState.filmInformation.copyWith(
        updatedCollectionIds: updatedCollectionIds,
      );

      emit(currentState.copyWith(
        filmInformation: filmInformationWithUpdatedIds
      ));

      if(updatedCollectionIds.isNotEmpty){
        await addFilmInUserCollectionUseCase.call(filmInformationWithUpdatedIds);
      } else{
        await removeFilmFromUserCollectionUseCase.call(filmInformationWithUpdatedIds);
      }
      
      emit(FilmRemovedSuccesful());

      emit(FilmInformationLoadedSuccessful(
        filmInformation: filmInformationWithUpdatedIds,
        filmImages: currentState.filmImages,
      ));
    } on LocalDataSourceException catch(e){
      emit(FilmRemovedFailure(message: e.message));
      emit(FilmInformationLoadedSuccessful(
        filmInformation: currentState.filmInformation,
        filmImages: currentState.filmImages,
      ));
    } catch(e){
      emit(FilmRemovedFailure(message: e.toString()));
      emit(FilmInformationLoadedSuccessful(
        filmInformation: currentState.filmInformation,
        filmImages: currentState.filmImages,
      ));
    }
  }

  Future<void> _onSavedCollectionsUpdated(OnSavedCollectionsUpdated event, Emitter emit) async {
    final currentState = state;
    if(currentState is FilmInformationLoadedSuccessful){
      final FilmEntity? filmInformation = await getFilmInformationUseCase.call(currentState.filmInformation.kinopoiskId!);
      emit(currentState.copyWith(
        filmInformation: filmInformation,
        filmImages: currentState.filmImages
      ));
    }
  }

  @override
  Future<void> close() {
    _onChangeSavedCollectionsSubscription.cancel();
    return super.close();
  }
}
