import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class WeatherViewModel extends ChangeNotifier {
  WeatherModel? _weather;
  bool _isLoading = false;
  String? _errorMessage;

  WeatherViewModel() {
    // Fetch default city weather on startup for gorgeous home screen layout
    fetchWeather('Montreal');
  }

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
      await Future.delayed(const Duration(milliseconds: 500));

      final cityLower = cityName.trim().toLowerCase();
      
      // Mock static forecasts
      final List<HourlyForecast> mockHourly = [
        HourlyForecast(time: '12 AM', temperature: 19.0, condition: 'Rainy', rainChance: 30),
        HourlyForecast(time: 'Now', temperature: 19.0, condition: 'Rainy', rainChance: 0),
        HourlyForecast(time: '2 AM', temperature: 18.0, condition: 'Cloudy', rainChance: 0),
        HourlyForecast(time: '3 AM', temperature: 19.0, condition: 'Rainy', rainChance: 0),
        HourlyForecast(time: '4 AM', temperature: 19.0, condition: 'Rainy', rainChance: 0),
        HourlyForecast(time: '5 AM', temperature: 20.0, condition: 'Sunny', rainChance: 0),
        HourlyForecast(time: '6 AM', temperature: 21.0, condition: 'Sunny', rainChance: 0),
        HourlyForecast(time: '7 AM', temperature: 22.0, condition: 'Sunny', rainChance: 0),
      ];

      final List<WeeklyForecast> mockWeekly = [
        WeeklyForecast(day: 'Mon', tempMax: 24.0, tempMin: 18.0, condition: 'Sunny'),
        WeeklyForecast(day: 'Tue', tempMax: 25.0, tempMin: 19.0, condition: 'Sunny'),
        WeeklyForecast(day: 'Wed', tempMax: 23.0, tempMin: 17.0, condition: 'Rainy'),
        WeeklyForecast(day: 'Thu', tempMax: 22.0, tempMin: 16.0, condition: 'Cloudy'),
        WeeklyForecast(day: 'Fri', tempMax: 24.0, tempMin: 18.0, condition: 'Sunny'),
        WeeklyForecast(day: 'Sat', tempMax: 26.0, tempMin: 19.0, condition: 'Sunny'),
        WeeklyForecast(day: 'Sun', tempMax: 25.0, tempMin: 18.0, condition: 'Sunny'),
      ];

      if (cityLower == 'montreal') {
        _weather = WeatherModel(
          cityName: 'Montreal',
          temperature: 19.0,
          condition: 'Mostly Clear',
          windSpeed: 10.0,
          humidity: 65,
          tempHigh: 24.0,
          tempLow: 18.0,
          hourlyForecast: mockHourly,
          weeklyForecast: mockWeekly,
        );
      } else if (cityLower == 'new york') {
        _weather = WeatherModel(
          cityName: 'New York',
          temperature: 18.5,
          condition: 'Rainy',
          windSpeed: 15.0,
          humidity: 80,
          tempHigh: 22.0,
          tempLow: 15.0,
          hourlyForecast: mockHourly.map((h) => h.time == 'Now' ? HourlyForecast(time: 'Now', temperature: 18.5, condition: 'Rainy', rainChance: 80) : h).toList(),
          weeklyForecast: mockWeekly,
        );
      } else if (cityLower == 'london') {
        _weather = WeatherModel(
          cityName: 'London',
          temperature: 14.0,
          condition: 'Cloudy',
          windSpeed: 12.0,
          humidity: 85,
          tempHigh: 16.0,
          tempLow: 11.0,
          hourlyForecast: mockHourly.map((h) => h.time == 'Now' ? HourlyForecast(time: 'Now', temperature: 14.0, condition: 'Cloudy', rainChance: 10) : h).toList(),
          weeklyForecast: mockWeekly,
        );
      } else if (cityLower == 'tokyo') {
        _weather = WeatherModel(
          cityName: 'Tokyo',
          temperature: 22.0,
          condition: 'Sunny',
          windSpeed: 8.5,
          humidity: 60,
          tempHigh: 26.0,
          tempLow: 18.0,
          hourlyForecast: mockHourly.map((h) => h.time == 'Now' ? HourlyForecast(time: 'Now', temperature: 22.0, condition: 'Sunny', rainChance: 0) : h).toList(),
          weeklyForecast: mockWeekly,
        );
      } else if (cityLower == 'paris') {
        _weather = WeatherModel(
          cityName: 'Paris',
          temperature: 16.0,
          condition: 'Windy',
          windSpeed: 20.0,
          humidity: 70,
          tempHigh: 19.0,
          tempLow: 12.0,
          hourlyForecast: mockHourly.map((h) => h.time == 'Now' ? HourlyForecast(time: 'Now', temperature: 16.0, condition: 'Windy', rainChance: 5) : h).toList(),
          weeklyForecast: mockWeekly,
        );
      } else {
        _weather = WeatherModel(
          cityName: cityName,
          temperature: 20.0,
          condition: 'Partly Cloudy',
          windSpeed: 10.0,
          humidity: 65,
          tempHigh: 24.0,
          tempLow: 16.0,
          hourlyForecast: mockHourly,
          weeklyForecast: mockWeekly,
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
