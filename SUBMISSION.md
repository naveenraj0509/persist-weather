# Submission

## Summary

Built a Flutter weather application that fetches real-time weather data from the OpenWeatherMap API, displays current conditions and forecasts, supports city search, and provides offline caching with a premium glassmorphic UI.

## Features Completed

| Feature | Status |
|---------|--------|
| Home screen with current weather | ✅ |
| City search flow | ✅ |
| Hourly forecast (next 24h) | ✅ |
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
- `lib/features/weather/services/weather_service.dart` — HTTP API calls
- `lib/features/weather/services/cache_service.dart` — SharedPreferences caching
- `lib/features/weather/views/search_view.dart` — City search screen
- `lib/features/weather/views/weather_detail_view.dart` — Weather detail screen
- `lib/features/weather/views/widgets/hourly_forecast_card.dart` — Extracted widget
- `lib/features/weather/views/widgets/daily_forecast_card.dart` — Extracted widget
- `lib/features/weather/views/widgets/metric_card.dart` — Extracted widget
- `lib/features/weather/views/widgets/offline_banner.dart` — Offline indicator
- `AI_USAGE.md` — AI tool usage documentation
- `SUBMISSION.md` — This file

### Modified Files
- `lib/main.dart` — SharedPreferences init, service injection
- `lib/features/weather/models/weather_model.dart` — Real API model mapping
- `lib/features/weather/viewmodels/weather_viewmodel.dart` — Service-based state management
- `lib/features/weather/views/weather_view.dart` — Refactored with extracted widgets and states
- `pubspec.yaml` — Added http, shared_preferences, intl, connectivity_plus
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

- **OpenWeatherMap Free Tier**: Current Weather + 5-Day/3-Hour Forecast
- `WeatherService` encapsulates all HTTP calls — never called from widgets
- API key injected via `--dart-define=OWM_API_KEY=<key>` at compile time
- Two parallel API calls (current + forecast) via `Future.wait` for performance
- `WeatherModel.fromApiResponses()` parses both responses into a unified model
- Daily forecast aggregated by grouping 3-hour entries by date, taking min/max temps

## Offline / Error Handling Approach

- **Offline caching**: `CacheService` stores the last successful API response per city in `SharedPreferences` as JSON with timestamps
- **Network errors**: Automatically falls back to cached data with an "Offline — Showing cached data" banner
- **City not found (404)**: Shows error message but keeps existing weather data so the user doesn't lose their current view
- **Empty state**: Shown on first launch before any city is searched
- **Retry**: Dedicated retry button re-fetches the last searched city
- **Cache staleness**: Data older than 30 minutes is refreshed on next fetch, but still used as offline fallback

## Checks Run

| Check | Result |
|-------|--------|
| `flutter analyze` | ✅ 0 errors, 0 warnings |
| `flutter test` | ✅ All tests passed |
| Code review (MVVM separation) | ✅ Verified |
| No API keys in source | ✅ Verified |
| No forbidden state management packages | ✅ Verified |

## What I Would Improve With More Time

1. **Geocoding / Autocomplete**: Use OpenWeatherMap's geocoding API for city name suggestions as the user types.
2. **Location Services**: Add device GPS to show weather for the user's current location automatically.
3. **Unit Toggle**: Allow switching between Celsius and Fahrenheit.
4. **Pull-to-Refresh**: Add swipe-down to refresh weather data on the home screen.
5. **Widget Tests**: Add more granular widget tests for each screen and error state.
6. **Integration Tests**: Full flow tests using `integration_test` package.
7. **Animated Weather Icons**: Replace static icons with Lottie animations for a more premium feel.
8. **Multi-City Dashboard**: Save multiple cities and show them in a list/grid view.
9. **Dark/Light Theme Toggle**: Currently only dark mode; add a light mode option.
10. **Accessibility**: Add semantic labels and ensure full screen reader compatibility.
