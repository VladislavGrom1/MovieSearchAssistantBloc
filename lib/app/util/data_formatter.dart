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

  static String formatGenres(List<String>? genres) {
    final List<String> parts = [];
    
    if (genres != null && genres.isNotEmpty) {
      final limitedGenres = genres.take(3);
      final genresStr = limitedGenres.join(', ');
      parts.add(genresStr);
    }
    
    return parts.isEmpty ? '-' : parts.join(', ');
  }
}