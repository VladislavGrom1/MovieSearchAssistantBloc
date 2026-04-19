class DataFormatter {
  static String formatCountriesAndYear(List<String>? countries, int? year) {
    final List<String> parts = [];
    
    if (countries != null && countries.isNotEmpty) {
      final limitedCountries = countries.take(2);
      final countriesStr = limitedCountries.join(', ');
      parts.add(countriesStr);
    }
    
    if (year != null) {
      parts.add(year.toString());
    }
    
    return parts.isEmpty ? '-' : parts.join(', ');
  }

  static String formatCountries(List<String>? countries){
    final List<String> parts = [];

    if (countries != null && countries.isNotEmpty) {
      final limitedCountries = countries.take(4);
      final countriesStr = limitedCountries.join(', ');
      parts.add(countriesStr);
    }
    return parts.isEmpty ? '-' : parts.join(', ');
  }

  static String formatGenres(List<String>? genres) {
    final List<String> parts = [];

    if (genres != null && genres.isNotEmpty) {
      final limitedGenres = genres.take(3);
      final genresStr = limitedGenres.join(', ');
      parts.add(genresStr);
    }

    return parts.isEmpty ? '-' : parts.join(', ');
  }

  static String formatVoteCount(int value) {
    if (value < 1000) {
      return value.toString();
    }

    if (value < 1000000) {
      final thousands = value / 1000;
      return '${thousands.toStringAsFixed(thousands.truncateToDouble() == thousands ? 0 : 1)}K';
    }

    final millions = value / 1000000;
    return '${millions.toStringAsFixed(millions.truncateToDouble() == millions ? 0 : 1)}M';
  }

  static String formatFilmWordDeclension(int filmCount){
    final lastDigit = filmCount % 10;
    final lastTwoDigits = filmCount % 100;
      
    if (lastTwoDigits >= 11 && lastTwoDigits <= 19) {
      return '$filmCount фильмов';
    }
      
    if (lastDigit == 1) {
      return '$filmCount фильм';
    }
      
    if (lastDigit >= 2 && lastDigit <= 4) {
      return '$filmCount фильма';
    }
      
    return '$filmCount фильмов';
  }


  static String formatCollectionName(String collectionName){
    String collectionNameFormated;
    switch(collectionName){
      case("TOP_POPULAR_MOVIES"): collectionNameFormated = "Популярные фильмы"; break;
      case("POPULAR_SERIES"): collectionNameFormated = "Популярные сериалы"; break;
      case("LOVE_THEME"): collectionNameFormated = "Такая разная любовь"; break;
      case("KIDS_ANIMATION_THEME"): collectionNameFormated = "Мультфильмы"; break;
      case("COMICS_THEME"): collectionNameFormated = "Кинокомиксы"; break;
      case("TOP_250_MOVIES"): collectionNameFormated = "Топ 250: фильмы"; break;
      case("TOP_250_TV_SHOWS"): collectionNameFormated = "Топ 250: сериалы"; break;
      default: collectionNameFormated = collectionName;
    }
    return collectionNameFormated;
  }
  // static String formatFilmRatingAndVoteCount(String resourceName, num? rating, int? voteCount){
  //   final ratingText = rating == null ? "-" : rating.toString();
  //       final voteCountText = "${voteCount == null ? 0 : voteCount.toString()} оценок";
  //       return Text("$resourceName, $ratingText, $voteCountText");
  // }
}
