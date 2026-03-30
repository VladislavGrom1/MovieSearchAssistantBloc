import 'package:generated/generated.dart';

class FilmImagesModel {
  List<String>? imageUrls;
  List<String>? previewUrls; 

  FilmImagesModel({
    this.imageUrls,
    this.previewUrls
  });

  factory FilmImagesModel.fromImageResponse(ImageResponse imageFilmUrls){
    return FilmImagesModel(
      imageUrls: imageFilmUrls.items.where((imageUrl) => imageUrl.imageUrl != null).take(5).map((imageUrl) => imageUrl.imageUrl!).toList(),
      previewUrls: imageFilmUrls.items.where((previewUrl) => previewUrl.previewUrl != null).take(5).map((previewUrl) => previewUrl.previewUrl!).toList(),
    );
  }
}