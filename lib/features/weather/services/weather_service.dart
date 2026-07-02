import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Service responsible for making HTTP calls to the Open-Meteo API.
///
/// Open-Meteo is a completely free, open-source weather API that
/// requires NO API key, no signup, and no registration.
/// https://open-meteo.com
class WeatherService {
  static const String _forecastBaseUrl = 'https://api.open-meteo.com/v1';
  static const String _geocodingBaseUrl = 'https://geocoding-api.open-meteo.com/v1';

  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  /// Searches for a city by name using the Open-Meteo Geocoding API.
  ///
  /// Returns a list of matching locations with lat/lon coordinates.
  /// Throws [WeatherApiException] on failure.
  Future<List<Map<String, dynamic>>> searchCity(String cityName) async {
    final uri = Uri.parse(
      '$_geocodingBaseUrl/search?name=${Uri.encodeComponent(cityName)}&count=5&language=en&format=json',
    );

    try {
      final response = await _client.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List?;
        if (results == null || results.isEmpty) {
          throw WeatherApiException(
            'City "$cityName" not found. Please check the spelling and try again.',
            statusCode: 404,
          );
        }
        return results.cast<Map<String, dynamic>>();
      } else {
        throw WeatherApiException(
          'Server error (${response.statusCode}). Please try again later.',
          statusCode: response.statusCode,
        );
      }
    } on WeatherApiException {
      rethrow;
    } on SocketException {
      throw WeatherApiException(
        'No internet connection. Please check your network and try again.',
        isNetworkError: true,
      );
    } on HttpException {
      throw WeatherApiException(
        'Could not reach the weather service. Please try again.',
        isNetworkError: true,
      );
    } on FormatException {
      throw WeatherApiException(
        'Received invalid data from the server. Please try again.',
      );
    }
  }

  /// Fetches weather data (current + hourly + daily) for given coordinates.
  ///
  /// Uses a single API call to get all weather data at once.
  /// Returns the raw JSON response as a Map.
  /// Throws [WeatherApiException] on failure.
  Future<Map<String, dynamic>> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(
      '$_forecastBaseUrl/forecast'
      '?latitude=$latitude'
      '&longitude=$longitude'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,'
      'weather_code,wind_speed_10m,surface_pressure,visibility'
      '&hourly=temperature_2m,weather_code,precipitation_probability'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset'
      '&timezone=auto'
      '&forecast_days=5',
    );

    try {
      final response = await _client.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw WeatherApiException(
          'Server error (${response.statusCode}). Please try again later.',
          statusCode: response.statusCode,
        );
      }
    } on WeatherApiException {
      rethrow;
    } on SocketException {
      throw WeatherApiException(
        'No internet connection. Please check your network and try again.',
        isNetworkError: true,
      );
    } on HttpException {
      throw WeatherApiException(
        'Could not reach the weather service. Please try again.',
        isNetworkError: true,
      );
    } on FormatException {
      throw WeatherApiException(
        'Received invalid data from the server. Please try again.',
      );
    }
  }

  /// Reverse geocodes coordinates (lat/lon) into a city and country name using BigDataCloud API.
  ///
  /// Returns a map with 'name' and 'country' keys.
  /// Throws [WeatherApiException] on failure.
  Future<Map<String, String>> reverseGeocode(double latitude, double longitude) async {
    final uri = Uri.parse(
      'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$latitude&longitude=$longitude&localityLanguage=en',
    );

    try {
      final response = await _client.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        
        // Find the most appropriate name representing the city/locality
        String cityName = '';
        if (data['city'] != null && (data['city'] as String).isNotEmpty) {
          cityName = data['city'] as String;
        } else if (data['locality'] != null && (data['locality'] as String).isNotEmpty) {
          cityName = data['locality'] as String;
        } else if (data['principalSubdivision'] != null && (data['principalSubdivision'] as String).isNotEmpty) {
          cityName = data['principalSubdivision'] as String;
        } else {
          cityName = 'Current Location';
        }

        final countryName = data['countryName'] as String? ?? '';
        return {
          'name': cityName,
          'country': countryName,
        };
      } else {
        throw WeatherApiException(
          'Failed to resolve location name (${response.statusCode}).',
          statusCode: response.statusCode,
        );
      }
    } on WeatherApiException {
      rethrow;
    } on SocketException {
      throw WeatherApiException(
        'No internet connection. Please check your network and try again.',
        isNetworkError: true,
      );
    } on HttpException {
      throw WeatherApiException(
        'Could not reach the geocoding service.',
        isNetworkError: true,
      );
    } on FormatException {
      throw WeatherApiException(
        'Received invalid geocoding data.',
      );
    }
  }

  void dispose() {
    _client.close();
  }
}

/// Custom exception for weather API errors.
///
/// Provides user-friendly error messages and metadata about the error type.
class WeatherApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool isNetworkError;

  WeatherApiException(
    this.message, {
    this.statusCode,
    this.isNetworkError = false,
  });

  @override
  String toString() => message;
}
