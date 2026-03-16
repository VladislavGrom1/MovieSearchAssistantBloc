import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/collection_films/collection_films_bloc.dart';

@RoutePage()
class CollectionFilmsScreen extends StatelessWidget {
  const CollectionFilmsScreen({
    super.key,
    @PathParam('collectionId') required this.collectionId,
  });

  final String collectionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => getIt<CollectionFilmsBloc>()..add(GetSavedFilms(collectionId: collectionId)),
        child: _CollectionFilmsView());
  }
}

class _CollectionFilmsView extends StatelessWidget {
  const _CollectionFilmsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
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
              return _CollectionFilmsList(savedFilms: state.savedFilms);
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
  const _CollectionFilmsList({required this.savedFilms});

  @override
  Widget build(BuildContext context) {
    if (savedFilms.isEmpty) {
      return Center(child: Text("Коллекция пуста", style: TextStyle(color: Colors.black)));
    }

    return ListView.separated(
        itemBuilder: (context, index) {
          final savedFilm = savedFilms[index];
          return _FilmCard(savedFilm: savedFilm);
        },
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemCount: savedFilms.length);
  }
}

class _FilmCard extends StatelessWidget {
  final FilmEntity savedFilm;

  const _FilmCard({required this.savedFilm});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: Переход на страницу фильма (Реализовать отрисовку окна используя данные с локального хранилища (сделать в Bloc FilmInformation))
      },
      child: Card(
        color: Colors.grey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140.h,
              width: 100.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.w),
                color: Colors.purple,
              ),
            ),
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
            ))
          ],
        ),
      ),
    );
  }
}
