import 'package:equatable/equatable.dart';

sealed class AiAssistantEvent extends Equatable {
  const AiAssistantEvent();

  @override
  List<Object?> get props => [];
}

/// Пользователь отправил запрос в поле ввода.
///
/// [onlyNew] — положение переключателя «Только новое» на момент отправки;
/// блок запоминает его в самом поиске.
final class AiAssistantRequested extends AiAssistantEvent {
  final String query;
  final bool onlyNew;

  const AiAssistantRequested(this.query, {this.onlyNew = false});

  @override
  List<Object?> get props => [query, onlyNew];
}

/// Пользователь попросил повторить неудавшийся AI-поиск.
final class AiAssistantRetryRequested extends AiAssistantEvent {
  final int searchId;

  const AiAssistantRetryRequested(this.searchId);

  @override
  List<Object?> get props => [searchId];
}

/// Пользователь раскрыл более ранний AI-поиск в ленте.
final class AiAssistantSearchExpanded extends AiAssistantEvent {
  final int searchId;

  const AiAssistantSearchExpanded(this.searchId);

  @override
  List<Object?> get props => [searchId];
}
