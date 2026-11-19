import 'package:equatable/equatable.dart';

/// Один AI-поиск: что пользователь спросил, в каком режиме и когда.
///
/// Сущность описывает только сам запрос. В каком состоянии он находится
/// (идёт загрузка, пришли фильмы, ничего не нашлось, ошибка) — это состояние
/// BLoC, оно живёт в `AiFilmSearchState`.
class AiFilmSearch extends Equatable {
  final int id;
  final String query;

  /// Режим «Только новое» на момент отправки: не рекомендовать фильмы,
  /// которые уже сохранены в библиотеку. Снимок, а не живая настройка экрана:
  /// поиск всегда воспроизводится в том режиме, в котором был отправлен.
  final bool onlyNew;

  final DateTime createdAt;

  const AiFilmSearch({
    required this.id,
    required this.query,
    required this.createdAt,
    this.onlyNew = false,
  });

  @override
  List<Object?> get props => [id, query, onlyNew, createdAt];
}
