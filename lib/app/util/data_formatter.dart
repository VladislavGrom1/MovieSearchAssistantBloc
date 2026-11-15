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
  
  static String formatDateTime(DateTime? dateTime){
    if (dateTime == null) return 'Дата не указана';
    
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    
    return '$day.$month.$year $hour:$minute';
  }

  /// День относительно сегодняшнего: «Сегодня», «Вчера», «13.11» или «13.11.2025».
  static String formatRelativeDay(DateTime dateTime, {DateTime? now}) {
    final DateTime reference = now ?? DateTime.now();
    final DateTime day = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final DateTime today = DateTime(reference.year, reference.month, reference.day);
    final int daysDifference = today.difference(day).inDays;

    if (daysDifference == 0) {
      return 'Сегодня';
    }

    if (daysDifference == 1) {
      return 'Вчера';
    }

    final String dayPart = dateTime.day.toString().padLeft(2, '0');
    final String monthPart = dateTime.month.toString().padLeft(2, '0');

    if (dateTime.year == reference.year) {
      return '$dayPart.$monthPart';
    }

    return '$dayPart.$monthPart.${dateTime.year}';
  }

  /// «Сегодня, 15:38» — день по [formatRelativeDay] плюс время.
  static String formatRelativeDayTime(DateTime dateTime, {DateTime? now}) {
    final String dayPart = formatRelativeDay(dateTime, now: now);
    final String hourPart = dateTime.hour.toString().padLeft(2, '0');
    final String minutePart = dateTime.minute.toString().padLeft(2, '0');

    return '$dayPart, $hourPart:$minutePart';
  }

  /// «2001 · Криминал, комедия» — год и не больше [genreLimit] жанров.
  static String formatYearWithGenres(
    int? year,
    List<String>? genres, {
    int genreLimit = 2,
  }) {
    final List<String> parts = [];

    if (year != null) {
      parts.add(year.toString());
    }

    final String genresPart = _formatGenresPart(genres, genreLimit);

    if (genresPart.isNotEmpty) {
      parts.add(genresPart);
    }

    return parts.isEmpty ? '-' : parts.join(' · ');
  }

  static String _formatGenresPart(List<String>? genres, int genreLimit) {
    if (genres == null || genres.isEmpty || genreLimit <= 0) {
      return '';
    }

    final List<String> cleanedGenres = genres
        .map((genre) => genre.trim())
        .where((genre) => genre.isNotEmpty)
        .take(genreLimit)
        .toList();

    if (cleanedGenres.isEmpty) {
      return '';
    }

    final String joinedGenres = cleanedGenres.join(', ');
    final String firstLetter = joinedGenres.substring(0, 1).toUpperCase();

    return '$firstLetter${joinedGenres.substring(1)}';
  }
  
}
