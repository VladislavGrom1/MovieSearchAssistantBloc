import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:movie_search_assistant_bloc/app/util/constants/app_config.dart';
import 'package:path/path.dart' as p;
 
class ImportDataMigrator {
  static const int currentLocalStorageVersion = AppConfig.LOCAL_STORAGE_VERSION;
  static const String versionKey = 'version';
 
  Future<Map<String, dynamic>> migrate(
    Map<String, dynamic> jsonData,
    Directory extractDir,
  ) async {
    final sourceVersion = jsonData[versionKey] as int? ?? 1;
    final migratedJson = _migrateJsonData(jsonData, sourceVersion);

    if (sourceVersion < currentLocalStorageVersion) {
      await compute(_migrateFileStructureIsolate, extractDir.path);
    }
 
    return migratedJson;
  }
 
  Map<String, dynamic> _migrateJsonData(Map<String, dynamic> jsonData, int version) {
    if (version > currentLocalStorageVersion) {
      throw Exception('Архив создан в более новой версии приложения.');
    }
 
    if (version == currentLocalStorageVersion) return jsonData;
 
    Map<String, dynamic> result = jsonData;
 
    if (version < 2) result = _upgradeFromV1ToV2(result);
 
    return result;
  }
 
  static Future<void> _migrateFileStructureIsolate(String extractDirPath) async {
    final extractDir = Directory(extractDirPath);
    final imagesDir = Directory(p.join(extractDir.path, "images"));
    if (!await imagesDir.exists()) return;
 
    final filmsDir = Directory(p.join(imagesDir.path, "films"));
    if (await filmsDir.exists()) return;
 
    final tmpDir = Directory(p.join(imagesDir.path, ".films_tmp"));
    if (await tmpDir.exists()) {
      await tmpDir.delete(recursive: true);
    }
    await tmpDir.create(recursive: true);
 
    final entities = imagesDir.listSync().whereType<Directory>().toList();
 
    for (final entityDir in entities) {
      final entityName = p.basename(entityDir.path);
      if (entityName == "collections") continue;
      if (entityName.startsWith('.')) continue;
      if (int.tryParse(entityName) == null) continue;
 
      final newPath = p.join(tmpDir.path, entityName);
      try {
        await entityDir.rename(newPath);
      } catch (e) {
        debugPrint("Fallback to copy for $entityName due to: $e");
        await _copyDirectory(entityDir, Directory(newPath));
        await entityDir.delete(recursive: true);
      }
    }
 
    await tmpDir.rename(filmsDir.path);
  }
 
  Map<String, dynamic> _upgradeFromV1ToV2(Map<String, dynamic> jsonData) {
    final upgraded = Map<String, dynamic>.from(jsonData);
    upgraded[versionKey] = currentLocalStorageVersion;
 
    if (upgraded['films'] is List) {
      upgraded['films'] = (upgraded['films'] as List)
          .whereType<Map<String, dynamic>>()
          .map(_upgradeFilmPaths)
          .toList();
    }
 
    if (upgraded['collections'] is List) {
      upgraded['collections'] = (upgraded['collections'] as List)
          .whereType<Map<String, dynamic>>()
          .map((c) {
            final map = Map<String, dynamic>.from(c);
            if (!map.containsKey('imagePath')) map['imagePath'] = null;
            return map;
          })
          .toList();
    }
    return upgraded;
  }
 
  Map<String, dynamic> _upgradeFilmPaths(Map<String, dynamic> film) {
    final upgraded = Map<String, dynamic>.from(film);
    final baseModel = upgraded['filmBaseModel'];
 
    if (baseModel is Map<String, dynamic>) {
      final filmId = baseModel['kinopoiskId']?.toString();
      if (filmId != null) {
        if (baseModel['localPosterImagePath'] != null) {
          baseModel['localPosterImagePath'] = "$filmId/poster.jpg";
        }
        if (baseModel['localScreenshotPaths'] is List) {
          final count = (baseModel['localScreenshotPaths'] as List).length;
          baseModel['localScreenshotPaths'] = List.generate(
            count, (i) => "$filmId/screenshot_$i.jpg",
          );
        }
      }
      upgraded['filmBaseModel'] = baseModel;
    }
    return upgraded;
  }
 
  static Future<void> _copyDirectory(Directory source, Directory destination) async {
    await destination.create(recursive: true);
    await for (final entity in source.list()) {
      if (entity is File) {
        await entity.copy(p.join(destination.path, p.basename(entity.path)));
      } else if (entity is Directory) {
        await _copyDirectory(entity, Directory(p.join(destination.path, p.basename(entity.path))));
      }
    }
  }
}