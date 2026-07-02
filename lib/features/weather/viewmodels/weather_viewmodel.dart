import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/cache_service.dart';

/// ViewModel for weather data using ChangeNotifier for Provider state management.
///
/// Manages all weather-related state: loading, error, offline, current weather,
/// hourly and daily forecasts. Delegates API calls to [WeatherService] and
/// caching to [CacheService]. No API calls happen directly in this class.
class WeatherViewModel extends ChangeNotifier {
  final WeatherService _weatherService;
  final CacheService _cacheService;

  // --- State Fields ---
  WeatherModel? _weather;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOffline = false;
  String _selectedCity = '';
  bool _isInitialized = false;

  WeatherViewModel({
    required WeatherService weatherService,
    required CacheService cacheService,
  })  : _weatherService = weatherService,
        _cacheService = cacheService;

  // --- Getters ---
  WeatherModel? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOffline => _isOffline;
  String get selectedCity => _selectedCity;
  bool get isInitialized => _isInitialized;
  bool get hasData => _weather != null;
  bool get isEmpty => !_isLoading && _errorMessage == null && _weather == null;

  /// Recently searched cities from cache.
  List<String> get recentCities => _cacheService.getRecentCities();

  /// Initializes the ViewModel by loading the last searched city's weather.
  ///
  /// Called once from the UI after the widget tree is built.
  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    final lastCity = _cacheService.getLastSearchedCity();
    if (lastCity != null && lastCity.isNotEmpty) {
      await fetchWeather(lastCity);
    }
  }

  /// Fetches weather data for the given [city].
  ///
  /// Flow:
  /// 1. Validate input
  /// 2. Set loading state
  /// 3. Call WeatherService for current weather + forecast
  /// 4. Parse response into WeatherModel
  /// 5. Cache the result
  /// 6. On network failure, fall back to cached data
  Future<void> fetchWeather(String cityName) async {
    final city = cityName.trim();
    if (city.isEmpty) {
      _errorMessage = 'Please enter a city name.';
      _weather = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _isOffline = false;
    _selectedCity = city;
    notifyListeners();

    try {
      // Fetch both current weather and forecast in parallel
      final results = await Future.wait([
        _weatherService.fetchCurrentWeather(city),
        _weatherService.fetchForecast(city),
      ]);

      final currentJson = results[0];
      final forecastJson = results[1];

      // Parse API responses into the model
      _weather = WeatherModel.fromApiResponses(currentJson, forecastJson);
      _isOffline = false;
      _errorMessage = null;

      // Cache the successful result
      await _cacheService.cacheWeatherData(
        city: city,
        currentWeatherJson: currentJson,
        forecastJson: forecastJson,
      );
      await _cacheService.saveLastSearchedCity(_weather!.cityName);
    } on WeatherApiException catch (e) {
      // Try to fall back to cached data on network errors
      if (e.isNetworkError) {
        final cached = _tryLoadFromCache(city);
        if (cached) {
          _isOffline = true;
          _errorMessage = null;
        } else {
          _errorMessage = e.message;
          _weather = null;
        }
      } else {
        _errorMessage = e.message;
        // Keep existing weather data if it was a search error
        // so the user doesn't lose their current view
        if (e.statusCode == 404) {
          // Don't clear existing weather on city-not-found
        } else {
          _weather = null;
        }
      }
    } catch (e) {
      // Unexpected errors — try cache fallback
      final cached = _tryLoadFromCache(city);
      if (cached) {
        _isOffline = true;
        _errorMessage = null;
      } else {
        _errorMessage = 'Something went wrong. Please try again.';
        _weather = null;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Retries fetching weather for the last selected city.
  Future<void> retry() async {
    if (_selectedCity.isNotEmpty) {
      await fetchWeather(_selectedCity);
    }
  }

  /// Attempts to load weather data from local cache.
  ///
  /// Returns true if cached data was found and loaded.
  bool _tryLoadFromCache(String city) {
    final cachedData = _cacheService.getCachedWeatherData(city);
    if (cachedData != null) {
      try {
        final currentJson = cachedData['current'] as Map<String, dynamic>;
        final forecastJson = cachedData['forecast'] as Map<String, dynamic>;
        _weather = WeatherModel.fromApiResponses(currentJson, forecastJson);
        return true;
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  /// Clears the current weather data and resets state.
  void clearWeather() {
    _weather = null;
    _errorMessage = null;
    _isOffline = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _weatherService.dispose();
    super.dispose();
  }
}
