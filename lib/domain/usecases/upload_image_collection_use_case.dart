import 'package:image_picker/image_picker.dart';
import 'package:movie_search_assistant_bloc/data/data_sources/local/image_storage_service.dart';
import 'package:movie_search_assistant_bloc/domain/entities/collection_entity.dart';
import 'package:movie_search_assistant_bloc/domain/repository/collection_repository.dart';

class UploadImageCollectionUseCase {
  final CollectionRepository collectionRepository;
  final ImageStorageService imageStorageService;

  UploadImageCollectionUseCase({
    required this.collectionRepository,
    required this.imageStorageService,
  });

  Future<void> call(CollectionEntity collection) async {
    ImagePicker imagePicker = ImagePicker();
    final XFile? pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage == null) return;

    final imagePath = await imageStorageService.saveCollectionImage(
      pickedImage.path,
      collection.id!,
    );

    if (imagePath == null) return;

    final updatedCollection = collection.copyWith(imagePath: imagePath);
    await collectionRepository.updateCollection(updatedCollection);
  }
}