import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/library/library_bloc.dart';

@RoutePage()
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _libraryBloc = getIt<LibraryBloc>();

  @override
  void initState() {
    super.initState();
    _libraryBloc.add(DisplaySavedFilms());
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Библиотека", style: TextStyle(
            color: Colors.white,
            overflow: TextOverflow.ellipsis
        )),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.only(left: 20.w, right: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: BlocBuilder<LibraryBloc, LibraryState>(
                  bloc: _libraryBloc,
                  builder: (context, state) {
                    if(state is SavedFilmsLoading){
                      return Center(child: CircularProgressIndicator());
                    }

                    if(state is SavedFilmsLoadedFailure){
                      return Center(child: Text("${state.exceptionType} ${state.statusCode}"));
                    }

                    if(state is SavedFilmsLoadedSuccessful){
                      return _buildSavedFilms(state);
                    }

                    return SizedBox();
                  }
                )
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavedFilms(SavedFilmsLoadedSuccessful state){
    final savedFilms = state.savedFilms;

    return ListView.separated(
      itemBuilder: (context, index) {
        final savedFilm = savedFilms[index];

        return InkWell(
            onTap: () {
              if(savedFilm.kinopoiskId != null){
                context.router.push(FilmInformationRoute(filmId: savedFilm.kinopoiskId!));
              } else{
                // TODO: Реализовать отображение Toast
                log("kinoposikId == null");
              }
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
                    child:
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: 5.h),
                            Text(
                              savedFilm.nameRu == null 
                              ? savedFilm.nameOriginal.toString() 
                              : savedFilm.nameRu.toString(), 
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2),
                            SizedBox(height: 10.h),
                            Text(
                              savedFilm.nameOriginal == null 
                              ? "-" 
                              : savedFilm.nameOriginal.toString(),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              savedFilm.countries!.isEmpty 
                              ? "${savedFilm.year}" 
                              : "${savedFilm.countries.toString()}, ${savedFilm.year}",
                            ),
                            SizedBox(height: 10.h),
                          ]
                        ),
                    ),
                    PopupMenuButton(
                          icon: Icon(Icons.more_vert, color: Colors.purple),
                          onSelected: (value) {
                            switch(value){
                              case("addFilmInCollection"): {

                              }
                              case("removeFilmFromLibrary"): {
                                _libraryBloc.add(RemoveFilmFromLibrary(savedFilms: savedFilms, film: savedFilm));
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'addFilmInCollection',
                              child: Text("Добавить в коллекцию")
                            ),
                            PopupMenuItem(
                              value: 'removeFilmFromLibrary',
                              child: Text("Удалить из библиотеки")
                            )
                          ]
                        )
                ],
              ),
            ),
          );
      }, 
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemCount: state.savedFilms.length
    );
  }
}