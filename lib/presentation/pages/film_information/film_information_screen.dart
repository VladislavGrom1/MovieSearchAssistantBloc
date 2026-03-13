import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/collections/collections_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/film_information/film_information_bloc.dart';

//TODO: При удалении коллекции полностью, у фильма не обновляются collectionTags

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
          listener: (context, state) {
            if (state is FilmActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            }
            if (state is FilmActionFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        ),
        BlocListener<CollectionsBloc, CollectionsState>(
          listener: (context, state) {
            if(state is CollectionRemovedSuccess){
              final filmState = context.read<FilmInformationBloc>().state;
              if(filmState is FilmLoaded){
                final filmId = filmState.film.kinopoiskId!;
                context.read<FilmInformationBloc>().add(GetFilmInformation(idFilm: filmId));
              }
            }
          },
        )
      ],
      child: Scaffold(
        appBar: AppBar(backgroundColor: Colors.black),
        backgroundColor: Colors.white,
        body: SafeArea(
            child: BlocBuilder<FilmInformationBloc, FilmInformationState>(
                builder: (context, state) {
                  if (state is FilmLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
      
                  if (state is FilmFailure) {
                    return Center(child: Text(state.message));
                  }
      
                  if (state is FilmLoaded) {
                    return FilmInformationContent();
                  }
      
                  return const SizedBox();
                })),
      ),
    );
  }
}

class FilmInformationContent extends StatelessWidget {
  const FilmInformationContent({super.key});

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
    final filmBloc = context.read<FilmInformationBloc>();
    final collectionsBloc = context.read<CollectionsBloc>();

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider<FilmInformationBloc>.value(value: filmBloc),
            BlocProvider<CollectionsBloc>.value(value: collectionsBloc),
          ],
        child: const CollectionPickerSheet(),
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

class CollectionPickerSheet extends StatelessWidget {
  const CollectionPickerSheet({super.key});

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
              });
            },
          );
        });
  }
}
