import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/collections/collections_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/film_information/film_information_bloc.dart';

@RoutePage()
class FilmInformationScreen extends StatelessWidget {
  const FilmInformationScreen({
    super.key,
    @PathParam('filmId') required this.filmId,
  });

  final int filmId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(
        create: (_) => getIt<FilmInformationBloc>()..add(GetFilmInformation(idFilm: filmId)),
      ),
      BlocProvider(
        create: (_) => getIt<CollectionsBloc>()..add(GetCollections()),
      )
    ], child: const _FilmInformationView());
  }
}

class _FilmInformationView extends StatelessWidget {
  const _FilmInformationView();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<FilmInformationBloc, FilmInformationState>(
            listener: _filmInformationBlocListener
        ),
        BlocListener<CollectionsBloc, CollectionsState>(
            listener: _collectionsBlocListener
        )
      ],
      child: Scaffold(
        appBar: AppBar(backgroundColor: Colors.black),
        backgroundColor: Colors.white,
        body: SafeArea(child:
            BlocBuilder<FilmInformationBloc, FilmInformationState>(
                builder: (context, state) {
          if (state is FilmLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FilmFailure) {
            return Center(child: Text(state.message));
          }
          if (state is FilmLoaded) {
            return _FilmInformationContent();
          }
          return const SizedBox();
        })),
      ),
    );
  }

  void _filmInformationBlocListener(
      BuildContext context, FilmInformationState state) {
    if (state is FilmActionSuccess) {
      _showSnackBar(context, state.message, Colors.green);
    }
    if (state is FilmActionFailure) {
      _showSnackBar(context, state.message, Colors.red);
    }
  }

  void _collectionsBlocListener(BuildContext context, CollectionsState state) {
    if (state is CollectionRemovedSuccess) {
      _showSnackBar(context, state.message, Colors.green);
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class _FilmInformationContent extends StatelessWidget {
  const _FilmInformationContent();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<FilmInformationBloc>().state;
    final film = (state as FilmLoaded).film;
    final filmImages = state.filmImages;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w),
            child: Column(
              children: [
                TextButton(
                  onPressed: () => _openCollectionSheet(context),
                  child: const Text(
                    "Добавить в коллекцию",
                    style: TextStyle(color: Colors.purple),
                  ),
                ),
                SizedBox(height: 16),
                Text(film.nameRu ?? film.nameOriginal ?? "Без названия"),
                SizedBox(height: 8),
                Text(film.collectionIds.toString()),
                SizedBox(height: 10.h),
                if (film.nameOriginal != null) ...[
                  Text(film.nameOriginal!),
                  SizedBox(height: 10.h),
                ],
                Text(
                  film.serial!
                      ? "${film.startYear} - ${film.endYear ?? "настоящее время"}"
                      : "${film.year}",
                ),
                SizedBox(height: 10.h),
                Text(_getCountriesString(film.countries)),
                SizedBox(height: 10.h),
                Text(_getGenresString(film.genres)),
                SizedBox(height: 10.h),
                Text(film.description.toString()),
                SizedBox(height: 10.h),
                Text(_getSloganString(film.slogan)),
                SizedBox(height: 10.h),
                _filmRatingAndReviewCount(
                  "Рейтинг KP",
                  film.ratingKinopoisk,
                  film.ratingKinopoiskVoteCount,
                ),
                SizedBox(height: 10.h),
                _filmRatingAndReviewCount(
                  "Рейтинг IMDB",
                  film.ratingImbd,
                  film.ratingImdbVoteCount,
                ),
                SizedBox(height: 10.h),
                Text(filmImages?.imageUrls.toString() ?? ""),
              ],
            ),
          ),
        )
      ],
    );
  }

  void _openCollectionSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (bottomSheetContext) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: context.read<FilmInformationBloc>()),
                BlocProvider.value(value: context.read<CollectionsBloc>()),
              ],
              child: const _CollectionPickerSheet(),
            ));
  }

  String _getGenresString(List<String>? genres) {
    return genres?.join(', ') ?? "Данные отсутствуют";
  }

  String _getCountriesString(List<String>? countries) {
    return countries?.join(', ') ?? "Данные отсутствуют";
  }

  String _getSloganString(String? slogan) {
    return slogan ?? "Слоган отсутствует";
  }

  Widget _filmRatingAndReviewCount(
      String resourceName, num? rating, int? voteCount) {
    final ratingText = rating == null ? "-" : rating.toString();
    final voteCountText =
        "${voteCount == null ? 0 : voteCount.toString()} оценок";
    return Text("$resourceName, $ratingText, $voteCountText");
  }

  List<Widget> _nameOriginal(String? nameOriginal) {
    if (nameOriginal != null) {
      return [Text(nameOriginal), SizedBox(height: 10.h)];
    }
    return [SizedBox()];
  }
}

class _CollectionPickerSheet extends StatelessWidget {
  const _CollectionPickerSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) {
          return BlocBuilder<FilmInformationBloc, FilmInformationState>(
            buildWhen: (previous, current) => current is FilmLoaded,
            builder: (context, filmState) {
              final film = (filmState as FilmLoaded).film;

              return BlocBuilder<CollectionsBloc, CollectionsState>(
                builder: (context, collectionsState) {
                if (collectionsState is CollectionsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (collectionsState is! CollectionsLoaded) {
                  return const Center(child: Text("Нет коллекций"));
                }

                final collections = collectionsState.collections;
                return _CollectionsList(
                    scrollController: scrollController,
                    film: film,
                    collections: collections);
              });
            },
          );
        });
  }
}

class _CollectionsList extends StatelessWidget {
  final ScrollController scrollController;
  final FilmEntity film;
  final List<CollectionEntity> collections;

  const _CollectionsList({
    required this.scrollController,
    required this.film,
    required this.collections});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        controller: scrollController,
        itemCount: collections.length,
        itemBuilder: (context, index) {
          final collection = collections[index];
          final isInCollection = film.collectionIds?.contains(collection.id) ?? false;

          return ListTile(
            title: Text(collection.name ?? "Без названия"),
            trailing: Icon(
              isInCollection ? Icons.check_box : Icons.add,
              color: isInCollection ? Colors.green : Colors.grey,
            ),
            onTap: () {
              if (isInCollection) {
                context.read<FilmInformationBloc>().add(RemoveFilmFromCollection(collectionId: collection.id!));
              } else {
                context.read<FilmInformationBloc>().add(AddFilmToCollection(collectionId: collection.id!));
              }
            },
          );
        });
  }
}
