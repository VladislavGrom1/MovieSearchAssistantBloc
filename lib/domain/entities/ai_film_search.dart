import 'package:equatable/equatable.dart';

class AiFilmSearch extends Equatable {
  final int id;
  final String query;

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
