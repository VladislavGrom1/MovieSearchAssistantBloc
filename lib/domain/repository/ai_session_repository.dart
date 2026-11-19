import 'package:movie_search_assistant_bloc/domain/entities/ai_session.dart';

/// История сессий AI-Ассистента.
///
/// Сессии лежат отдельно от библиотеки фильмов: в экспорт библиотеки не
/// попадают и `ClearLibraryUseCase` их не трогает.
abstract class AiSessionRepository {
  Future<List<AiSession>> getSessions();

  /// Сохраняет сессию вместе с постерами и вытесняет самую старую, если
  /// сессий стало больше лимита.
  Future<void> saveSession(AiSession session);

  /// Удаляет сессию вместе с папкой постеров.
  Future<void> deleteSession(int sessionId);

  /// Удаляет все сессии и папку с их постерами.
  Future<void> clearSessions();
}
