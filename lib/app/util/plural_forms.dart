class PluralForms {
  static String films(int count) {
    final lastDigit = count % 10;
    final lastTwoDigits = count % 100;
    
    if (lastTwoDigits >= 11 && lastTwoDigits <= 19) {
      return '$count фильмов';
    }
    
    if (lastDigit == 1) {
      return '$count фильм';
    }
    
    if (lastDigit >= 2 && lastDigit <= 4) {
      return '$count фильма';
    }
    
    return '$count фильмов';
  }
}