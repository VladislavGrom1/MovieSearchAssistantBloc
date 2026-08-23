import 'dart:io';

import 'package:movie_search_assistant_bloc/app/file_service/export_destination_service.dart';
import 'package:movie_search_assistant_bloc/app/file_service/file_service.dart';

class IosExportDestinationService implements ExportDestinationService {
  final FileService fileService;

  IosExportDestinationService({required this.fileService});

  @override
  Future<String> saveZip({
    required String zipPath,
    required String fileName,
  }) async {
    final bytes = await File(zipPath).readAsBytes();

    final savedPath = await fileService.saveFile(bytes, fileName);

    if (savedPath == null) {
      throw Exception("Экспорт отменён пользователем");
    }

    return savedPath;
  }
}