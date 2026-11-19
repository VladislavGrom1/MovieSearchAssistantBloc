import 'package:equatable/equatable.dart';

sealed class AiAssistantEvent extends Equatable {
  const AiAssistantEvent();

  @override
  List<Object?> get props => [];
}

/// Экран AI-Ассистента открылся: пора поднять сохранённые сессии из Hive.
final class AiAssistantHistoryRequested extends AiAssistantEvent {
  const AiAssistantHistoryRequested();
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

/// Пользователь удалил одну сессию через меню карточки.
final class AiAssistantSessionDeleteRequested extends AiAssistantEvent {
  final int sessionId;

  const AiAssistantSessionDeleteRequested(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

/// Пользователь очистил все сессии AI-Ассистента.
final class AiAssistantSessionsClearRequested extends AiAssistantEvent {
  const AiAssistantSessionsClearRequested();
}
