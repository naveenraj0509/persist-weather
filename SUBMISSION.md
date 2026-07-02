# Submission

## Summary

Built a Flutter weather application that fetches real-time weather data from the Open-Meteo API (using no API key), displays current conditions and forecasts, supports city search, and provides offline caching with a premium glassmorphic UI. It also integrates GPS-based location detection to automatically load weather for the user's current position.

## Features Completed

| Feature | Status |
|---------|--------|
| Home screen with current weather | ✅ |
| City search flow | ✅ |
| GPS location weather fetching | ✅ |
| Hourly forecast (next 8h) | ✅ |
| 5-day daily forecast | ✅ |
| Weather detail screen | ✅ |
| Loading state | ✅ |
| Empty state | ✅ |
| Error state with retry | ✅ |
| Offline caching | ✅ |
| Offline banner indicator | ✅ |
| Responsive UI | ✅ |
| Navigation between screens | ✅ |
| Recent search history | ✅ |

## Files and Areas Changed

### New Files
- `lib/features/weather/services/location_service.dart` — Geolocation checks and device coordinate fetching using `geolocator`
- `lib/features/weather/views/search_view.dart` — City search screen
- `lib/features/weather/views/weather_detail_view.dart` — Weather detail screen
- `lib/features/weather/views/widgets/hourly_forecast_card.dart` — Extracted widget
- `lib/features/weather/views/widgets/daily_forecast_card.dart` — Extracted widget
- `lib/features/weather/views/widgets/metric_card.dart` — Extracted widget
- `lib/features/weather/views/widgets/offline_banner.dart` — Offline indicator
- `AI_USAGE.md` — AI tool usage documentation
- `SUBMISSION.md` — This file

### Modified Files
- `lib/main.dart` — SharedPreferences init, location/weather/cache service injection
- `lib/features/weather/services/weather_service.dart` — HTTP API calls (Open-Meteo) and BigDataCloud reverse geocoding
- `lib/features/weather/models/weather_model.dart` — Open-Meteo API model mapping (WMO codes, string sunrises/sunsets, visibility)
- `lib/features/weather/viewmodels/weather_viewmodel.dart` — Service-based state management (geocoding + forecast + GPS location flows)
- `lib/features/weather/views/weather_view.dart` — Refactored with bottom navigation and map-pin locator integration
- `android/app/src/main/AndroidManifest.xml` — Added Android coarse and fine location permissions
- `ios/Runner/Info.plist` — Added iOS location usage description keys
- `pubspec.yaml` — Added http, shared_preferences, intl, connectivity_plus, geolocator
- `.gitignore` — Added env and signing file exclusions
- `README.md` — Full project documentation
- `test/widget_test.dart` — Updated for new app constructor

### Preserved Files (no changes)
- `lib/features/weather/views/widgets/twinkling_stars_background.dart`
- `lib/features/weather/views/widgets/stylized_weather_house.dart`
- `lib/features/weather/views/widgets/custom_bottom_nav_bar.dart`

## State Management Approach

- **Provider** with **ChangeNotifier** — the only state management solution used
- `WeatherViewModel` extends `ChangeNotifier` and is provided via `ChangeNotifierProvider` in `main.dart`
- Views use `context.watch<WeatherViewModel>()` for reactive rebuilds and `context.read<WeatherViewModel>()` for one-off actions
- No GetX, Bloc, Cubit, Riverpod, MobX, or any other state management package

## API / Data Handling Approach

- **Open-Meteo Geocoding API**: Resolves city searches to coordinates. **Requires no API key.**
- **Open-Meteo Forecast API**: Fetches weather metrics (temp, feels like, condition code, wind, humidity, pressure, visibility, sunrise/sunset, hourly and daily forecast lists). **Requires no API key.**
- **BigDataCloud Reverse Geocoding API**: Translates latitude and longitude coordinates back to real city and country names. **Client-side keyless public endpoint.**
- `WeatherService` encapsulates all HTTP calls — never called from widgets.
- `WeatherModel.fromOpenMeteo()` parses the responses and WMO weather codes into a unified model.

## Offline / Error Handling Approach

- **Offline caching**: `CacheService` stores the last successful forecast and geocoding response per city in `SharedPreferences` as JSON with timestamps.
- **Network errors**: Automatically falls back to cached data with an "Offline — Showing cached data" banner.
- **Location & GPS issues**: Displays location-specific error messages if services are disabled or permissions are denied.
- **City not found (404)**: Shows error message but keeps existing weather data so the user doesn't lose their current view.
- **Empty state**: Shown on first launch before any city is searched.
- **Retry**: Dedicated retry button re-fetches the last searched city.
- **Cache staleness**: Data older than 30 minutes is refreshed on next fetch, but still used as offline fallback.

## Checks Run

| Check | Result |
|-------|--------|
| `flutter analyze` | ✅ 0 errors, 0 warnings, 0 info items |
| `flutter test` | ✅ All tests passed |
| Code review (MVVM separation) | ✅ Verified |
| No API keys required | ✅ Verified |
| No forbidden state management packages | ✅ Verified |

## What I Would Improve With More Time

1. **Geocoding Autocomplete**: Show a dropdown of city suggestions *as* the user types in the search field.
2. **Interactive Weather Charts**: Add charts/graphs to plot temperature and rain probability fluctuations over the next 24 hours.
3. **Unit Toggle**: Allow switching between Celsius and Fahrenheit.
4. **Pull-to-Refresh**: Add swipe-down to refresh weather data on the home screen.
5. **Widget Tests**: Add more granular widget tests for each screen and error state.
6. **Integration Tests**: Full flow tests using `integration_test` package.
7. **Animated Weather Icons**: Replace static icons with Lottie animations for a more premium feel.
8. **Multi-City Dashboard**: Save multiple cities and show them in a list/grid view.
9. **Dark/Light Theme Toggle**: Currently only dark mode; add a light mode option.
10. **Accessibility**: Add semantic labels and ensure full screen reader compatibility.
