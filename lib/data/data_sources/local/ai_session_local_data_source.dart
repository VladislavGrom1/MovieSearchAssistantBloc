import 'package:hive/hive.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/local_data_source_exception.dart';
import 'package:movie_search_assistant_bloc/app/util/constants/hive_storage_keys.dart';
import 'package:movie_search_assistant_bloc/data/models/ai_session_model.dart';

class AiSessionLocalDataSource {
  static const int maxSessions = 20;

  Box<AiSessionModel> get _box =>
      Hive.box<AiSessionModel>(HiveStorageKeys.aiSessionModelBox);

  Future<List<AiSessionModel>> getSessions() async {
    try {
      return _box.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } on HiveError catch (e) {
      throw LocalDataSourceException(message: e.message);
    }
  }

  Future<List<int>> saveSession(AiSessionModel session) async {
    try {
      await _box.put(session.id, session);

      final int overflow = _box.length - maxSessions;
      if (overflow <= 0) {
        return const <int>[];
      }

      final List<AiSessionModel> byUpdatedAt = _box.values.toList()
        ..sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
      final List<int> evictedIds =
          byUpdatedAt.take(overflow).map((session) => session.id).toList();

      for (final int id in evictedIds) {
        await _box.delete(id);
      }

      return evictedIds;
    } on HiveError catch (e) {
      throw LocalDataSourceException(message: e.message);
    }
  }

  Future<void> deleteSession(int id) async {
    try {
      await _box.delete(id);
    } on HiveError catch (e) {
      throw LocalDataSourceException(message: e.message);
    }
  }

  Future<void> deleteAllSessions() async {
    try {
      await _box.clear();
    } on HiveError catch (e) {
      throw LocalDataSourceException(message: e.message);
    }
  }
}
