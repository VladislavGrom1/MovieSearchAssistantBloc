import 'dart:developer';
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
      final path = await _downloadAndSaveImage(url, filePath);
      return path;
    } catch(e){
      rethrow;
    }
  }

  Future<List<String>> _saveScreenshots(List<String> urls, int filmId) async {
    try {
      final dir = await _getFilmDir(filmId);
      
      final futures = <Future<String>>[];
      for (int i = 0; i < urls.length; i++) {
        futures.add(_downloadAndSaveImage(urls[i], '${dir.path}/screenshot_$i.jpg'));
      }
      
      final paths = await Future.wait(futures);
      return paths;
    } catch (e) {
      rethrow;
    }
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

  Future<void> deleteFilmImages(int filmId) async {
    try{
      final dir = await _getFilmDir(filmId);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
      log("Удалена директория фильма: $dir");
    } catch(e){
      rethrow;
    }
  }
}