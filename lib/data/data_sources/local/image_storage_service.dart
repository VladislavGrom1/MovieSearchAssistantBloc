import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/exception_mapper.dart';
import 'package:movie_search_assistant_bloc/app/exceptions/remote_data_source_exception.dart';
import 'package:path_provider/path_provider.dart';

class ImageStorageService {
  final Dio _dio = Dio();

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

  Future<String?> _savePoster(String url, int filmId) async {
    try{
      final dir = await _getFilmDir(filmId);
      final filePath = '${dir.path}/poster.jpg';

      final result = await _downloadAndSaveImage(url, filePath, true);

      return result != null ? "$filmId/poster.jpg" : null;
    } on RemoteDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }
  } 

  Future<List<String>> _saveScreenshots(List<String> urls, int filmId) async {
    try{
      final dir = await _getFilmDir(filmId);

      final limitedUrls = urls.take(3).toList();

      final futures = List.generate(limitedUrls.length, (i) async {
        final filePath = '${dir.path}/screenshot_$i.jpg';

        final result = await _downloadAndSaveImage(
          limitedUrls[i],
          filePath,
          false,
        );

        if (result != null) {
          return "$filmId/screenshot_$i.jpg";
        }
        return null;
      });

      final results = await Future.wait(futures);
      return results.whereType<String>().toList();
    } on RemoteDataSourceException {
      rethrow;
    } catch(e){
      rethrow;
    }
  }

  Future<String?> _downloadAndSaveImage(String url, String filePath, bool isPoster) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      final originalBytes = response.data;

      if (originalBytes == null) return null;

      final compressedBytes = await _compressImage(originalBytes, isPoster: isPoster);

      final file = File(filePath);
      await file.writeAsBytes(compressedBytes);

      return file.path;
    } on DioException catch(e){
      if(e.response?.statusCode == 404){
        return null;
      }
      throw ExceptionMapper.mapDioException(e);
    } catch (e) {
      return null;
    }
  }

  Future<(String?, List<String>?)> saveFilmImagesInDirectory(String? posterUrl, List<String>? screenshotUrls, int filmId) async {
    try {
      final posterFuture = posterUrl != null
          ? _savePoster(posterUrl, filmId)
          : Future.value(null);

      final screenshotsFuture = screenshotUrls != null
          ? _saveScreenshots(screenshotUrls, filmId)
          : Future.value(null);

      final results = await Future.wait([
        posterFuture,
        screenshotsFuture,
      ]);

      return (
        results[0] as String?,
        results[1] as List<String>?,
      );
    } on RemoteDataSourceException {
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

  Future<void> deleteAllFilmImages() async {
    try {
      final baseDir = await getApplicationDocumentsDirectory();
      final filmsDir = Directory('${baseDir.path}/films');
      
      if (await filmsDir.exists()) {
        await filmsDir.delete(recursive: true);
      }
    } catch(e) {
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

  Future<Uint8List> _compressImage(Uint8List bytes, {bool isPoster = false}) async {
    return await FlutterImageCompress.compressWithList(
      bytes,
      quality: isPoster ? 80 : 60,
      minWidth: isPoster ? 600 : 800,
      minHeight: isPoster ? 900 : 800,
    );
  }
}