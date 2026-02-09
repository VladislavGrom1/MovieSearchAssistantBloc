import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/film_information/film_information_bloc.dart';

@RoutePage()
class FilmInformationScreen extends StatefulWidget {
  const FilmInformationScreen({
    super.key, 
    @PathParam('filmId') required this.filmId,
  });

  final int filmId;

  @override
  State<FilmInformationScreen> createState() => _FilmInformationScreenState();
}

class _FilmInformationScreenState extends State<FilmInformationScreen> {
  final _filmInformationBloc = getIt<FilmInformationBloc>();

  @override
  void initState() {
    super.initState();
    _filmInformationBloc.add(DisplayFilmInformationEvent(idFilm: widget.filmId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _filmInformationBloc.add(DisplayFilmInformationEvent(idFilm: widget.filmId));
          },
          child: BlocBuilder<FilmInformationBloc, FilmInformationState>(
            bloc: _filmInformationBloc,
            builder: (context, state) {
              
              if(state is FilmInformatinonLoading){
                return Center(child: CircularProgressIndicator());
              }
          
              if(state is FilmInformationLoadedFailure){
                return Center(child: Text(state.exceptionType));
              }
          
              if(state is FilmInformationLoadedSuccessful){
                final film = state.filmInformation;
                final titleText = film.nameRu ?? film.nameOriginal ?? "Название отсутствует";
                return CustomScrollView(
                  slivers: [
                    SliverList.list(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20.w, right: 20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(titleText),
                              SizedBox(height: 10.h),
                              Text(film.nameOriginal.toString()),
                              SizedBox(height: 10.h),
                              Text("${film.startYear} - ${film.endYear} - ${film.year}"),
                              SizedBox(height: 10.h),
                              Text(film.countries.toString()),
                              SizedBox(height: 10.h),
                              Text(film.genres.toString()),
                              SizedBox(height: 10.h),
                              Text(film.description.toString()),
                              SizedBox(height: 10.h),
                              Text(film.slogan.toString()),
                              SizedBox(height: 10.h),
                              Row(
                                children: [
                                  Text(film.ratingKinopoisk.toString()),
                                  SizedBox(height: 5.w),
                                  Text(film.ratingKinopoiskVoteCount.toString()),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              Row(
                                children: [
                                  Text(film.ratingImdb.toString()),
                                  SizedBox(height: 5.w),
                                  Text(film.ratingImdbVoteCount.toString()),
                                ],
                              ),
                              SizedBox(height: 10.h),
                            ]
                          )
                        )
                      ] 
                    ),
                  ]
                );
              }
              return SizedBox();
            },
          ),
        )
      )
    );
  }
}