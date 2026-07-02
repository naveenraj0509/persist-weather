# Persist Weather

A beautiful Flutter weather application with real-time weather data, 5-day forecasts, city search, and offline caching support.

## Project Overview

Persist Weather is a mobile weather app built with Flutter using the MVVM architecture pattern and Provider for state management. It fetches real weather data from the OpenWeatherMap API and provides a premium, glassmorphic dark UI with smooth animations.

## API Used

- **OpenWeatherMap API** (Free Tier)
  - Current Weather: `GET /data/2.5/weather`
  - 5-Day Forecast: `GET /data/2.5/forecast`
  - No credit card required
  - 60 calls/min, 1M calls/month

## Setup Instructions

### Prerequisites

- Flutter SDK (3.10.8 or later)
- Dart SDK (included with Flutter)
- An OpenWeatherMap API key (free): [Sign up here](https://home.openweathermap.org/users/sign_up)

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

3. **Get your API key:**
   - Sign up at [OpenWeatherMap](https://home.openweathermap.org/users/sign_up)
   - Navigate to [API Keys](https://home.openweathermap.org/api_keys)
   - Copy your API key (may take up to 2 hours to activate for new accounts)

## How to Run the App

Run the app with your API key passed as a compile-time constant:

```bash
flutter run --dart-define=OWM_API_KEY=your_api_key_here
```

### Running on specific platforms

```bash
# iOS
flutter run --dart-define=OWM_API_KEY=your_api_key_here -d ios

# Android
flutter run --dart-define=OWM_API_KEY=your_api_key_here -d android

# Chrome (web)
flutter run --dart-define=OWM_API_KEY=your_api_key_here -d chrome
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
        │   ├── weather_service.dart   # HTTP calls to OpenWeatherMap
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
- **City Search**: Full-screen search with popular cities and recent search history
- **Hourly Forecast**: Next 24 hours in 3-hour intervals
- **5-Day Forecast**: Daily high/low temperatures with conditions
- **Weather Details**: Humidity, pressure, visibility, wind, sunrise/sunset
- **Offline Caching**: Last successful result cached per city
- **Error Handling**: Loading, empty, error, and retry states
- **Premium UI**: Glassmorphic design, twinkling stars, animated backgrounds

## Assumptions

1. Temperature is displayed in Celsius (metric units).
2. Wind speed is displayed in m/s (OpenWeatherMap default for metric).
3. The app defaults to an empty state on first launch — the user must search for a city.
4. Cached data is shown with an offline banner when the network is unavailable.
5. The API key is passed at build time and is never committed to version control.
6. The 5-day forecast groups 3-hour entries by date for daily min/max temperatures.

## Known Limitations

1. **No location-based weather**: The app doesn't use device GPS/location services. Users must search for cities manually.
2. **Weather icons**: Uses CupertinoIcons rather than OpenWeatherMap's icon images for a consistent iOS-style look.
3. **No unit toggle**: Only Celsius is supported (no Fahrenheit toggle).
4. **Cache expiry**: Cached data is considered stale after 30 minutes but is still used as a fallback when offline.
5. **Search is city-name based**: No autocomplete or geocoding — the user must type an exact city name recognized by OpenWeatherMap.
6. **No push notifications or background updates**.
