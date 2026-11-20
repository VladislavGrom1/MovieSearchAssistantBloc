import 'package:equatable/equatable.dart';

sealed class AiAssistantEvent extends Equatable {
  const AiAssistantEvent();

  @override
  List<Object?> get props => [];
}

final class AiAssistantHistoryRequested extends AiAssistantEvent {
  const AiAssistantHistoryRequested();
}

final class AiAssistantRequested extends AiAssistantEvent {
  final String query;
  final bool onlyNew;

  const AiAssistantRequested(this.query, {this.onlyNew = false});

  @override
  List<Object?> get props => [query, onlyNew];
}

final class AiAssistantRetryRequested extends AiAssistantEvent {
  final int searchId;

  const AiAssistantRetryRequested(this.searchId);

  @override
  List<Object?> get props => [searchId];
}

final class AiAssistantSearchExpanded extends AiAssistantEvent {
  final int searchId;

  const AiAssistantSearchExpanded(this.searchId);

  @override
  List<Object?> get props => [searchId];
}

final class AiAssistantSessionDeleteRequested extends AiAssistantEvent {
  final int sessionId;

  const AiAssistantSessionDeleteRequested(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

final class AiAssistantSessionsClearRequested extends AiAssistantEvent {
  const AiAssistantSessionsClearRequested();
}
