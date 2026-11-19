import 'package:movie_search_assistant_bloc/domain/repository/ai_session_repository.dart';

class DeleteAiSessionUseCase {
  final AiSessionRepository aiSessionRepository;

  const DeleteAiSessionUseCase({required this.aiSessionRepository});

  Future<void> call(int sessionId) =>
      aiSessionRepository.deleteSession(sessionId);
}
