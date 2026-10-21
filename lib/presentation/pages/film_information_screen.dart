import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/app/cache_service/film_image_cache_service.dart';
import 'package:movie_search_assistant_bloc/app/cache_service/image_path_resolver.dart';
import 'package:movie_search_assistant_bloc/app/network_service/cubit/internet_cubit.dart';
import 'package:movie_search_assistant_bloc/app/theme/app_colors.dart';
import 'package:movie_search_assistant_bloc/app/theme/custom_text_styles.dart';
import 'package:movie_search_assistant_bloc/app/util/data_formatter.dart';
import 'package:movie_search_assistant_bloc/app/util/responsive_extension.dart';
import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_images_entity.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/collections/collections_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/film_information/cubit/similar_films_cubit.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/film_information/film_information_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/search_films/cubit/watch_film_collection_links_cubit.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/search_films/cubit/watch_saved_films_status_cubit.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/confirm_alert_dialog.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/custom_refresh_indicator.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/custom_snack_bar.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/error_message_widget.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/film_poster_card.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/widgets/text_field_alert_dialog.dart';
import 'package:skeletonizer/skeletonizer.dart';

@RoutePage()
class FilmInformationScreen extends StatelessWidget {
  const FilmInformationScreen(
      {super.key,
      @PathParam('filmId') required this.filmId,
      @PathParam('filmName') required this.filmName});
 
  final int filmId;
  final String filmName;
 
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider(
        create: (_) => getIt<FilmInformationBloc>()..add(GetFilmInformation(idFilm: filmId)),
      ),
      BlocProvider(
        create: (_) => getIt<CollectionsBloc>()..add(GetCollections()),
      ),
      BlocProvider(create: (_) => getIt<WatchFilmCollectionLinksCubit>()),
      BlocProvider(create: (_) => getIt<WatchSavedFilmsStatusCubit>()),
      BlocProvider(create: (_) => getIt<SimilarFilmsCubit>()),
    ], child: _FilmInformationView(filmId: filmId, filmName: filmName));
  }
}
 
class _FilmInformationView extends StatelessWidget {
  const _FilmInformationView({required this.filmId, required this.filmName});
 
  final int filmId;
  final String filmName;
 
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<FilmInformationBloc, FilmInformationState>(
            listener: _filmInformationBlocListener),
      ],
      child: Scaffold(
        backgroundColor: AppColors.primaryThemeBlack,
        body: SafeArea(
            child: CustomRefreshIndicator(
          onRefresh: () async {
            final filmInformationBloc = context.read<FilmInformationBloc>();
            final state = filmInformationBloc.state;
            if (state is FilmLoaded) {
              final currentFilm = state.film;
              filmInformationBloc.add(RefreshFilmInformation(film: currentFilm));
            }
 
            if (state is FilmFailure) {
              filmInformationBloc.add(GetFilmInformation(idFilm: filmId));
            }
          },
          child: BlocBuilder<FilmInformationBloc, FilmInformationState>(
              builder: (context, state) {
            if (state is FilmLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is FilmLoaded) {
              return _FilmInformationContent(
                filmId: filmId,
                film: state.film,
                filmImages: state.filmImages,
                collectionIds: state.collectionIds,
              );
            }
            if (state is FilmFailure) {
              return Scaffold(
                backgroundColor: AppColors.primaryThemeBlack,
                appBar: AppBar(
                  title: Text(
                    filmName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyles.m3ActionText(),
                  ),
                  backgroundColor: AppColors.primaryThemeBlack,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: IconThemeData(color: AppColors.primaryScheme),
                ),
                body: Center(
                  child: ErrorMessageWidget(
                    message: state.message
                  ),
                )
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
      CustomSnackBar(message: state.message).show(context);
    }
  }
}
 
class _FilmInformationContent extends StatefulWidget {
  final int filmId;
  final FilmEntity film;
  final FilmImagesEntity? filmImages;
  final List<String> collectionIds;
 
  const _FilmInformationContent(
      {required this.filmId,
      required this.film,
      required this.filmImages,
      required this.collectionIds});
 
  @override
  State<_FilmInformationContent> createState() => _FilmInformationContentState();
}
 
class _FilmInformationContentState extends State<_FilmInformationContent> {
  static const double _expandedHeight = 500;
 
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _titleOpacity = ValueNotifier(0.0);
 
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateTitleOpacity);
  }
 
  void _updateTitleOpacity() {
    final collapseRange = _expandedHeight - kToolbarHeight;
    final offset = _scrollController.hasClients ? _scrollController.offset : 0.0;
    final fadeStart = collapseRange * 0.85;
    final fadeRange = collapseRange - fadeStart;
    final progress = fadeRange <= 0
        ? (offset >= collapseRange ? 1.0 : 0.0)
        : ((offset - fadeStart) / fadeRange).clamp(0.0, 1.0);
 
    if (_titleOpacity.value != progress) {
      _titleOpacity.value = progress;
    }
  }
 
  @override
  void dispose() {
    _scrollController.removeListener(_updateTitleOpacity);
    _scrollController.dispose();
    _titleOpacity.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    final film = widget.film;
    final filmImages = widget.filmImages;
 
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          backgroundColor: AppColors.primaryThemeBlack,
          surfaceTintColor: Colors.transparent,
          pinned: true,
          floating: false,
          expandedHeight: _expandedHeight,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppColors.primaryScheme),
          title: ValueListenableBuilder<double>(
            valueListenable: _titleOpacity,
            builder: (context, opacity, child) => Opacity(
              opacity: opacity,
              child: child,
            ),
            child: Text(
              film.nameRu ?? film.nameOriginal ?? "Без названия",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CustomTextStyles.m3ActionText(),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: _PosterImageWidget(film: film),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  film.nameRu ?? film.nameOriginal ?? "Без названия",
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center, 
                  style: CustomTextStyles.m3Headline().copyWith(height: 1.1)
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${film.ratingKinopoisk ?? "-"}", 
                      style: CustomTextStyles.m3Body(color: _getRatingColor(film.ratingKinopoisk))
                    ),
                    const SizedBox(width: 5),
                    Text(
                      film.ratingKinopoiskVoteCount == null 
                      ? "Нет данных"
                      : DataFormatter.formatVoteCount(film.ratingKinopoiskVoteCount!),
                      style: CustomTextStyles.m3Body(color: AppColors.textDarkGrey),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        "${film.nameOriginal ?? film.nameRu ?? film.nameEn}",
                        overflow: TextOverflow.ellipsis,
                        style: CustomTextStyles.m3Body(),
                      ),
                    )
                  ]
                ),
                const SizedBox(height: 10),
                Text(
                  film.serial!
                    ? "${film.startYear} - ${film.endYear ?? "настоящее время"}"
                    : "${film.year}",
                  style: CustomTextStyles.m3Body(color: AppColors.textDarkGrey),
                ),
                const SizedBox(height: 10),
                Text(
                  DataFormatter.formatCountries(film.countries), 
                  style: CustomTextStyles.m3Body(color: AppColors.textDarkGrey)
                ),
                const SizedBox(height: 10),
                Text(
                  DataFormatter.formatGenres(film.genres),
                  style: CustomTextStyles.m3Body(),
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryThemeGrey,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      _ActionButton(
                        icon: Icons.bookmark_add_outlined,
                        label: "Коллекции",
                        color: AppColors.primaryScheme,
                        onTap: () => _openCollectionSheet(context),
                      ),
                      BlocBuilder<WatchFilmCollectionLinksCubit, Set<int>>(
                        builder: (context, savedFilmIds) {
                          final isSaved = savedFilmIds.contains(film.kinopoiskId);
                          return _ActionButton(
                            icon: Icons.star_border_rounded,
                            label: "Оценить",
                            color: isSaved ? AppColors.primaryScheme : AppColors.textDarkGrey,
                            onTap: isSaved ? () => _openRatingSheet(context, film.userRating) : null,
                          );
                        },
                      ),
                      _ActionButton(
                        icon: Icons.public,
                        label: "Подробнее",
                        color: AppColors.primaryScheme,
                        onTap: () => context.read<FilmInformationBloc>().add(LaunchUrl(url: film.webUrl)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Divider(color: AppColors.primaryScheme, thickness: 2),
                const SizedBox(height: 20),
                Container(
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: AppColors.primaryThemeGrey,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: film.slogan == null 
                  ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        const SizedBox(height: 20),
                        Icon(Icons.rate_review_sharp, size: 48, color: AppColors.primaryScheme),
                        const SizedBox(height: 8),
                        Text(
                          "Слоган отсутствует", 
                          style: CustomTextStyles.m3Body()
                        ),
                        const SizedBox(height: 20),
                      ],
                  )
                  : Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                    child: Align(
                      alignment: AlignmentGeometry.center,
                      child: Text(
                        "«${film.slogan}»",
                        textAlign: TextAlign.center, 
                        softWrap: true,
                        style: CustomTextStyles.m3Content().copyWith(
                          fontStyle: FontStyle.italic,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                  )
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: AppColors.primaryThemeGrey,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: film.description == null 
                  ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        const SizedBox(height: 40),
                        Icon(Icons.rate_review_sharp, size: 48, color: AppColors.primaryScheme),
                        const SizedBox(height: 8),
                        Text(
                          "Описание отсутствует", 
                          style: CustomTextStyles.m3Body()
                        ),
                        const SizedBox(height: 40),
                      ],
                  )
                  : Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 30),
                    child: Text(
                        film.description!,
                        style: CustomTextStyles.m3Body(),
                        softWrap: true,
                      ),
                  )
                ),
                const SizedBox(height: 20),
                Divider(color: AppColors.primaryScheme, thickness: 2),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      "Рейтинг", 
                      style: CustomTextStyles.m3Headline(), 
                      textAlign: TextAlign.left,
                    ),
                    if (film.userRating != null)
                      IconButton(
                        onPressed: () => _showConfirmActionDialog(
                          context, 
                          "Удалить пользовательский рейтинг", 
                          Text.rich(
                              TextSpan(
                                style: CustomTextStyles.m3Content(),
                                children: [
                                  const TextSpan(text: "Вы действительно хотите "),
                                  TextSpan(text: "удалить", style: CustomTextStyles.m3Content(color: AppColors.primaryScheme)),
                                  const TextSpan(text: " пользовательский рейтинг?"),
                                ],
                              ),
                            ),
                          "Удалить",
                          () => context.read<FilmInformationBloc>().add(UpdateUserFilmInformation(clearUserRating: true)),
                        ),
                        icon: Icon(Icons.delete, color: AppColors.primaryScheme),
                    ),
                  ]
                ),
                const SizedBox(height: 20),
                _FilmRatingWidget(
                  imagePath: "assets/icons/kp.jpg", 
                  resourseName: "КиноПоиск", 
                  rating: film.ratingKinopoisk, 
                  voteCount: film.ratingKinopoiskVoteCount,
                  isUserRating: false,
                ),
                const SizedBox(height: 10),
                _FilmRatingWidget(
                  imagePath: "assets/icons/imdb.png", 
                  resourseName: "IMDB", 
                  rating: film.ratingImbd, 
                  voteCount: film.ratingImdbVoteCount,
                  isUserRating: false,
                ),
                const SizedBox(height: 10),
                _FilmRatingWidget(
                  imagePath: "assets/icons/movie_search_assistant_icon_dark.png", 
                  resourseName: "Польз. рейтинг", 
                  rating: film.userRating, 
                  isUserRating: true,
                ),
                const SizedBox(height: 20),
                Divider(color: AppColors.primaryScheme, thickness: 2),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      "Отзыв", 
                      style: CustomTextStyles.m3Headline(), 
                      textAlign: TextAlign.left,
                    ),
                    BlocBuilder<WatchFilmCollectionLinksCubit, Set<int>>(
                      builder: (context, savedFilmIds) {
                        final isSaved = savedFilmIds.contains(film.kinopoiskId);
                        return IconButton(
                          onPressed: isSaved ? () => _openCommentDialog(context) : null,
                          icon: Icon(Icons.edit, color: isSaved ? AppColors.primaryScheme : AppColors.textDarkGrey),
                        );
                      },
                    ),
                    if (film.userComment != null && film.userComment!.isNotEmpty)
                      IconButton(
                        onPressed: () => _showConfirmActionDialog(
                          context, 
                          "Удалить отзыв", 
                          Text.rich(
                              TextSpan(
                                style: CustomTextStyles.m3Content(),
                                children: [
                                  const TextSpan(text: "Вы действительно хотите "),
                                  TextSpan(text: "удалить", style: CustomTextStyles.m3Content(color: AppColors.primaryScheme)),
                                  const TextSpan(text: " отзыв?"),
                                ],
                              ),
                            ),
                          "Удалить",
                          () => context.read<FilmInformationBloc>().add(UpdateUserFilmInformation(userComment: "")),
                        ),
                        icon: Icon(Icons.delete, color: AppColors.primaryScheme),
                    ),
                  ]
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: AppColors.primaryThemeGrey,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: film.userComment == null || film.userComment!.isEmpty
                  ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        const SizedBox(height: 40),
                        Icon(Icons.rate_review_sharp, size: 48, color: AppColors.primaryScheme),
                        const SizedBox(height: 8),
                        Text(
                          "Отзыв отсутствует", 
                          style: CustomTextStyles.m3Body()
                        ),
                        const SizedBox(height: 40),
                      ],
                  )
                  : Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 40),
                    child: Text(
                        film.userComment!,
                        style: CustomTextStyles.m3Body()
                      ),
                  )
                ),
                const SizedBox(height: 20),
                Divider(color: AppColors.primaryScheme, thickness: 2),
                const SizedBox(height: 20),
                Align(
                  alignment: AlignmentGeometry.centerLeft,
                  child: Text(
                    "Кадры из фильма", 
                    style: CustomTextStyles.m3Headline(), 
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(height: 20),
                _FilmScreenshotsWidget(
                  imageUrls: filmImages?.imageUrls, 
                  localImagePaths: film.localScreenshotPaths
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        _SimilarFilmsSliver(filmId: widget.filmId),
      ],
    );
  }
 
  Color _getRatingColor(num? rating) {
    if (rating == null) return AppColors.ratingGrey;
    if (rating >= 7 && rating <= 10) return AppColors.ratingGreen;
    if (rating >= 6 && rating < 7) return AppColors.ratingOrange;
    if (rating >= 5 && rating < 6) return AppColors.ratingGrey;
    if (rating >= 0 && rating < 5) return AppColors.ratingRed;
    return AppColors.ratingGrey;
  }
 
  void _openCollectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.primaryThemeBlack,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(
              value: context.read<FilmInformationBloc>(),
            ),
            BlocProvider.value(
              value: context.read<CollectionsBloc>(),
            ),
          ],
          child: SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(bottomSheetContext).size.height * 0.8),
              child: const _CollectionPickerSheet()
              ),
            ),
        );
      },
    );
  }
 
  void _openRatingSheet(BuildContext context, int? currentUserRating) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (bottomSheetContext) => BlocProvider.value(
          value: context.read<FilmInformationBloc>(),
          child: _RatingPickerSheet(currentUserRating: currentUserRating))
      );
  }
 
  void _openCommentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
          value: context.read<FilmInformationBloc>(),
          child: TextFieldAlertDialog(
              titleText: 'Изменить пользовательский отзыв', 
              startText: widget.film.userComment,
              hintText: 'Новый отзыв',
              maxLenght: 500,
              maxLines: 8,
              actionText: "Сохранить", 
              actionFunc: (controllerText) => context.read<FilmInformationBloc>().add(UpdateUserFilmInformation(userComment: controllerText))
            ),
          )
      );
  }
 
  void _showConfirmActionDialog(
    BuildContext context, 
    String titleText, 
    Widget content, 
    String actionText, 
    VoidCallback actionFunc
    ){
    showDialog(
      context: context, 
      builder: (dialogContext) {
        return ConfirmAlertDialog(
          titleText: titleText, 
          content: content, 
          actionText: actionText, 
          actionFunc: actionFunc
        );
      }
    );
  }
}
 
class _SimilarFilmsSliver extends StatelessWidget {
  final int filmId;
 
  const _SimilarFilmsSliver({required this.filmId});
 
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkCubit, NetworkStatus>(
      buildWhen: (previous, current) =>
          (previous == NetworkStatus.connected) != (current == NetworkStatus.connected),
      builder: (context, status) {
        if (status != NetworkStatus.connected) {
          return const SliverToBoxAdapter();
        }
        return _SimilarFilmsContent(filmId: filmId);
      },
    );
  }
}
 
class _SimilarFilmsContent extends StatefulWidget {
  final int filmId;
 
  const _SimilarFilmsContent({required this.filmId});
 
  @override
  State<_SimilarFilmsContent> createState() => _SimilarFilmsContentState();
}
 
class _SimilarFilmsContentState extends State<_SimilarFilmsContent> {
  @override
  void initState() {
    super.initState();
    context.read<SimilarFilmsCubit>().load(widget.filmId);
  }
 
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SimilarFilmsCubit, SimilarFilmsState>(
      builder: (context, state) {
        if (state is SimilarFilmsLoaded && state.films.isEmpty) {
          return const SliverToBoxAdapter();
        }
 
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SimilarFilmsHeader(),
              _buildBody(context, state),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
 
  Widget _buildBody(BuildContext context, SimilarFilmsState state) {
    if (state is SimilarFilmsLoaded) {
      final films = state.films;
      return SizedBox(
        height: 200,
        child: ListView.separated(
          addAutomaticKeepAlives: false,
          addSemanticIndexes: false,
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: films.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) => FilmPosterCard(
            key: ValueKey(films[index].kinopoiskId),
            film: films[index],
            showRating: false,
          ),
        ),
      );
    }
 
    if (state is SimilarFilmsFailure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Не удалось загрузить похожие фильмы",
                textAlign: TextAlign.center,
                style: CustomTextStyles.m3Body(),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => context.read<SimilarFilmsCubit>().load(widget.filmId),
                child: Text(
                  "Повторить",
                  style: CustomTextStyles.m3ActionText(color: AppColors.primaryScheme),
                ),
              ),
            ],
          ),
        ),
      );
    }
 
    return const SizedBox(
      height: 100,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
 
class _SimilarFilmsHeader extends StatelessWidget {
  const _SimilarFilmsHeader();
 
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: AppColors.primaryScheme, thickness: 2),
          const SizedBox(height: 20),
          Text(
            "Похожие фильмы",
            style: CustomTextStyles.m3Headline(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
 
class _PosterImageWidget extends StatelessWidget {
  const _PosterImageWidget({required this.film});
 
  final FilmEntity film;
 
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildImage(),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.6, 1.0],
              colors: [
                Colors.transparent,
                Colors.transparent,
                AppColors.primaryThemeBlack.withValues(alpha: 0.95),
              ],
            ),
          ),
        ),
      ],
    );
  }
 
  Widget _buildImage() {
    if (film.localPosterImagePath != null) {
      final fullPosterImagePath = ImagePathResolver.resolve(film.localPosterImagePath!);
      return Image.file(
        File(fullPosterImagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    }
 
    final posterUrl = film.posterUrl;
    if (posterUrl == null || posterUrl.isEmpty) {
      return _placeholder();
    }
 
    return CachedNetworkImage(
      imageUrl: posterUrl,
      cacheManager: getIt<FilmImageCacheService>().instance,
      fit: BoxFit.cover,
      placeholder: (context, url) => LayoutBuilder(
        builder: (context, constraints) {
          return Skeletonizer(
            enabled: true,
            effect: const ShimmerEffect(
              baseColor: AppColors.primaryThemeBlack,
              highlightColor: AppColors.primaryThemeGrey,
              duration: Duration(seconds: 4),
            ),
            child: Container(
              width: constraints.maxWidth.isFinite ? constraints.maxWidth : double.infinity,
              height: constraints.maxHeight.isFinite ? constraints.maxHeight : 200,
              color: AppColors.primaryThemeGrey,
            ),
          );
        },
      ),
      errorWidget: (context, url, error) => _placeholder(),
    );
  }
 
  Widget _placeholder() => Container(
    color: AppColors.primaryThemeGrey,
    child: Icon(Icons.image_not_supported, color: AppColors.primaryScheme, size: 48),
  );
}
 
class _FilmRatingWidget extends StatelessWidget {
  final String imagePath;
  final String resourseName;
  final num? rating;
  final int? voteCount;
  final bool isUserRating;
 
  const _FilmRatingWidget({
    required this.imagePath,
    required this.resourseName,
    this.rating,
    this.voteCount,
    required this.isUserRating
  });
 
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primaryThemeGrey,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width - 40,
          maxHeight: 90,
          minHeight: 80,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildRatingCircle(context),
              const VerticalDivider(width: 1, thickness: 2, color: AppColors.primaryScheme),
              _buildRatingInfo(context, isUserRating),
            ],
          ),
        ),
      ),
    );
  }
 
  Widget _buildRatingCircle(BuildContext context) {
    return SizedBox(
      width: 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryThemeGrey,
              image: DecorationImage(
                opacity: 0.15,
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              rating != null ? rating.toString() : "-",
              style: CustomTextStyles.m3Title().copyWith(fontSize: 40, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildRatingInfo(BuildContext context, bool isUserRating) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: 12, right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              resourseName,
              style: CustomTextStyles.m3Title(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            if(!isUserRating) 
            Text(
              voteCount != null
                  ? "${DataFormatter.formatVoteCount(voteCount!)} оценок"
                  : "Нет данных",
              style: CustomTextStyles.m3Title(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
      ),
    );
  }
}
 
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
 
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
 
  @override
  Widget build(BuildContext context) {
    return InkWell(
      enableFeedback: false,
      highlightColor: AppColors.primaryThemeBlack,
      splashColor: AppColors.primaryThemeBlack,
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(label, style: CustomTextStyles.m3ActionText(color: color).copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
 
class _FilmScreenshotsWidget extends StatelessWidget {
  final List<String>? imageUrls;
  final List<String>? localImagePaths;
 
  const _FilmScreenshotsWidget({
    required this.imageUrls,
    required this.localImagePaths
  });
 
  @override
  Widget build(BuildContext context) {
    final hasLocalImages = localImagePaths?.isNotEmpty == true;
    final hasUrlImages = imageUrls?.isNotEmpty == true;
    
    if (!hasLocalImages && !hasUrlImages) {
      return Center(
        child: Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: AppColors.primaryThemeGrey,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 40),
              Icon(Icons.image_not_supported, size: 48, color: AppColors.primaryScheme),
              SizedBox(height: 8),
              Text("Кадры отсутствуют", style: CustomTextStyles.m3Body()),
              SizedBox(height: 40),
            ],
          ),
        ),
      );
    }
 
    final itemCount = hasLocalImages ? localImagePaths!.length : imageUrls!.length;
 
    return SizedBox(
      height: 200,
      child: ListView.separated(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(width: 15),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (hasLocalImages) {
            return ScreenshotFilm(localPath: localImagePaths![index]);
          } else {
            return ScreenshotFilm(url: imageUrls![index]);
          }
        },
      ),
    );
  }
}
 
class ScreenshotFilm extends StatefulWidget {
    const ScreenshotFilm({
      super.key, 
      this.url,
      this.localPath
      });
 
    final String? url;
    final String? localPath;
 
  @override
  State<ScreenshotFilm> createState() => _ScreenshotFilmState();
}
 
class _ScreenshotFilmState extends State<ScreenshotFilm> {
    final _transformationController = TransformationController();
    late OverlayEntry _overlayEntry;
    late TapDownDetails _doubleTapDetails;
    bool _isShowing = false;
    
    void _showPhoto(String imagePath) {
      if (!_isShowing) {
        _overlayEntry = _createOverlayEntry(imagePath);
        Overlay.of(context).insert(_overlayEntry);
        setState(() {
          _isShowing = true;
        });
      }
    }
 
    void _closePhoto() {
      if (_isShowing) {
        _overlayEntry.remove();
        setState(() {
          _isShowing = false;
        });
      }
    }
 
    void _handleDoubleTapDown(TapDownDetails details) {
      _doubleTapDetails = details;
    }
 
    void _handleDoubleTap() {
      if (_transformationController.value != Matrix4.identity()) {
        _transformationController.value = Matrix4.identity();
      } else {
        final position = _doubleTapDetails.localPosition;
        _transformationController.value = Matrix4.identity()
          ..translate(-position.dx, -position.dy)
          ..scale(2.0);
      }
    }
 
      OverlayEntry _createOverlayEntry(String imagePath) {
        return OverlayEntry(
          builder: (context) {
            return GestureDetector(
              onTap: _closePhoto,
              onDoubleTap: _handleDoubleTap,
              onDoubleTapDown: _handleDoubleTapDown,
              onTapCancel: _closePhoto,
              child: Container(
                  height: context.screenHeight * 0.6,
                  width: context.screenWidth * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                  ),
                  child: widget.url != null 
                  ? InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 3.0,
                    transformationController: _transformationController,
                    constrained: true,
                    child: CachedNetworkImage(
                        imageUrl: imagePath,
                        cacheManager: getIt<FilmImageCacheService>().instance,
                        progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                          child: Container(
                            height: 100,
                            width: 100,
                            color: Colors.transparent,
                            child: Center(
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value: downloadProgress.progress,
                                ),
                              ),
                            ),
                          ),
                        ),
                      errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, color: AppColors.primaryScheme),
                    ),
                  )
                  : InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 3.0,
                      transformationController: _transformationController,
                      constrained: true,
                      child: Image.file(
                        File(imagePath),
                        //fit: BoxFit.cover,
                        errorBuilder: (context, url, error) => const Icon(Icons.image_not_supported, color: AppColors.primaryScheme)),
                  ),
                ),
            );
          },
        );
      }
 
    @override
    Widget build(BuildContext context) {
      String imagePath;
 
      if (widget.localPath != null) {
        imagePath = ImagePathResolver.resolve(widget.localPath!);
      } else {
        imagePath = widget.url!;
      }
 
      return PopScope(
        canPop: !_isShowing,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && _isShowing) {
            _closePhoto();
          }
        },
        child: GestureDetector(
          onTap: () {
            _showPhoto(imagePath);
          },
          child: Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: RepaintBoundary(
                child: widget.localPath != null 
                  ? Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, url, error) => const Icon(Icons.image_not_supported, color: AppColors.primaryScheme))
                  : CachedNetworkImage(
                      imageUrl: imagePath,
                      cacheManager: getIt<FilmImageCacheService>().instance,
                      fit: BoxFit.fill,
                      placeholder: (context, url) => Skeletonizer(
                        enabled: true,
                        effect: const ShimmerEffect(
                          baseColor: AppColors.primaryThemeBlack,
                          highlightColor: AppColors.primaryThemeGrey,
                          duration: Duration(seconds: 4),
                        ),
                        child: Container(
                          color: AppColors.primaryThemeGrey,
                          width: 200,
                          height: 100,
                        )
                      ),
                    errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, color: AppColors.primaryScheme),
                  ),
                ),
              ),
                ),
          ),
      );
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = MediaQuery.of(context).size;
        final aspectRatio = screenSize.height / screenSize.width;
        double initialSize;
 
        if (aspectRatio > 1.7) {
          initialSize = 0.28;
        } 
        else if (context.screenHeight < 800) {
          initialSize = 0.45;
        } 
        else {
          initialSize = 0.35;
        }
    
        initialSize = initialSize.clamp(0.3, 0.5);
 
        return DraggableScrollableSheet(
          expand: false,
          minChildSize: 0.3,
          maxChildSize: 0.6,
          initialChildSize: initialSize,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                color: AppColors.primaryThemeBlack
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 8, bottom: 6),
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.primaryThemeGrey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text("Оценить", style: CustomTextStyles.m3Title()),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 80,
                    child: PageView.builder(
                      controller: _controller,
                      physics: BouncingScrollPhysics(),
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
                              child: Text(
                                "$value",
                                style: TextStyle(
                                  fontSize: 50,
                                  fontWeight: FontWeight.bold,
                                  color: value == selectedRating
                                      ? AppColors.primaryScheme
                                      : AppColors.secondaryThemeGrey,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ElevatedButton(
                      style: ButtonStyle(
                          minimumSize: WidgetStatePropertyAll(Size(double.infinity, 40)),
                          alignment: AlignmentGeometry.center,
                          backgroundColor: WidgetStatePropertyAll(AppColors.primaryScheme)),
                      onPressed: () {
                        context.read<FilmInformationBloc>().add(
                          UpdateUserFilmInformation(userRating: selectedRating)
                        );
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Поставить оценку", 
                        style: CustomTextStyles.m3ActionText(color: AppColors.textWhite)
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      } 
    );
  }
}
 
class _CollectionPickerSheet extends StatelessWidget {
  const _CollectionPickerSheet();
 
  @override
  Widget build(BuildContext context) {
 
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 8, bottom: 6),
                      width: 50,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primaryThemeGrey,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text("Добавить в коллекцию", style: CustomTextStyles.m3Title()),
                    const SizedBox(height: 20),
                    Flexible(
                      child: BlocBuilder<FilmInformationBloc, FilmInformationState>(
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
                                collectionsIds: collectionIds,
                                collections: collections);
                          });
                        },
                      ),
                    ),
                  ],
              ),
    );
        }
  }
 
class _CollectionsList extends StatelessWidget {
  final List<String> collectionsIds;
  final List<CollectionEntity> collections;
 
  const _CollectionsList(
      {required this.collectionsIds,
      required this.collections});
 
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        itemCount: collections.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _CreateCollectionTile();
          }
          final collection = collections[index - 1];
          final isInCollection = collectionsIds.contains(collection.id);
          return _CollectionTile(
              collection: collection, isInCollection: isInCollection);
        });
  }
}
 
class _CreateCollectionTile extends StatelessWidget {
  const _CreateCollectionTile();
 
  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Icon(Icons.add, color: AppColors.primaryScheme),
        title: Text("Создать новую коллекцию", style: CustomTextStyles.m3ActionText().copyWith(fontWeight: FontWeight.w600)),
        splashColor: AppColors.primaryThemeGrey,
        onTap: () => showDialog(
            context: context,
            builder: (dialogContext) {
              return BlocProvider.value(
                value: context.read<CollectionsBloc>(),
                child: TextFieldAlertDialog(
                  titleText: 'Новая коллекция', 
                  hintText: 'Придумайте название', 
                  actionText: "Сохранить", 
                  actionFunc: (controllerText) => context.read<CollectionsBloc>().add(AddNewCollection(collectionName: controllerText))
                ),
              );
            }));
  }
}
 
class _CollectionTile extends StatelessWidget {
  final CollectionEntity collection;
  final bool isInCollection;
 
  const _CollectionTile({required this.collection, required this.isInCollection});
 
  @override
  Widget build(BuildContext context) {
    final state = context.read<FilmInformationBloc>().state as FilmLoaded;
    final isLoadingThisCollection = state.loadingCollectionId == collection.id;
    final isSavingAnyCollection = state.loadingCollectionId != null;
 
    return ListTile(
      title: Text(collection.name ?? "Без названия", style: CustomTextStyles.m3ActionText().copyWith(fontWeight: FontWeight.w600)),
      splashColor: AppColors.primaryThemeGrey,
      enabled: !isSavingAnyCollection || isLoadingThisCollection,
      trailing: isLoadingThisCollection
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator())
          : Icon(
              isInCollection ? Icons.check_box : Icons.add,
              color: (isSavingAnyCollection && !isLoadingThisCollection)
                  ? AppColors.primaryThemeGrey
                  : AppColors.primaryScheme,
            ),
      onTap: isSavingAnyCollection
          ? null
          : () {
              if (isInCollection) {
                context.read<FilmInformationBloc>().add(
                    RemoveFilmFromCollection(collectionId: collection.id!));
              } else {
                context
                    .read<FilmInformationBloc>()
                    .add(AddFilmToCollection(collectionId: collection.id!));
              }
            },
    );
  }
}

