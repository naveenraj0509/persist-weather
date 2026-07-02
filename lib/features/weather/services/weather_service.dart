import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Service responsible for making HTTP calls to the OpenWeatherMap API.
///
/// API key is injected via `--dart-define=OWM_API_KEY=<your_key>` at build time.
/// No API calls are made directly from widgets or ViewModels.
class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _apiKey = String.fromEnvironment('OWM_API_KEY');

  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches current weather data for a given [city].
  ///
  /// Returns the raw JSON response as a Map.
  /// Throws [WeatherApiException] on failure.
  Future<Map<String, dynamic>> fetchCurrentWeather(String city) async {
    _validateApiKey();

    final uri = Uri.parse(
      '$_baseUrl/weather?q=${Uri.encodeComponent(city)}&appid=$_apiKey&units=metric',
    );

    try {
      final response = await _client.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        throw WeatherApiException(
          'City "$city" not found. Please check the spelling and try again.',
          statusCode: 404,
        );
      } else if (response.statusCode == 401) {
        throw WeatherApiException(
          'Invalid API key. Please check your OpenWeatherMap API key.',
          statusCode: 401,
        );
      } else {
        throw WeatherApiException(
          'Server error (${response.statusCode}). Please try again later.',
          statusCode: response.statusCode,
        );
      }
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

  /// Fetches the 5-day / 3-hour forecast for a given [city].
  ///
  /// Returns the raw JSON response as a Map.
  /// Throws [WeatherApiException] on failure.
  Future<Map<String, dynamic>> fetchForecast(String city) async {
    _validateApiKey();

    final uri = Uri.parse(
      '$_baseUrl/forecast?q=${Uri.encodeComponent(city)}&appid=$_apiKey&units=metric',
    );

    try {
      final response = await _client.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        throw WeatherApiException(
          'Forecast data not found for "$city".',
          statusCode: 404,
        );
      } else {
        throw WeatherApiException(
          'Server error (${response.statusCode}). Please try again later.',
          statusCode: response.statusCode,
        );
      }
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

  void _validateApiKey() {
    if (_apiKey.isEmpty) {
      throw WeatherApiException(
        'API key not configured. Run with: flutter run --dart-define=OWM_API_KEY=<your_key>',
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
