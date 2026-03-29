import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_assistant_bloc/domain/usecases/watch_links_use_case.dart';


class WatchFilmCollectionLinksCubit extends Cubit<Set<int>> {  
  final WatchLinksUseCase watchLinksUseCase;
  StreamSubscription? _linksSubscription;

  WatchFilmCollectionLinksCubit(this.watchLinksUseCase) : super({}) {
    _linksSubscription = watchLinksUseCase().listen((links) {
      final filmIds = links.map((e) => e.filmId).toSet();
      emit(filmIds);
    });
  }

  @override
  Future<void> close() {
    _linksSubscription?.cancel();
    return super.close();
  }
}
