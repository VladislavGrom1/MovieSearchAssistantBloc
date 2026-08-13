import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';
import 'package:movie_search_assistant_bloc/app/util/data_formatter.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/collection_films/collection_films_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/collection_films/selection_films_cubit/selection_films_cubit.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/custom_search_bar.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/error_message_widget.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/film_poster_image.dart';

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

class _CollectionFilmsView extends StatefulWidget {
  const _CollectionFilmsView({required this.collectionName});

  final String collectionName;

  @override
  State<_CollectionFilmsView> createState() => _CollectionFilmsViewState();
}

class _CollectionFilmsViewState extends State<_CollectionFilmsView> {
  bool _isSearch = false;
  String _searchKeyword = '';

  void _onSearchSubmitted(String keyword, BuildContext context) {
    setState(() {
      _searchKeyword = keyword.toLowerCase();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearch = !_isSearch;
      if (!_isSearch) {
        _searchKeyword = '';
      }
    });
  }

  List<FilmEntity> _getFilteredFilms(List<FilmEntity> films) {
    if (_searchKeyword.isEmpty) {
      return films;
    }
    return films.where((film) {
      final nameRu = film.nameRu?.toLowerCase() ?? '';
      final nameOriginal = film.nameOriginal?.toLowerCase() ?? '';
      return nameRu.contains(_searchKeyword) || nameOriginal.contains(_searchKeyword);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryThemeBlack,
      appBar: AppBar(
        automaticallyImplyLeading: !_isSearch,
        title: BlocBuilder<SelectionFilmsCubit, SelectionFilmsState>(
          builder: (context, state) {
            if (state.isSelectionMode) {
              return Text("Выбрано: ${state.selectedFilmIds.length}", style: CustomTextStyles.m3Title());
            }
            if (_isSearch){
              return CustomSearchBar(
                key: ValueKey('search_bar'),
                onSearchSubmitted: _onSearchSubmitted,
                useFilterButton: false,
                useRealTimeChange: true,
                onClear: () {
                  setState(() {
                    _searchKeyword = '';
                  });
                },
              );
            }
            return Text(widget.collectionName, style: CustomTextStyles.m3Title());
          },
        ),
        actions: [
          BlocBuilder<SelectionFilmsCubit, SelectionFilmsState>(
            builder: (context, selectionFilmsState) {
              if (_isSearch) {
                return IconButton(
                  icon: Icon(Icons.search_off, color: AppColors.primaryScheme),
                  onPressed: _toggleSearch,
                );
              }
              
              if (!selectionFilmsState.isSelectionMode) {
                return IconButton(
                  icon: Icon(Icons.search, color: AppColors.primaryScheme),
                  onPressed: _toggleSearch,
                );
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
      padding: EdgeInsets.only(left: 20, right: 20),
      child: BlocBuilder<CollectionFilmsBloc, CollectionFilmsState>(
        builder: (context, state) {
          if (state is CollectionFilmsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CollectionFilmsFailure) {
            return Center(child: Text(state.message));
          }

          if (state is CollectionFilmsLoaded) {
            if (state.savedFilms.isEmpty) {
              return ErrorMessageWidget(message: "Коллекция пуста");
            }
            
            final filteredFilms = _getFilteredFilms(state.savedFilms);
            
            if (filteredFilms.isEmpty) {
              return Center(
                child: Text(
                "Фильмы не найдены", 
                style: CustomTextStyles.m3Title(), 
                textAlign: TextAlign.center
              ),
              );
            }
            
            return _CollectionFilmsList(
              savedFilms: filteredFilms,
              collectionId: state.collectionId,
              isSearchMode: _isSearch,
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
  final bool isSearchMode;

  const _CollectionFilmsList({
    required this.savedFilms, 
    required this.collectionId,
    required this.isSearchMode,
  });

  @override
  Widget build(BuildContext context) {
    final collectionFilmsBloc = context.read<CollectionFilmsBloc>();
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
              isSearchMode: isSearchMode,
          );
        },
        separatorBuilder: (context, index) => SizedBox(height: 12),
        itemCount: savedFilms.length);
  }
}

class _FilmCard extends StatelessWidget {
  final FilmEntity savedFilm;
  final String collectionId;
  final CollectionFilmsBloc collectionFilmsBloc;
  final bool isSearchMode;

  const _FilmCard({
    required this.savedFilm,
    required this.collectionId,
    required this.collectionFilmsBloc,
    required this.isSearchMode,
  });

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
        if (isSearchMode) {
          context.router.push(FilmInformationRoute(
              filmId: savedFilm.kinopoiskId!,
              filmName: savedFilm.nameRu ?? savedFilm.nameOriginal.toString()));
          return;
        }
        
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
        if (!isSearchMode) {
          context.read<SelectionFilmsCubit>().enterSelection(savedFilm.kinopoiskId!);
        }
      },
      child: Card(
        color: AppColors.primaryThemeGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
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
              SizedBox(width: 10),
              Expanded(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      savedFilm.nameRu ?? savedFilm.nameOriginal ?? "-",
                      maxLines: 2,
                      style: CustomTextStyles.m3Title().copyWith(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 10),
                    Text(
                      savedFilm.nameOriginal ?? savedFilm.nameRu ?? "-",
                      maxLines: 2,
                      style: CustomTextStyles.m3Body().copyWith(fontWeight: FontWeight.w400),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      DataFormatter.formatCountriesAndYear(savedFilm.countries, savedFilm.year),
                      maxLines: 1,
                      style: CustomTextStyles.m3Body(color: AppColors.primaryScheme).copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
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
                  if (isSearchMode) {
                    return SizedBox(
                      width: 40,
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
                  
                  if (!state.isSelectionMode) {
                    return SizedBox(
                      width: 40,
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
