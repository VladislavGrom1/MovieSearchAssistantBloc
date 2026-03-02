import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_images_entity.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/collections/collections_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/film_information/film_information_bloc.dart';

class FilmInformationWidget extends StatefulWidget {
  const FilmInformationWidget(
      {super.key,
      required this.filmInformationBloc,
      required this.collectionsBloc,
      required this.film,
      required this.images,
      required this.collections,
      required this.onAddFilmInCollectionPressed,
      required this.onRemoveFilmFromCollectionPressed});

  final FilmInformationBloc filmInformationBloc;
  final CollectionsBloc collectionsBloc;
  final FilmEntity film;
  final FilmImagesEntity? images;
  final List<CollectionEntity> collections;
  final Function(String) onAddFilmInCollectionPressed;
  final Function(String) onRemoveFilmFromCollectionPressed;

  @override
  State<FilmInformationWidget> createState() => _FilmInformationWidgetState();
}

class _FilmInformationWidgetState extends State<FilmInformationWidget> {
  @override
  Widget build(BuildContext context) {
    final titleText = widget.film.nameRu ??
        widget.film.nameOriginal ??
        "Название отсутствует";
    return CustomScrollView(slivers: [
      SliverList.list(children: [
        Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => pickCollection(context),
                    child: Text(
                      "Добавить фильм в коллекцию",
                      style: TextStyle(color: Colors.purple),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(titleText),
                  SizedBox(height: 10.h),
                  Text(widget.film.collectionIds.toString()),
                  SizedBox(height: 10.h),
                  ..._nameOriginal(widget.film.nameOriginal),
                  Text(widget.film.serial!
                      ? "${widget.film.startYear} - ${widget.film.endYear ?? "настоящее время"}"
                      : "${widget.film.year}"),
                  SizedBox(height: 10.h),
                  Text(_getCountriesString(widget.film.countries)),
                  SizedBox(height: 10.h),
                  Text(_getGenresString(widget.film.genres)),
                  SizedBox(height: 10.h),
                  Text(widget.film.description.toString()),
                  SizedBox(height: 10.h),
                  Text(_getSloganString(widget.film.slogan)),
                  SizedBox(height: 10.h),
                  _filmRatingAndReviewCount(
                      "Рейтинг KP",
                      widget.film.ratingKinopoisk,
                      widget.film.ratingKinopoiskVoteCount),
                  SizedBox(height: 10.h),
                  _filmRatingAndReviewCount("Рейтинг IMDB",
                      widget.film.ratingImbd, widget.film.ratingImdbVoteCount),
                  SizedBox(height: 10.h),
                  Text("${widget.images?.imageUrls.toString()}")
                ]))
      ]),
    ]);
  }

  void pickCollection(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: widget.filmInformationBloc),
          BlocProvider.value(value: widget.collectionsBloc),
        ],
        child: Builder(
          builder: (context) {
            final collectionsBloc = widget.collectionsBloc;
            final currentCollections = collectionsBloc.state is CollectionsLoadedSuccesful
                ? (collectionsBloc.state as CollectionsLoadedSuccesful).collections
                : widget.collections;
            
            final int itemCount = currentCollections.length;
            final double itemHeight = 60.h;
            final double headerHeight = 100.h;

            double contentHeight = (itemCount * itemHeight) + headerHeight;
            double screenHeight = MediaQuery.of(context).size.height;

            double initialSize = (contentHeight / screenHeight).clamp(0.1, 0.95);
            double minSize = 0.1;
            double maxSize = 0.95;

            return DraggableScrollableSheet(
              initialChildSize: initialSize,
              minChildSize: minSize,
              maxChildSize: maxSize,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 8.h),
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2.h),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.h),
                        child: Text(
                          "Добавить в коллекцию",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Flexible(
                        child: BlocBuilder<CollectionsBloc, CollectionsState>(
                          builder: (context, collectionState) {
                            final collections = collectionState is CollectionsLoadedSuccesful
                                ? collectionState.collections
                                : <CollectionEntity>[];

                            return BlocBuilder<FilmInformationBloc,
                                FilmInformationState>(
                              builder: (context, filmInformationState) {
                                final currentFilm =
                                    filmInformationState is FilmInformationLoadedSuccessful
                                        ? filmInformationState.filmInformation
                                        : widget.film;

                                if (collections.isEmpty) {
                                  return Center(
                                      child: Text("Нет доступных коллекций"));
                                }

                                return ListView.builder(
                                  controller: scrollController,
                                  shrinkWrap: true,
                                  itemCount: collections.length,
                                  itemBuilder: (context, index) {
                                    final collection = collections[index];
                                    final isInCollection = currentFilm
                                            .collectionIds
                                            ?.contains(collection.id) ??
                                        false;

                                    return ListTile(
                                      leading: Container(
                                        height: 50.h,
                                        width: 50.w,
                                        color: Colors.purple,
                                      ),
                                      trailing: isInCollection
                                          ? Icon(Icons.check_box,
                                              color: Colors.green)
                                          : Icon(Icons.add,
                                              color: Colors.grey),
                                      title: Text(collection.name ?? "Без названия"),
                                      onTap: () {
                                        if (isInCollection) {
                                          widget
                                              .onRemoveFilmFromCollectionPressed(
                                                  collection.id!);
                                        } else {
                                          widget
                                              .onAddFilmInCollectionPressed(
                                                  collection.id!);
                                        }
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          },
        ),
      );
    },
  );
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
