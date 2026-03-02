import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/collections/collections_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/film_information/film_information_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/film_information/widgets/film_information_widget.dart';

@RoutePage()
class FilmInformationScreen extends StatefulWidget {
  const FilmInformationScreen({
    super.key,
    @PathParam('filmId') required this.filmId,
  });

  final int filmId;

  @override
  State<FilmInformationScreen> createState() => _FilmInformationScreenState();
}

class _FilmInformationScreenState extends State<FilmInformationScreen> {
  final _filmInformationBloc = getIt<FilmInformationBloc>();
  final _collectionsBloc = getIt<CollectionsBloc>();

  @override
  void initState() {
    super.initState();
    _filmInformationBloc.add(DisplayFilmInformationEvent(idFilm: widget.filmId));
    _collectionsBloc.add(DisplayCollections());
  }

  void onAddFilmInCollectionPressed(String collectionId){
    _filmInformationBloc.add(AddFilmInCollectionEvent(collectionId: collectionId));
  }

  void onRemoveFilmFromCollectionPressed(String collectionId){
    _filmInformationBloc.add(RemoveFilmFromCollectionEvent(collectionId: collectionId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
            child: RefreshIndicator(
          onRefresh: () async {
            _filmInformationBloc.add(DisplayFilmInformationEvent(idFilm: widget.filmId));
            _collectionsBloc.add(DisplayCollections());
          },
          child: MultiBlocListener(
            listeners: [
              BlocListener<FilmInformationBloc, FilmInformationState>(
                bloc: _filmInformationBloc,
                listener: (context, state) {
                  if (state is FilmSavedSuccesful) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Фильм сохранён в коллекцию"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _collectionsBloc.add(DisplayCollections());
                  }
                  if (state is FilmRemovedSuccesful) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Фильм удалён из коллекции"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _collectionsBloc.add(DisplayCollections());
                  }
                  if (state is FilmSavedFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Фильм не удалось сохранить в коллекцию"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  if (state is FilmRemovedFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Фильм не удалось удалить из коллекции"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
              BlocListener<CollectionsBloc, CollectionsState>(
                  bloc: _collectionsBloc,
                  listener: (context, state) {
                    if (state is CollectionsLoadedFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Ошибка загрузки коллекций: ${state.exceptionType}"),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                ),
            ], 
            child: BlocBuilder<FilmInformationBloc, FilmInformationState>(
              bloc: _filmInformationBloc,
              buildWhen: (previous, current) {
                return current is FilmInformatinonLoading ||
                  current is FilmInformationLoadedFailure ||
                  current is FilmInformationLoadedSuccessful;
              },
              builder: (context, state) {
                if (state is FilmInformatinonLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (state is FilmInformationLoadedFailure) {
                  return Center(child: Text(state.exceptionType));
                }

                if (state is FilmInformationLoadedSuccessful) {
                  final film = state.filmInformation;
                  final images = state.filmImages;

                  return BlocBuilder<CollectionsBloc, CollectionsState>(
                    bloc: _collectionsBloc,
                    builder: (context, collectionsState) {
                      List<CollectionEntity> collections = [];
                      if (collectionsState is CollectionsLoadedSuccesful) {
                        collections = collectionsState.collections;
                      }
                      return FilmInformationWidget(
                        filmInformationBloc: _filmInformationBloc,
                        collectionsBloc: _collectionsBloc,
                        film: film,
                        images: images,
                        collections: collections,
                        onAddFilmInCollectionPressed: onAddFilmInCollectionPressed,
                        onRemoveFilmFromCollectionPressed: onRemoveFilmFromCollectionPressed,
                      );
                    },
                  );
                }
                return SizedBox();
              },
            )
          )
          ),
        ),
      );
  }
}
