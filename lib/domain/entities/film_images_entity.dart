import 'package:equatable/equatable.dart';
import 'package:movie_search_assistant_bloc/data/models/film_images_model.dart';

class FilmImagesEntity extends Equatable {
  final List<String>? imageUrls;
  final List<String>? previewUrls;

  const FilmImagesEntity({
    this.imageUrls,
    this.previewUrls
  });

  factory FilmImagesEntity.fromModel(FilmImagesModel filmImagesModel){
    return FilmImagesEntity(
      imageUrls: filmImagesModel.imageUrls,
      previewUrls: filmImagesModel.previewUrls
    );
  }
  
  @override
  List<Object?> get props => [imageUrls, previewUrls];
}