import 'package:movie_search_assistant_bloc/domain/entities/ai_session.dart';

abstract class AiSessionRepository {
  Future<List<AiSession>> getSessions();

  Future<void> saveSession(AiSession session);

  Future<void> deleteSession(int sessionId);

  Future<void> clearSessions();
}
