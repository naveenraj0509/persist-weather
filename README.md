# Persist Weather

A beautiful Flutter weather application with real-time weather data, 5-day forecasts, city search, and offline caching support.

## Project Overview

Persist Weather is a mobile weather app built with Flutter using the MVVM architecture pattern and Provider for state management. It fetches real weather data from the Open-Meteo API and provides a premium, glassmorphic dark UI with smooth animations.

## API Used

- **Open-Meteo Geocoding API**
  - Search cities: `GET https://geocoding-api.open-meteo.com/v1/search`
  - Resolves city names to latitude and longitude coordinates.
  - **No API key required.**

- **Open-Meteo Forecast API**
  - Weather forecast: `GET https://api.open-meteo.com/v1/forecast`
  - Fetches current weather, 24-hour hourly forecast, and 5-day daily forecast.
  - **No API key required.**

## Setup Instructions

### Prerequisites

- Flutter SDK (3.10.8 or later)
- Dart SDK (included with Flutter)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/naveenraj0509/persist-weather.git
   cd persist-weather
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

## How to Run the App

Run the app normally without any special environment variables:

```bash
flutter run
```

### Running on specific platforms

```bash
# iOS
flutter run -d ios

# Android
flutter run -d android

# Chrome (web)
flutter run -d chrome
```

### Running tests

```bash
flutter test
flutter analyze
```

## Architecture

```
lib/
├── main.dart                          # App entry point
└── features/
    └── weather/
        ├── models/                    # Data models
        │   └── weather_model.dart     # WeatherModel, HourlyForecast, DailyForecast
        ├── services/                  # API & cache layer
        │   ├── weather_service.dart   # HTTP calls to Open-Meteo
        │   └── cache_service.dart     # SharedPreferences caching
        ├── viewmodels/                # Business logic
        │   └── weather_viewmodel.dart # ChangeNotifier state management
        └── views/                     # UI layer
            ├── weather_view.dart      # Home screen
            ├── search_view.dart       # City search screen
            ├── weather_detail_view.dart # Weather details screen
            └── widgets/               # Reusable components
                ├── twinkling_stars_background.dart
                ├── stylized_weather_house.dart
                ├── custom_bottom_nav_bar.dart
                ├── hourly_forecast_card.dart
                ├── daily_forecast_card.dart
                ├── metric_card.dart
                └── offline_banner.dart
```

## Key Features

- **Current Weather**: Real-time temperature, condition, and city info
- **City Search**: Full-screen search with popular cities and recent search history (via Open-Meteo Geocoding)
- **Hourly Forecast**: Next 8 hours in 1-hour intervals
- **5-Day Forecast**: Daily high/low temperatures with conditions
- **Weather Details**: Humidity, pressure, visibility, wind speed, sunrise/sunset
- **Offline Caching**: Last successful result cached per city using `SharedPreferences`
- **Error Handling**: Loading, empty, error, and retry states
- **Premium UI**: Glassmorphic design, twinkling stars, animated backgrounds

## Assumptions

1. Temperature is displayed in Celsius (metric units).
2. Wind speed is displayed in km/h.
3. The app defaults to an empty state on first launch — the user must search for a city.
4. Cached data is shown with an offline banner when the network is unavailable.
5. Cached data is considered stale after 30 minutes but is still used as a fallback when offline.

## Known Limitations

1. **No location-based weather**: The app doesn't use device GPS/location services. Users must search for cities manually.
2. **Weather icons**: Uses CupertinoIcons rather than external images for a consistent iOS-style look.
3. **No unit toggle**: Only Celsius is supported (no Fahrenheit toggle).
4. **Search matches**: Since it uses Open-Meteo's geocoding API, spelling matches the first result returned by the service.
5. **No push notifications or background updates**.
