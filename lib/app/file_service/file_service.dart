import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';


class FileService {

  Future<String?> saveFile(Uint8List fileBytes, String fileName) async {
    final filePath = await FilePicker.saveFile(
      dialogTitle: "Сохранить архив",
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['zip'],
      bytes: fileBytes,
    );

    if (filePath == null) {
      return null;
    }

    return filePath.toString();
  }

  Future<File?> pickZipFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result.single.path == null) {
      return null;
    }

    return File(result.single.path!);
  }

  Future<File?> pickJsonFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json']
    );

    if (result.single.path == null) {
      return null;
    }

    return File(result.single.path!);
  }

  Future<String> shareZip(File zipFile) async {
    final path = await SharePlus.instance.share(
      ShareParams(
        files: [XFile(zipFile.path)],
      ),
    );
    return path.raw;
  }
}

  
  