# AI Usage

## AI Tools Used

- **Gemini (Antigravity IDE)**: Used as the primary AI coding assistant during development.

## What AI Was Used For

1. **Architecture planning**: Designing the MVVM folder structure, service layer separation, and Provider integration pattern.
2. **Boilerplate generation**: Generating initial model classes, service classes, and widget skeletons.
3. **API integration**: Writing the `WeatherService` class for Open-Meteo (Geocoding + Forecast) API calls with proper error handling and no API keys.
4. **Code refactoring**: Extracting inline widget builders into standalone widget files for modularity.
5. **Documentation**: Drafting README.md, SUBMISSION.md, and this file.

## Code and Architecture Decisions Reviewed Manually

1. **API response parsing**: Verified that `WeatherModel.fromOpenMeteo()` correctly maps all Open-Meteo JSON fields, especially coordinates, WMO weather codes, and daily forecast lists.
2. **Error handling strategy**: Reviewed the decision to show cached data on network errors vs. showing an error screen, and the distinction between 404 (city not found) and network errors.
3. **State management flow**: Confirmed that `ChangeNotifier` + `Provider` is used consistently with no other state management packages.
4. **Offline caching design**: Reviewed the `CacheService` to ensure data is serialized/deserialized correctly and the staleness check (30-min expiry) works as expected.
5. **API choice**: Switched to Open-Meteo to strictly adhere to the requirement of using a free API that does not require any API key or registration.
6. **Navigation architecture**: Decided to use full-screen `SearchView` and `WeatherDetailView` via `Navigator.push` rather than dialogs for better UX.

## AI-Generated Output Rejected or Corrected

1. **Initial suggestion to use OpenWeatherMap**: Corrected to use Open-Meteo to avoid requiring any API key or registration.
2. **Suggested `cached_network_image` dependency**: Removed since we use CupertinoIcons instead of custom icon URLs, avoiding an unnecessary dependency.
3. **Initial mock data approach**: The original codebase had hardcoded mock data for specific cities. This was completely replaced with real API calls.

## How the Final Code Was Verified

1. **Static analysis**: Ran `flutter analyze` — 0 errors, 0 warnings, 0 info items (all deprecated `withOpacity` usages were refactored to `.withValues()`).
2. **Unit tests**: Ran `flutter test` — all tests pass.
3. **Code review**: Manually reviewed all files for proper separation of concerns, no API calls in widgets, and consistent error handling.
4. **Architecture check**: Verified MVVM pattern: Models have no Flutter dependencies, ViewModel only depends on services, Views only depend on ViewModel via Provider.
