import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/app/util/cache_manager/film_image_cache_manager.dart';
import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_images_entity.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/collections/collections_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/film_information/film_information_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/search_films/cubit/watch_film_collection_links_cubit.dart';

@RoutePage()
class FilmInformationScreen extends StatelessWidget {
  const FilmInformationScreen({
    super.key,
    @PathParam('filmId') required this.filmId,
    @PathParam('filmName') required this.filmName
  });

  final int filmId;
  final String filmName;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<FilmInformationBloc>()..add(GetFilmInformation(idFilm: filmId)),
        ),
        BlocProvider(
          create: (_) => getIt<CollectionsBloc>()..add(GetCollections()),
        ),
        BlocProvider(
          create: (_) => getIt<WatchFilmCollectionLinksCubit>()
        )
      ], 
      child: _FilmInformationView(
        filmId: filmId,
        filmName: filmName
      )
    );
  }
}

class _FilmInformationView extends StatelessWidget {
  const _FilmInformationView({
    required this.filmId,
    required this.filmName
  });

  final int filmId;
  final String filmName;
  
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
        appBar: AppBar(
          title: Text(filmName, style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child:
            RefreshIndicator(
              onRefresh: () async {
                final filmInformationBloc = context.read<FilmInformationBloc>();
                final state = filmInformationBloc.state;
                if(state is FilmLoaded){
                  final currentFilm = state.film;
                  filmInformationBloc.add(RefreshFilmInformation(film: currentFilm));
                }

                if(state is FilmFailure){
                  filmInformationBloc.add(GetFilmInformation(idFilm: filmId));
                }
              },
              child: BlocBuilder<FilmInformationBloc, FilmInformationState>(
                  builder: (context, state) {
                        if (state is FilmLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (state is FilmFailure) {
                          return Center(child: Text(state.message));
                        }
                        if (state is FilmLoaded) {
                          return _FilmInformationContent(
                            film: state.film,
                            filmImages: state.filmImages,
                            collectionIds: state.collectionIds,
                          );
                        }
                        return const SizedBox();
                      }),
            )),
      ),
    );
  }

  void _filmInformationBlocListener(BuildContext context, FilmInformationState state) {
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
        backgroundColor: color,
      ),
    );
  }
}

class _FilmInformationContent extends StatelessWidget {
  final FilmEntity film;
  final FilmImagesEntity? filmImages;
  final List<String> collectionIds;
  const _FilmInformationContent({
    required this.film,
    required this.filmImages,
    required this.collectionIds
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w),
            child: Column(
              children: [
                CachedNetworkImage(
                  imageUrl: film.posterUrlPreview ?? '',
                  cacheManager: FilmImageCacheManager.instance,
                  imageBuilder: (context, imageProvider) => Container(
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                        opacity: 1.0,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.white
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                ),
                TextButton(
                  onPressed: () => _openCollectionSheet(context),
                  child: const Text(
                    "Добавить в коллекцию",
                    style: TextStyle(color: Colors.purple),
                  ),
                ),
                BlocBuilder<WatchFilmCollectionLinksCubit, Set<int>>(
                  builder: (context, savedFilmIds) {
                    final isSaved = savedFilmIds.contains(film.kinopoiskId);
                    if(isSaved){
                      return TextButton(
                        onPressed: () => _openRatingSheet(context, film.userRating),
                        child: const Text("Оценить фильм", style: TextStyle(color: Colors.purple))
                      );
                    } else{
                      return SizedBox();
                    }
                  },
                ),
                SizedBox(height: 16),
                Text(film.nameRu ?? film.nameOriginal ?? "Без названия"),
                SizedBox(height: 8),
                Text(collectionIds.toString()),
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
                Text("Пользовательский рейтинг, ${film.userRating}"),
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

  void _openRatingSheet(BuildContext context, int? currentUserRating) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (bottomSheetContext) => BlocProvider.value(
          value: context.read<FilmInformationBloc>(),
          child: _RatingPickerSheet(currentUserRating: currentUserRating)));
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

class _RatingPickerSheet extends StatefulWidget {
  final int? currentUserRating;

  const _RatingPickerSheet({required this.currentUserRating});

  @override
  State<_RatingPickerSheet> createState() => _RatingPickerSheetState();
}

class _RatingPickerSheetState extends State<_RatingPickerSheet> {
  late final PageController _controller;
  late double currentPage;
  late int selectedRating;

 @override
  void initState() {
    super.initState();
    final initialPage = (widget.currentUserRating ?? 5) - 1;
    selectedRating = widget.currentUserRating ?? 5;
    currentPage = initialPage.toDouble();

    _controller = PageController(
      viewportFraction: 0.25,
      initialPage: initialPage,
    );

    _controller.addListener(() {
      setState(() {
        currentPage = _controller.page ?? currentPage;
        selectedRating = currentPage.round() + 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.28,
      builder: (context, scrollController) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            Text("Оценить", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20.h),
            SizedBox(
              height: 80.h,
              child: PageView.builder(
                controller: _controller,
                physics: const PageScrollPhysics(),
                itemCount: 10,
                itemBuilder: (context, index) {
                  final value = index + 1;
                  final diff = (currentPage - index).abs();
                  final scale = (1 - (diff * 0.3)).clamp(0.6, 1.0);
                  final opacity = (1 - (diff * 0.5)).clamp(0.3, 1.0);
                  return Center(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: opacity,
                      child: Transform.scale(
                        scale: scale,
                        child: Text("$value",
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: value == selectedRating
                                ? Colors.deepPurple
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  context.read<FilmInformationBloc>().add(UpdateFilmUserRating(userRating: selectedRating));
                  Navigator.pop(context);
                },
                child: const Text("Поставить оценку", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );
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
              final collectionIds = (filmState as FilmLoaded).collectionIds;

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
                    collectionsIds: collectionIds,
                    collections: collections);
              });
            },
          );
        });
  }
}

class _CollectionsList extends StatelessWidget {
  final ScrollController scrollController;
  final List<String> collectionsIds;
  final List<CollectionEntity> collections;

  const _CollectionsList({
    required this.scrollController,
    required this.collectionsIds,
    required this.collections});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        controller: scrollController,
        itemCount: collections.length + 1,
        itemBuilder: (context, index) {
          if(index == 0) {
            return _CreateCollectionTile();
          }
          final collection = collections[index-1];
          final isInCollection = collectionsIds.contains(collection.id);
          return _CollectionTile(collection: collection, isInCollection: isInCollection);
        });
  }
}

class _CreateCollectionTile extends StatelessWidget {
  const _CreateCollectionTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("Создать новую коллекцию"),
        onTap: () => showDialog(
          context: context, 
          builder: (dialogContext) {
            return BlocProvider.value(
              value: context.read<CollectionsBloc>(),
              child: const _CreateCollectionDialog(),
            );
          }
        )
    );
  }
}

class _CollectionTile extends StatelessWidget {
  final CollectionEntity collection;
  final bool isInCollection;
  
  const _CollectionTile({
    required this.collection,
    required this.isInCollection
  });

  @override
  Widget build(BuildContext context) {
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
  }
}

class _CreateCollectionDialog extends StatefulWidget {
  const _CreateCollectionDialog();

  @override
  State<_CreateCollectionDialog> createState() => _CreateCollectionDialogState();
}

class _CreateCollectionDialogState extends State<_CreateCollectionDialog> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final collectionBloc = context.read<CollectionsBloc>();

    return AlertDialog(
          title: Text('Новая коллекция'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Придумайте название',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            onChanged: (_) => setState(() {})
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: controller.text.isEmpty
                  ? null
                  : () {
                      collectionBloc.add(AddNewCollection(collectionName: controller.text));
                      Navigator.pop(context);
                    },
              child: Text('Сохранить'),
            ),
          ],
        );
  }
}
