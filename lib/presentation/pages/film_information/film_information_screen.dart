import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_entity.dart';
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

  void onSavePressed(FilmEntity film){
    _filmInformationBloc.add(SaveFilmEvent(film: film));
  }

  void onRemovePressed(FilmEntity film){
    _filmInformationBloc.add(RemoveFilmEvent(film: film));
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
          child: BlocConsumer<FilmInformationBloc, FilmInformationState>(
              bloc: _filmInformationBloc,
              listener: (BuildContext context, FilmInformationState state) {
                // TODO: Реализовать Toast при изменении статуса фильма (Сохранён/Удалён)

                // if(state is FilmSavedSuccesful){
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(
                //       content: Text("Фильм сохранён успешно"),
                //       backgroundColor: Colors.green,
                //     ),
                //   );
                // }
                // if(state is FilmSavedFailure){
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(
                //       content: Text("Фильм не удалось сохранить"),
                //       backgroundColor: Colors.red,
                //     ),
                //   );
                // }
              },
              builder: (context, state) {
                if (state is FilmInformatinonLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (state is FilmInformationLoadedFailure) {
                  return Center(child: Text(state.exceptionType));
                }

                if (state is FilmInformationLoaded) {
                  final film = state.filmInformation;
                  final images = state.filmImages;
                  return FilmInformationWidget(
                    film: film, 
                    images: images, 
                    onSavePressed: () => onSavePressed(film),
                    onRemovePressed: () => onRemovePressed(film),
                  );
                }
                return SizedBox();
              },
            ),
          ),
        ));
  }
}
