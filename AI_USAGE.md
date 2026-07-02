# AI Usage

## AI Tools Used

- **Gemini (Antigravity IDE)**: Used as the primary AI coding assistant during development.

## What AI Was Used For

1. **Architecture planning**: Designing the MVVM folder structure, service layer separation, and Provider integration pattern.
2. **Boilerplate generation**: Generating initial model classes, service classes, and widget skeletons.
3. **API integration**: Writing the `WeatherService` class for Open-Meteo API calls and BigDataCloud reverse geocoding, plus the `LocationService` class using `geolocator`.
4. **Code refactoring**: Extracting inline widget builders and integrating GPS location actions across the home and search screens.
5. **Documentation**: Drafting README.md, SUBMISSION.md, and this file.

## Code and Architecture Decisions Reviewed Manually

1. **API response parsing**: Verified that `WeatherModel.fromOpenMeteo()` correctly maps all Open-Meteo JSON fields, and BigDataCloud geocoding translates coordinate outputs back to proper locality strings.
2. **Error handling strategy**: Reviewed the decision to show cached data on network errors vs. showing an error screen, handling location permission denials, and handling location service disabled exceptions.
3. **State management flow**: Confirmed that `ChangeNotifier` + `Provider` is used consistently and location services are cleanly injected.
4. **Offline caching design**: Reviewed the `CacheService` to ensure GPS-resolved location weather is also correctly cached.
5. **API choice**: Switched to Open-Meteo and BigDataCloud to strictly adhere to the requirement of using free, keyless client APIs.
6. **Navigation architecture**: Decided to use full-screen `SearchView` and `WeatherDetailView` via `Navigator.push` rather than dialogs, and mapped bottom bar icon actions cleanly.

## AI-Generated Output Rejected or Corrected

1. **Initial suggestion to use OpenWeatherMap**: Corrected to use Open-Meteo to avoid requiring any API key or registration.
2. **Suggested `cached_network_image` dependency**: Removed since we use CupertinoIcons instead of custom icon URLs, avoiding an unnecessary dependency.
3. **Initial mock data approach**: The original codebase had hardcoded mock data for specific cities. This was completely replaced with real API calls.

## How the Final Code Was Verified

1. **Static analysis**: Ran `flutter analyze` — 0 errors, 0 warnings, 0 info items (all deprecated `withOpacity` usages were refactored to `.withValues()`).
2. **Unit tests**: Ran `flutter test` — all tests pass.
3. **Code review**: Manually reviewed all files for proper separation of concerns, no API calls in widgets, and consistent error handling.
4. **Architecture check**: Verified MVVM pattern: Models have no Flutter dependencies, ViewModel only depends on services, Views only depend on ViewModel via Provider.
