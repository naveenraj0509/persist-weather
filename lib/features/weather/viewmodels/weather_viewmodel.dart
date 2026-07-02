import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/cache_service.dart';
import '../services/location_service.dart';

/// ViewModel for weather data using ChangeNotifier for Provider state management.
///
/// Manages all weather-related state: loading, error, offline, current weather,
/// hourly and daily forecasts. Delegates API calls to [WeatherService], location
/// coordinates to [LocationService], and caching to [CacheService].
class WeatherViewModel extends ChangeNotifier {
  final WeatherService _weatherService;
  final CacheService _cacheService;
  final LocationService _locationService;

  // --- State Fields ---
  WeatherModel? _weather;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOffline = false;
  String _selectedCity = '';
  bool _isInitialized = false;
  bool _lastActionWasGps = false;

  WeatherViewModel({
    required WeatherService weatherService,
    required CacheService cacheService,
    required LocationService locationService,
  })  : _weatherService = weatherService,
        _cacheService = cacheService,
        _locationService = locationService;

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
  /// 3. Call Geocoding API to get lat/lon for the city
  /// 4. Call Forecast API with lat/lon
  /// 5. Parse response into WeatherModel
  /// 6. Cache the result
  /// 7. On network failure, fall back to cached data
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
    _lastActionWasGps = false;
    notifyListeners();

    try {
      // Step 1: Geocode city name → lat/lon
      final geoResults = await _weatherService.searchCity(city);
      final geoData = geoResults.first;
      final lat = (geoData['latitude'] as num).toDouble();
      final lon = (geoData['longitude'] as num).toDouble();

      // Step 2: Fetch weather using coordinates
      final forecastJson = await _weatherService.fetchWeather(
        latitude: lat,
        longitude: lon,
      );

      // Parse API response into the model
      _weather = WeatherModel.fromOpenMeteo(forecastJson, geoData);
      _isOffline = false;
      _errorMessage = null;

      // Cache the successful result
      await _cacheService.cacheWeatherData(
        city: _weather!.cityName,
        weatherJson: forecastJson,
        geoJson: geoData,
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

  /// Retries fetching weather for the last selected city or GPS location.
  Future<void> retry() async {
    if (_lastActionWasGps) {
      await fetchWeatherForCurrentLocation();
    } else if (_selectedCity.isNotEmpty) {
      await fetchWeather(_selectedCity);
    }
  }

  /// Fetches weather data for the device's current location via GPS.
  Future<void> fetchWeatherForCurrentLocation() async {
    _isLoading = true;
    _errorMessage = null;
    _isOffline = false;
    _lastActionWasGps = true;
    notifyListeners();

    try {
      // Step 1: Get GPS coordinates
      final position = await _locationService.getCurrentPosition();
      final lat = position.latitude;
      final lon = position.longitude;

      // Step 2: Reverse-geocode coordinates to get location name
      final reverseGeo = await _weatherService.reverseGeocode(lat, lon);
      final cityName = reverseGeo['name'] ?? 'Current Location';
      final countryName = reverseGeo['country'] ?? '';

      // Construct a geocoding data structure matching what the geocoding API would return
      final geoData = {
        'name': cityName,
        'country': countryName,
        'latitude': lat,
        'longitude': lon,
      };

      // Step 3: Fetch weather for these coordinates
      final forecastJson = await _weatherService.fetchWeather(
        latitude: lat,
        longitude: lon,
      );

      // Step 4: Parse API response
      _weather = WeatherModel.fromOpenMeteo(forecastJson, geoData);
      _selectedCity = cityName;
      _isOffline = false;
      _errorMessage = null;

      // Cache the successful result
      await _cacheService.cacheWeatherData(
        city: cityName,
        weatherJson: forecastJson,
        geoJson: geoData,
      );
      await _cacheService.saveLastSearchedCity(cityName);
    } on LocationServiceException catch (e) {
      _errorMessage = e.message;
      // If we already have weather loaded, keep it so the UI doesn't blank out
    } on WeatherApiException catch (e) {
      // Try to fall back to cached data on network errors
      if (e.isNetworkError && _selectedCity.isNotEmpty) {
        final cached = _tryLoadFromCache(_selectedCity);
        if (cached) {
          _isOffline = true;
          _errorMessage = null;
        } else {
          _errorMessage = e.message;
        }
      } else {
        _errorMessage = e.message;
      }
    } catch (e) {
      _errorMessage = 'Failed to locate device: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Attempts to load weather data from local cache.
  ///
  /// Returns true if cached data was found and loaded.
  bool _tryLoadFromCache(String city) {
    final cachedData = _cacheService.getCachedWeatherData(city);
    if (cachedData != null) {
      try {
        final forecastJson = cachedData['weather'] as Map<String, dynamic>;
        final geoJson = cachedData['geo'] as Map<String, dynamic>;
        _weather = WeatherModel.fromOpenMeteo(forecastJson, geoJson);
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
