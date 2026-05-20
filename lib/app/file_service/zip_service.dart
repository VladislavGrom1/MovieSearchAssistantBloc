import 'dart:io';
import 'package:archive/archive.dart';
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

  Future<String> _zipFilesIsolate(Map<String, dynamic> args) async {
    final root = args["root"];
    final files = List<String>.from(args["files"]);

    final archive = Archive();

    for (final path in files) {
      final file = File(path);
      final bytes = file.readAsBytesSync();

      final relativePath = p.relative(path, from: root);

      archive.addFile(
        ArchiveFile(relativePath, bytes.length, bytes),
      );
    }

    final zipData = ZipEncoder().encode(archive);

    final date = DateTime.now();

    final tempDir = Directory.systemTemp.createTempSync();
    final zipPath = p.join(tempDir.path, "FilmLibrary_${date.day}_${date.month}_${date.year}_${date.hour}${date.minute}${date.second}.zip");

    File(zipPath).writeAsBytesSync(zipData);

    return zipPath;
  }
}