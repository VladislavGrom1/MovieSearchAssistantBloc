import 'package:movie_search_assistant_bloc/domain/entities/ai_session.dart';
import 'package:movie_search_assistant_bloc/domain/repository/ai_session_repository.dart';

class GetAiSessionsUseCase {
  final AiSessionRepository aiSessionRepository;

  const GetAiSessionsUseCase({required this.aiSessionRepository});

  Future<List<AiSession>> call() => aiSessionRepository.getSessions();
}
