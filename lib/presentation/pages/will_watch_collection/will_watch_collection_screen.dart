import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/app/router/app_router.gr.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/will_watch_collection/will_watch_collection_bloc.dart';

@RoutePage()
class WillWatchCollectionScreen extends StatefulWidget {
  const WillWatchCollectionScreen({super.key});

  @override
  State<WillWatchCollectionScreen> createState() => _WillWatchCollectionScreenState();
}

class _WillWatchCollectionScreenState extends State<WillWatchCollectionScreen> {
  final _willWatchCollectionBloc = getIt<WillWatchCollectionBloc>();

  @override
  void initState() {
    super.initState();
    _willWatchCollectionBloc.add(DisplaySavedFilms());
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Буду смотреть", style: TextStyle(
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
                child: BlocBuilder<WillWatchCollectionBloc, WillWatchCollectionState>(
                  bloc: _willWatchCollectionBloc,
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
              if(savedFilm.filmBaseModel.kinopoiskId != null){
                context.router.push(FilmInformationRoute(filmId: savedFilm.filmBaseModel.kinopoiskId!));
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 5.h),
                        Text(
                          savedFilm.filmBaseModel.nameRu == null 
                          ? savedFilm.filmBaseModel.nameOriginal.toString() 
                          : savedFilm.filmBaseModel.nameRu.toString(), 
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2),
                        SizedBox(height: 10.h),
                        Text(
                          savedFilm.filmBaseModel.nameOriginal == null 
                          ? "-" 
                          : savedFilm.filmBaseModel.nameOriginal.toString(),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          savedFilm.filmBaseModel.countries!.isEmpty 
                          ? "${savedFilm.filmBaseModel.year}" 
                          : "${savedFilm.filmBaseModel.countries.toString()}, ${savedFilm.filmBaseModel.year}",
                        ),
                        SizedBox(height: 10.h),
                      ]
                    ),
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