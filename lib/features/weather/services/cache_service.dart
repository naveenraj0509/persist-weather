import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for local caching of weather data using SharedPreferences.
///
/// Caches the last successful weather result per city and tracks the last searched city.
/// Data is stored as JSON strings with timestamps for staleness checks.
class CacheService {
  static const String _lastCityKey = 'last_searched_city';
  static const String _weatherCachePrefix = 'weather_cache_';
  static const String _cacheTimestampPrefix = 'cache_timestamp_';
  static const String _recentCitiesKey = 'recent_cities';

  /// Cache expiry duration — data older than this is considered stale
  /// but still used as fallback when offline.
  static const Duration cacheExpiry = Duration(minutes: 30);

  final SharedPreferences _prefs;

  CacheService(this._prefs);

  /// Saves the last successfully searched city name.
  Future<void> saveLastSearchedCity(String city) async {
    await _prefs.setString(_lastCityKey, city);
    await _addToRecentCities(city);
  }

  /// Returns the last searched city, or null if none.
  String? getLastSearchedCity() {
    return _prefs.getString(_lastCityKey);
  }

  /// Caches weather data (current + forecast) for a city.
  Future<void> cacheWeatherData({
    required String city,
    required Map<String, dynamic> currentWeatherJson,
    required Map<String, dynamic> forecastJson,
  }) async {
    final cacheKey = _weatherCachePrefix + city.toLowerCase().trim();
    final timestampKey = _cacheTimestampPrefix + city.toLowerCase().trim();

    final cacheData = {
      'current': currentWeatherJson,
      'forecast': forecastJson,
    };

    await _prefs.setString(cacheKey, json.encode(cacheData));
    await _prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Retrieves cached weather data for a city.
  ///
  /// Returns a map with 'current' and 'forecast' keys, or null if no cache exists.
  Map<String, dynamic>? getCachedWeatherData(String city) {
    final cacheKey = _weatherCachePrefix + city.toLowerCase().trim();
    final cachedString = _prefs.getString(cacheKey);

    if (cachedString == null) return null;

    try {
      return json.decode(cachedString) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Checks if cached data for a city is stale (older than [cacheExpiry]).
  bool isCacheStale(String city) {
    final timestampKey = _cacheTimestampPrefix + city.toLowerCase().trim();
    final timestamp = _prefs.getInt(timestampKey);

    if (timestamp == null) return true;

    final cachedAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(cachedAt) > cacheExpiry;
  }

  /// Returns a list of recently searched cities (up to 10).
  List<String> getRecentCities() {
    final cities = _prefs.getStringList(_recentCitiesKey);
    return cities ?? [];
  }

  /// Adds a city to the recent cities list, keeping only the last 10.
  Future<void> _addToRecentCities(String city) async {
    final cities = getRecentCities();

    // Remove if already exists (to move it to the front)
    cities.removeWhere((c) => c.toLowerCase() == city.toLowerCase());
    cities.insert(0, city);

    // Keep only the last 10
    if (cities.length > 10) {
      cities.removeRange(10, cities.length);
    }

    await _prefs.setStringList(_recentCitiesKey, cities);
  }

  /// Clears all cached data.
  Future<void> clearAll() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_weatherCachePrefix) ||
          key.startsWith(_cacheTimestampPrefix)) {
        await _prefs.remove(key);
      }
    }
  }
}
