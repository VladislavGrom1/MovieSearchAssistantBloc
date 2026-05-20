import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';
import 'package:movie_search_assistant_bloc/app/util/data_formatter.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/collection_films/collection_films_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/collection_films/selection_films_cubit/selection_films_cubit.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/error_message_widget.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/poster_film_image.dart';

@RoutePage()
class CollectionFilmsScreen extends StatelessWidget {
  const CollectionFilmsScreen({
    super.key,
    @PathParam('collectionId') required this.collectionId,
    @PathParam('collectionName') required this.collectionName
  });

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

class _CollectionFilmsView extends StatelessWidget {
  const _CollectionFilmsView({required this.collectionName});

  final String collectionName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryThemeBlack,
      appBar: AppBar(
        title: BlocBuilder<SelectionFilmsCubit, SelectionFilmsState>(
          builder: (context, state) {
            if (!state.isSelectionMode) {
              return Text(collectionName, style: CustomTextStyles.m3Title());
            } 
            return Text("Выбрано: ${state.selectedFilmIds.length}", style: CustomTextStyles.m3Title());
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
                        final selectedFilmIds = selectionFilmsState.selectedFilmIds;
                        context.read<CollectionFilmsBloc>().add(
                          RemoveFilms(
                            selectedFilmIds: selectedFilmIds, 
                            collectionId: collectionFilmsState.collectionId
                          ));
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
              if(state.savedFilms.isEmpty){
                return ErrorMessageWidget(message: "Коллекция пуста");
              }
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
      enableFeedback: false,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
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
        color: AppColors.primaryThemeGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.w),
        ),
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FilmPosterImage(
                localImagePath: savedFilm.localPosterImagePath,
                kinopoiskRating: savedFilm.ratingKinopoisk,
                userRating: savedFilm.userRating,
                showUserRating: true,
              ),
              SizedBox(width: 10.w),
              Expanded(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.h),
                    Text(
                      savedFilm.nameRu ?? savedFilm.nameOriginal ?? "-",
                      maxLines: 2,
                      style: CustomTextStyles.m3Title().copyWith(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      savedFilm.nameOriginal ?? savedFilm.nameRu ?? "-",
                      maxLines: 2,
                      style: CustomTextStyles.m3Body().copyWith(fontWeight: FontWeight.w400),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      DataFormatter.formatCountriesAndYear(savedFilm.countries, savedFilm.year),
                      maxLines: 1,
                      style: CustomTextStyles.m3Body(color: AppColors.primaryScheme).copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      DataFormatter.formatGenres(savedFilm.genres),
                      maxLines: 1,
                      style: CustomTextStyles.m3Body().copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                )
              ),
              BlocBuilder<SelectionFilmsCubit, SelectionFilmsState>(
                builder: (context, state) {
                  if (!state.isSelectionMode) {
                    return SizedBox(
                      width: 40.w,
                      child: PopupMenuButton(
                          color: AppColors.primaryThemeGrey,
                          enableFeedback: false,
                          icon: Icon(Icons.more_vert, color: AppColors.primaryScheme),
                          onSelected: (value) {
                            if (value == "removeFilm") onRemove();
                          },
                          itemBuilder: (_) => [PopupMenuItem(value: 'removeFilm', child: Text("Удалить фильм", style: CustomTextStyles.m3Body()))]),
                    );
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
      ),
    );
  }
}
