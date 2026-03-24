import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/app/util/cache_manager/film_image_cache_manager.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/collection_films/collection_films_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/collection_films/selection_films_cubit/selection_films_cubit.dart';

@RoutePage()
class CollectionFilmsScreen extends StatelessWidget {
  const CollectionFilmsScreen(
      {super.key,
      @PathParam('collectionId') required this.collectionId,
      @PathParam('collectionName') required this.collectionName});

  final String collectionId;
  final String collectionName;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(create: (_) => getIt<CollectionFilmsBloc>()..add(GetSavedFilms(collectionId: collectionId))),
      BlocProvider(create: (_) => getIt<SelectionFilmsCubit>()),
    ], child: _CollectionFilmsView(collectionName: collectionName));
  }
}

// TODO: если выбрано 2 фильма и удалить 1 фильм из коллекции, то в multiselect будет отображаться "выбрано 2 фильма" а не "1"

class _CollectionFilmsView extends StatelessWidget {
  const _CollectionFilmsView({required this.collectionName});

  final String collectionName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: BlocBuilder<SelectionFilmsCubit, SelectionFilmsState>(
          builder: (context, state) {
            if (!state.isSelectionMode) {
              return Text(collectionName, style: TextStyle(color: Colors.white));
            } 
            return Text("Выбрано: ${state.selectedFilmIds.length}", style: TextStyle(color: Colors.white));
          },
        ),
        actions: [
          BlocBuilder<SelectionFilmsCubit, SelectionFilmsState>(
            builder: (context, selectionFilmsState) {
              if (!selectionFilmsState.isSelectionMode) {
                return SizedBox();
              } 
              final collectionFilmsState = context.read<CollectionFilmsBloc>().state;
              return Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.select_all),
                    onPressed: () {
                      if (collectionFilmsState is CollectionFilmsLoaded) {
                        if (selectionFilmsState.selectedFilmIds.length ==
                            collectionFilmsState.savedFilms.length) {
                          context.read<SelectionFilmsCubit>().clear();
                        } else {
                          context.read<SelectionFilmsCubit>().selectAll(collectionFilmsState.savedFilms.map((e) => e.kinopoiskId!).toList());
                        }
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      if (collectionFilmsState is CollectionFilmsLoaded) {
                        final selected = selectionFilmsState.selectedFilmIds;
                        for (final film in collectionFilmsState.savedFilms) {
                          if (selected.contains(film.kinopoiskId)) {
                            context.read<CollectionFilmsBloc>().add(RemoveFilm(film: film, collectionId: collectionFilmsState.collectionId),
                            );
                          }
                        }
                        context.read<SelectionFilmsCubit>().clear();
                      }
                    },
                  )
                ],
              );
            },
          )
        ],
      ),
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.only(left: 20.w, right: 20.h),
        child: BlocBuilder<CollectionFilmsBloc, CollectionFilmsState>(
          builder: (context, state) {
            if (state is CollectionFilmsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CollectionFilmsFailure) {
              return Center(child: Text(state.message));
            }

            if (state is CollectionFilmsLoaded) {
              return _CollectionFilmsList(
                savedFilms: state.savedFilms,
                collectionId: state.collectionId,
              );
            }

            return SizedBox();
          },
        ),
      )),
    );
  }
}

class _CollectionFilmsList extends StatelessWidget {
  final List<FilmEntity> savedFilms;
  final String collectionId;

  const _CollectionFilmsList({required this.savedFilms, required this.collectionId});

  @override
  Widget build(BuildContext context) {
    final collectionFilmsBloc = context.read<CollectionFilmsBloc>();

    if (savedFilms.isEmpty) {
      return Center(child: Text("Коллекция пуста", style: TextStyle(color: Colors.black)));
    }

    return ListView.separated(
        addAutomaticKeepAlives: false,
        addSemanticIndexes: false,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final savedFilm = savedFilms[index];
          return _FilmCard(
              savedFilm: savedFilm,
              collectionId: collectionId,
              collectionFilmsBloc: collectionFilmsBloc,
          );
        },
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemCount: savedFilms.length);
  }
}

class _FilmCard extends StatelessWidget {
  final FilmEntity savedFilm;
  final String collectionId;
  final CollectionFilmsBloc collectionFilmsBloc;

  const _FilmCard(
      {required this.savedFilm,
      required this.collectionId,
      required this.collectionFilmsBloc});

  void onRemove() {
    collectionFilmsBloc.add(RemoveFilm(film: savedFilm, collectionId: collectionId));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final selectionFilmsCubit = context.read<SelectionFilmsCubit>();
        final selectionFilmsState = selectionFilmsCubit.state;

        if (selectionFilmsState.isSelectionMode) {
          selectionFilmsCubit.toggle(savedFilm.kinopoiskId!);
        } else {
          context.router.push(FilmInformationRoute(
              filmId: savedFilm.kinopoiskId!,
              filmName: savedFilm.nameRu ?? savedFilm.nameOriginal.toString()));
        }
      },
      onLongPress: () {
        context.read<SelectionFilmsCubit>().enterSelection(savedFilm.kinopoiskId!);
      },
      child: Card(
        color: Colors.grey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CachedImageWidget(urlImage: savedFilm.posterUrlPreview),
            SizedBox(width: 16.w),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 5.h),
                Text(
                  savedFilm.nameRu == null
                      ? savedFilm.nameOriginal.toString()
                      : savedFilm.nameRu.toString(),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                SizedBox(height: 10.h),
                Text(
                  savedFilm.nameOriginal == null
                      ? "-"
                      : savedFilm.nameOriginal.toString(),
                ),
                SizedBox(height: 10.h),
                Text(savedFilm.countries!.isEmpty
                    ? "${savedFilm.year}"
                    : "${savedFilm.countries.toString()}, ${savedFilm.year}"),
                SizedBox(height: 10.h)
              ],
            )),
            BlocBuilder<SelectionFilmsCubit, SelectionFilmsState>(
              builder: (context, state) {
                if (!state.isSelectionMode) {
                  return PopupMenuButton(
                      icon: Icon(Icons.more_vert, color: Colors.purple),
                      onSelected: (value) {
                        if (value == "removeFilm") onRemove();
                      },
                      itemBuilder: (_) => const [
                            PopupMenuItem(
                                value: 'removeFilm',
                                child: Text("Удалить фильм")),
                          ]);
                }
                final isSelected = state.selectedFilmIds.contains(savedFilm.kinopoiskId!);
                return Checkbox(
                    value: isSelected,
                    onChanged: (_) {
                      context.read<SelectionFilmsCubit>().toggle(savedFilm.kinopoiskId!);
                    });
              },
            )
          ],
        ),
      ),
    );
  }
}

class _CachedImageWidget extends StatelessWidget {
  final String? urlImage;

  const _CachedImageWidget({required this.urlImage});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.w),
      child: RepaintBoundary(
        child: CachedNetworkImage(
          imageUrl: urlImage ?? '',
          cacheManager: FilmImageCacheManager.instance,
          memCacheHeight: 140,
          memCacheWidth: 100,
          fit: BoxFit.fill,
          height: 140.h,
          width: 100.w,
          placeholder: (context, url) => Container(color: Colors.grey[200]),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }
}
