import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
 
class ZipService {
 
  Future<String> zipDirectory(String sourceDirPath) async {
    final dir = Directory(sourceDirPath);
    final files = dir.listSync(recursive: true)
        .whereType<File>()
        .map((f) => f.path)
        .toList();
 
    return compute(_zipFilesIsolate, {
      "root": sourceDirPath,
      "files": files,
    });
  }
 
  Future<void> unzipToDirectory(String zipPath, String destinationPath) {
    return compute(_unzipFilesIsolate, {
      "zipPath": zipPath,
      "destination": destinationPath,
    });
  }
 
  static String _zipFilesIsolate(Map<String, dynamic> args) {
    final root = args["root"] as String;
    final files = List<String>.from(args["files"]);
 
    final date = DateTime.now();
    final tempDir = Directory.systemTemp.createTempSync();
    final zipPath = p.join(
      tempDir.path,
      "FilmLibrary_${date.day}_${date.month}_${date.year}_${date.hour}${date.minute}${date.second}.zip",
    );
 
    final encoder = ZipFileEncoder();
    encoder.create(zipPath);
 
    try {
      for (final path in files) {
        final relativePath = p.relative(path, from: root);
        encoder.addFileSync(File(path), relativePath);
      }
    } finally {
      encoder.closeSync();
    }
 
    return zipPath;
  }
 
  static Future<void> _unzipFilesIsolate(Map<String, dynamic> args) async {
    final zipPath = args["zipPath"] as String;
    final destination = args["destination"] as String;
    final normalizedRoot = p.normalize(destination);
 
    final inputStream = InputFileStream(zipPath);
 
    try {
      final archive = ZipDecoder().decodeStream(inputStream);
 
      for (final file in archive) {
        final filePath = p.normalize(p.join(destination, file.name));
 
        if (!p.isWithin(normalizedRoot, filePath)) {
          throw Exception("Некорректный путь в архиве: ${file.name}");
        }
 
        if (file.isFile) {
          final outputStream = OutputFileStream(filePath);
          try {
            file.writeContent(outputStream);
          } finally {
            await outputStream.close();
          }
        } else {
          await Directory(filePath).create(recursive: true);
        }
      }
    } finally {
      await inputStream.close();
    }
  }
}