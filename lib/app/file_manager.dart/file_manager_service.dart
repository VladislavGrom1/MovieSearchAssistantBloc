import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';


class FileManagerService {

  static Future<String?> saveFile(Uint8List fileBytes, String fileName) async {
    final filePath = await FilePicker.platform.saveFile(
      dialogTitle: "Сохранить архив",
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['zip'],
      bytes: fileBytes,
    );

    if (filePath == null) {
      return null;
    }

    return filePath;
  }

  static Future<File?> pickZipFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result == null || result.files.single.path == null) {
      return null;
    }

    return File(result.files.single.path!);
  }
}

  // static Future<String> shareZip(File zipFile) async {
  //   final shareResult = await SharePlus.instance.share(
  //     ShareParams(
  //       files: [XFile(zipFile.path)],
  //       text: "Экспорт библиотеки фильмов",
  //       subject: "Film Library Backup",
  //     ),
  //   );
  //   return shareResult.raw;
  // }
  