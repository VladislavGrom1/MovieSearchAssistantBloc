import 'package:movie_search_assistant_bloc/domain/entities/ai_session.dart';
import 'package:movie_search_assistant_bloc/domain/repository/ai_session_repository.dart';

class SaveAiSessionUseCase {
  final AiSessionRepository aiSessionRepository;

  const SaveAiSessionUseCase({required this.aiSessionRepository});

  Future<void> call(AiSession session) =>
      aiSessionRepository.saveSession(session);
}
