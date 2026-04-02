import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class ImageStorageService {
  Future<Directory> _getFilmDir(int filmId) async {
    try{
      final baseDir = await getApplicationDocumentsDirectory();
      final filmDir = Directory('${baseDir.path}/films/$filmId');

      if (!await filmDir.exists()) {
        await filmDir.create(recursive: true);
      }

      return filmDir;
    } catch(e){
      rethrow;
    }
  }

  Future<String> _savePoster(String url, int filmId) async {
    try{
      final dir = await _getFilmDir(filmId);
      final filePath = '${dir.path}/poster.jpg';
      await _downloadAndSaveImage(url, filePath);
      return "$filmId/poster.jpg";
    } catch(e){
      rethrow;
    }
  }

  Future<List<String>> _saveScreenshots(List<String> urls, int filmId) async {
    final dir = await _getFilmDir(filmId);

    final paths = <String>[];

    for (int i = 0; i < urls.length; i++) {
      final filePath = '${dir.path}/screenshot_$i.jpg';

      await _downloadAndSaveImage(urls[i], filePath);

      paths.add("$filmId/screenshot_$i.jpg");
    }

    return paths;
  }

  Future<String> _downloadAndSaveImage(String url, String filePath) async {
    final response = await Dio().get(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    final file = File(filePath);
    await file.writeAsBytes(response.data);
    return file.path;
  }

  Future<(String?, List<String>?)> saveFilmImagesInDirectory(String? posterUrl, List<String>? screenshotUrls, int filmId) async {
    try{
      final posterImagePath = posterUrl != null ? await _savePoster(posterUrl, filmId) : null;
      final screenshotPaths = screenshotUrls != null ? await _saveScreenshots(screenshotUrls, filmId) : null;
      return (posterImagePath, screenshotPaths);
    } catch(e){
      rethrow;
    }
  } 

  Future<String> getFullImagePath(String relativePath) async {
    final baseDir = await getApplicationDocumentsDirectory();
    return "${baseDir.path}/films/$relativePath";
  }

  Future<void> deleteFilmImages(int filmId) async {
    try{
      final dir = await _getFilmDir(filmId);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch(e){
      rethrow;
    }
  }

  Future<void> copyAllImagesTo(String destinationPath) async {
    final baseDir = await getApplicationDocumentsDirectory();
    final filmsDir = Directory('${baseDir.path}/films');

    if (!await filmsDir.exists()) return;

    final filmFolders = filmsDir.listSync();

    for (final entity in filmFolders) {
      if (entity is Directory) {
        final filmId = entity.path.split('/').last;

        final newDir = Directory('$destinationPath/$filmId');
        await newDir.create(recursive: true);

        for (final file in entity.listSync()) {
          if (file is File) {
            final newPath = '${newDir.path}/${file.uri.pathSegments.last}';
            await file.copy(newPath);
          }
        }
      }
    }
  }
}