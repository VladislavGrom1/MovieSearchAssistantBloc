import 'dart:developer';

import 'package:media_store_plus/media_store_plus.dart';
import 'package:movie_search_assistant_bloc/app/file_service/export_destination_service.dart';

class AndroidExportDestinationService implements ExportDestinationService {
  final MediaStore mediaStore;

  AndroidExportDestinationService({required this.mediaStore});
  
  
  @override
  Future<String> saveZip({
    required String zipPath,
    required String fileName,
  }) async {
    final saveInfo = await mediaStore.saveFile(
      tempFilePath: zipPath,
      dirType: DirType.download,
      dirName: DirName.download,
    );

    log("saveInfo: $saveInfo");

    if (saveInfo != null) {
      log("Saved URI: ${saveInfo.uri}");
      return saveInfo.uri.toString();
    }

    final exists = await mediaStore.isFileExist(
      fileName: fileName,
      dirType: DirType.download,
      dirName: DirName.download,
    );

    if (exists) {
      final uri = await mediaStore.getFileUri(
        fileName: fileName,
        dirType: DirType.download,
        dirName: DirName.download,
      );
      if (uri != null) {
        log("Recovered URI: $uri");
        return uri.toString();
      }
    }

    throw Exception("MediaStore не смог подтвердить сохранение файла");
  }
}