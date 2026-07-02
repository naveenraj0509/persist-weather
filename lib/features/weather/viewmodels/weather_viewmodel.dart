import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class WeatherViewModel extends ChangeNotifier {
  WeatherModel? _weather;
  bool _isLoading = false;
  String? _errorMessage;

  WeatherModel? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchWeather(String cityName) async {
    if (cityName.trim().isEmpty) {
      _errorMessage = 'Please enter a valid city name';
      _weather = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate network request
      await Future.delayed(const Duration(seconds: 1));

      final cityLower = cityName.trim().toLowerCase();
      if (cityLower == 'new york') {
        _weather = WeatherModel(
          cityName: 'New York',
          temperature: 18.5,
          condition: 'Rainy',
          windSpeed: 15.0,
          humidity: 80,
        );
      } else if (cityLower == 'london') {
        _weather = WeatherModel(
          cityName: 'London',
          temperature: 14.0,
          condition: 'Cloudy',
          windSpeed: 12.0,
          humidity: 85,
        );
      } else if (cityLower == 'tokyo') {
        _weather = WeatherModel(
          cityName: 'Tokyo',
          temperature: 22.0,
          condition: 'Sunny',
          windSpeed: 8.5,
          humidity: 60,
        );
      } else if (cityLower == 'paris') {
        _weather = WeatherModel(
          cityName: 'Paris',
          temperature: 16.0,
          condition: 'Windy',
          windSpeed: 20.0,
          humidity: 70,
        );
      } else {
        // Mock generic response for other cities
        _weather = WeatherModel(
          cityName: cityName,
          temperature: 20.0,
          condition: 'Partly Cloudy',
          windSpeed: 10.0,
          humidity: 65,
        );
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch weather. Please try again.';
      _weather = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearWeather() {
    _weather = null;
    _errorMessage = null;
    notifyListeners();
  }
}
