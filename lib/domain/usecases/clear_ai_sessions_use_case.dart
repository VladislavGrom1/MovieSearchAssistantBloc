import 'package:movie_search_assistant_bloc/domain/repository/ai_session_repository.dart';

class ClearAiSessionsUseCase {
  final AiSessionRepository aiSessionRepository;

  const ClearAiSessionsUseCase({required this.aiSessionRepository});

  Future<void> call() => aiSessionRepository.clearSessions();
}
