import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/injection_container.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/film_information/film_information_bloc.dart';
import 'package:movie_search_assistant_bloc/presentation/pages/film_information/widgets/film_information_widget.dart';

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
              if (state is FilmInformatinonLoading) {
                return Center(child: CircularProgressIndicator());
              }

              if (state is FilmInformationLoadedFailure) {
                return Center(child: Text(state.exceptionType));
              }

              if (state is FilmInformationLoadedSuccessful) {
                final film = state.filmInformation;
                final images = state.filmImages;
                return FilmInformationWidget(film: film, images: images);
              }
              return SizedBox();
            },
          ),
        )));
  }
}
