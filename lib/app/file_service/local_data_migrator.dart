import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:movie_search_assistant_bloc/app/util/constants/app_config.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

class LocalDataMigration {
  static const int currentLocalStorageVersion = AppConfig.LOCAL_STORAGE_VERSION;
  static const String versionFileName = AppConfig.VERSION_FILE_NAME;

  static Future<void> ensureLocalStorageMigrated() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final versionFile = File(p.join(appDir.path, versionFileName));
      
      int currentVersion = 1;
      
      if (await versionFile.exists()) {
        final content = await versionFile.readAsString();
        currentVersion = int.tryParse(content.trim()) ?? 1;
      } else {
        if (await Directory(p.join(appDir.path, "images", "films")).exists()) {
          currentVersion = 2;
        }
      }

      if (currentVersion >= currentLocalStorageVersion) {
        debugPrint("Local storage is up to date (v$currentVersion).");
        return;
      }

      debugPrint("Starting local storage migration from v$currentVersion to v$currentLocalStorageVersion...");
      
      await compute(_performCascadeMigration, {
        'appDirPath': appDir.path,
        'startVersion': currentVersion,
        'targetVersion': currentLocalStorageVersion,
      });
      
      await versionFile.writeAsString(currentLocalStorageVersion.toString());
      debugPrint("Local storage migration completed successfully.");
      
    } catch (e, stackTrace) {
      debugPrint("Critical error during local migration: $e");
      debugPrint("Stack trace: $stackTrace");
    }
  }

  static Future<void> _performCascadeMigration(Map<String, dynamic> args) async {
    final appDirPath = args['appDirPath'] as String;
    final startVersion = args['startVersion'] as int;
    final targetVersion = args['targetVersion'] as int;

    final appDir = Directory(appDirPath);

    if (startVersion < 2 && targetVersion >= 2) {;
      await _migrateV1ToV2(appDir);
    }
  }

  static Future<void> _migrateV1ToV2(Directory appDir) async {
    final imagesDir = Directory(p.join(appDir.path, "images"));
    if (!await imagesDir.exists()) return;

    final filmsDir = Directory(p.join(imagesDir.path, "films"));
    
    if (await filmsDir.exists()) return;

    await filmsDir.create(recursive: true);

    final entities = await imagesDir.list().whereType<Directory>().toList();
    
    for (final entityDir in entities) {
      final dirName = p.basename(entityDir.path);
      
      if (dirName == "films" || dirName == "collections") continue;
      if (int.tryParse(dirName) == null) continue;

      final targetPath = p.join(filmsDir.path, dirName);
      
      try {
        await entityDir.rename(targetPath);
      } catch (e) {
        debugPrint("Rename failed for $dirName, falling back to copy+delete: $e");
        await _copyDirectory(entityDir, Directory(targetPath));
        await entityDir.delete(recursive: true);
      }
    }
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