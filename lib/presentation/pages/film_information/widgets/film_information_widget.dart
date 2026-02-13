import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_images_entity.dart';
import 'package:movie_search_assistant_bloc/domain/entities/film_information_entity.dart';

class FilmInformationWidget extends StatelessWidget {
  const FilmInformationWidget({
    super.key,
    required this.film,
    required this.images
  });

  final FilmInformationEntity film;
  final FilmImagesEntity? images;

  @override
  Widget build(BuildContext context) {
    final titleText = film.nameRu ?? film.nameOriginal ?? "Название отсутствует";
    return CustomScrollView(slivers: [
      SliverList.list(children: [
        Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(titleText),
                  SizedBox(height: 10.h),
                  ..._nameOriginal(film.nameOriginal),
                  Text(film.serial! ? "${film.startYear} - ${film.endYear ?? "настоящее время"}" : "${film.year}"),
                  SizedBox(height: 10.h),
                  Text(_getCountriesString(film.countries)),
                  SizedBox(height: 10.h),
                  Text(_getGenresString(film.genres)),
                  SizedBox(height: 10.h),
                  Text(film.description.toString()),
                  SizedBox(height: 10.h),
                  Text(_getSloganString(film.slogan)),
                  SizedBox(height: 10.h),
                  _filmRatingAndReviewCount("Рейтинг KP", film.ratingKinopoisk, film.ratingKinopoiskVoteCount),
                  SizedBox(height: 10.h),
                  _filmRatingAndReviewCount("Рейтинг IMDB", film.ratingImdb, film.ratingImdbVoteCount),
                  SizedBox(height: 10.h),
                  Text("${images?.imageUrls.toString()}") 
                ]))
      ]),
    ]);
  }

  String _getGenresString(List<String>? genres) {
    return genres?.join(', ') ?? "Данные отсутствуют";
  }

  String _getCountriesString(List<String>? countries){
    return countries?.join(', ') ?? "Данные отсутствуют";
  }

  String _getSloganString(String? slogan){
    return slogan ?? "Слоган отсутствует";
  }

  Widget _filmRatingAndReviewCount(String resourceName, num? rating, int? voteCount){
    final ratingText = rating == null ? "-" : rating.toString();
    final voteCountText = "${voteCount == null ? 0 : voteCount.toString()} оценок";
    return Text("$resourceName, $ratingText, $voteCountText");
  }

  List<Widget> _nameOriginal(String? nameOriginal){
    if(nameOriginal != null) {
      return [
        Text(nameOriginal),
        SizedBox(height: 10.h)
      ];
    }
    return [SizedBox()];
  }
}