class ApiConstants {
  // Prevent instantiation
  ApiConstants._();

  /// Open-Meteo forecast API base URL (requires no API key)
  static const String forecastBaseUrl = 'https://api.open-meteo.com/v1';

  /// Open-Meteo geocoding API base URL (requires no API key)
  static const String geocodingBaseUrl = 'https://geocoding-api.open-meteo.com/v1';

  /// BigDataCloud reverse geocoding API base URL (requires no API key)
  static const String reverseGeocodeBaseUrl = 'https://api.bigdatacloud.net/data/reverse-geocode-client';
}
