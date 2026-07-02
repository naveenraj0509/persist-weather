/// Represents current weather data for a city.
///
/// Maps to the Open-Meteo forecast API response (no API key needed).
class WeatherModel {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final String condition;
  final String description;
  final int weatherCode;
  final double windSpeed;
  final int humidity;
  final double tempHigh;
  final double tempLow;
  final int pressure;
  final int visibility;
  final String sunrise;
  final String sunset;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;

  WeatherModel({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.description,
    required this.weatherCode,
    required this.windSpeed,
    required this.humidity,
    required this.tempHigh,
    required this.tempLow,
    required this.pressure,
    required this.visibility,
    required this.sunrise,
    required this.sunset,
    required this.hourlyForecast,
    required this.dailyForecast,
  });

  WeatherModel copyWith({
    String? cityName,
    String? country,
    double? temperature,
    double? feelsLike,
    String? condition,
    String? description,
    int? weatherCode,
    double? windSpeed,
    int? humidity,
    double? tempHigh,
    double? tempLow,
    int? pressure,
    int? visibility,
    String? sunrise,
    String? sunset,
    List<HourlyForecast>? hourlyForecast,
    List<DailyForecast>? dailyForecast,
  }) {
    return WeatherModel(
      cityName: cityName ?? this.cityName,
      country: country ?? this.country,
      temperature: temperature ?? this.temperature,
      feelsLike: feelsLike ?? this.feelsLike,
      condition: condition ?? this.condition,
      description: description ?? this.description,
      weatherCode: weatherCode ?? this.weatherCode,
      windSpeed: windSpeed ?? this.windSpeed,
      humidity: humidity ?? this.humidity,
      tempHigh: tempHigh ?? this.tempHigh,
      tempLow: tempLow ?? this.tempLow,
      pressure: pressure ?? this.pressure,
      visibility: visibility ?? this.visibility,
      sunrise: sunrise ?? this.sunrise,
      sunset: sunset ?? this.sunset,
      hourlyForecast: hourlyForecast ?? this.hourlyForecast,
      dailyForecast: dailyForecast ?? this.dailyForecast,
    );
  }

  /// Creates a [WeatherModel] from the Open-Meteo forecast API response
  /// combined with geocoding data.
  ///
  /// [forecastJson] is the full response from `/v1/forecast`.
  /// [geoData] is a single result from the geocoding API.
  factory WeatherModel.fromOpenMeteo(
    Map<String, dynamic> forecastJson,
    Map<String, dynamic> geoData,
  ) {
    final current = forecastJson['current'] as Map<String, dynamic>;
    final hourly = forecastJson['hourly'] as Map<String, dynamic>;
    final daily = forecastJson['daily'] as Map<String, dynamic>;

    // Current weather code
    final currentCode = (current['weather_code'] as num).toInt();

    // Parse hourly forecast — take next 8 hours from current time
    final hourlyTimes = (hourly['time'] as List).cast<String>();
    final hourlyTemps = (hourly['temperature_2m'] as List);
    final hourlyCodes = (hourly['weather_code'] as List);
    final hourlyPrecip = (hourly['precipitation_probability'] as List);

    // Find the current hour index
    final now = DateTime.now();
    int startIndex = 0;
    for (int i = 0; i < hourlyTimes.length; i++) {
      final hourTime = DateTime.parse(hourlyTimes[i]);
      if (hourTime.isAfter(now) || hourTime.isAtSameMomentAs(now)) {
        startIndex = i > 0 ? i - 1 : 0;
        break;
      }
    }

    final List<HourlyForecast> hourlyList = [];
    for (int i = startIndex; i < hourlyTimes.length && hourlyList.length < 8; i++) {
      final dt = DateTime.parse(hourlyTimes[i]);
      final code = (hourlyCodes[i] as num).toInt();
      hourlyList.add(HourlyForecast(
        time: i == startIndex ? 'Now' : '${dt.hour.toString().padLeft(2, '0')}:00',
        temperature: (hourlyTemps[i] as num).toDouble(),
        condition: _wmoCondition(code),
        weatherCode: code,
        rainChance: (hourlyPrecip[i] as num).toInt(),
        dateTime: dt,
      ));
    }

    // Parse daily forecast
    final dailyTimes = (daily['time'] as List).cast<String>();
    final dailyMaxTemps = (daily['temperature_2m_max'] as List);
    final dailyMinTemps = (daily['temperature_2m_min'] as List);
    final dailyCodes = (daily['weather_code'] as List);
    final dailySunrises = (daily['sunrise'] as List).cast<String>();
    final dailySunsets = (daily['sunset'] as List).cast<String>();

    final List<DailyForecast> dailyList = [];
    for (int i = 0; i < dailyTimes.length && i < 5; i++) {
      final code = (dailyCodes[i] as num).toInt();
      dailyList.add(DailyForecast(
        date: dailyTimes[i],
        tempMax: (dailyMaxTemps[i] as num).toDouble(),
        tempMin: (dailyMinTemps[i] as num).toDouble(),
        condition: _wmoCondition(code),
        description: _wmoDescription(code),
        weatherCode: code,
      ));
    }

    return WeatherModel(
      cityName: geoData['name'] as String,
      country: geoData['country'] as String? ?? '',
      temperature: (current['temperature_2m'] as num).toDouble(),
      feelsLike: (current['apparent_temperature'] as num).toDouble(),
      condition: _wmoCondition(currentCode),
      description: _wmoDescription(currentCode),
      weatherCode: currentCode,
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      tempHigh: dailyList.isNotEmpty ? dailyList[0].tempMax : (current['temperature_2m'] as num).toDouble(),
      tempLow: dailyList.isNotEmpty ? dailyList[0].tempMin : (current['temperature_2m'] as num).toDouble(),
      pressure: (current['surface_pressure'] as num).toInt(),
      visibility: (current['visibility'] as num?)?.toInt() ?? 10000,
      sunrise: dailySunrises.isNotEmpty ? dailySunrises[0] : '',
      sunset: dailySunsets.isNotEmpty ? dailySunsets[0] : '',
      hourlyForecast: hourlyList,
      dailyForecast: dailyList,
    );
  }

  /// Serializes to JSON for local cache storage.
  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'country': country,
      'temperature': temperature,
      'feelsLike': feelsLike,
      'condition': condition,
      'description': description,
      'weatherCode': weatherCode,
      'windSpeed': windSpeed,
      'humidity': humidity,
      'tempHigh': tempHigh,
      'tempLow': tempLow,
      'pressure': pressure,
      'visibility': visibility,
      'sunrise': sunrise,
      'sunset': sunset,
      'hourlyForecast': hourlyForecast.map((x) => x.toJson()).toList(),
      'dailyForecast': dailyForecast.map((x) => x.toJson()).toList(),
    };
  }

  /// Deserializes from cached JSON.
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['cityName'] as String,
      country: json['country'] as String? ?? '',
      temperature: (json['temperature'] as num).toDouble(),
      feelsLike: (json['feelsLike'] as num?)?.toDouble() ?? (json['temperature'] as num).toDouble(),
      condition: json['condition'] as String,
      description: json['description'] as String? ?? json['condition'] as String,
      weatherCode: (json['weatherCode'] as num?)?.toInt() ?? 0,
      windSpeed: (json['windSpeed'] as num).toDouble(),
      humidity: json['humidity'] as int,
      tempHigh: (json['tempHigh'] as num).toDouble(),
      tempLow: (json['tempLow'] as num).toDouble(),
      pressure: (json['pressure'] as num?)?.toInt() ?? 1013,
      visibility: (json['visibility'] as num?)?.toInt() ?? 10000,
      sunrise: json['sunrise'] as String? ?? '',
      sunset: json['sunset'] as String? ?? '',
      hourlyForecast: (json['hourlyForecast'] as List?)
              ?.map((e) => HourlyForecast.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dailyForecast: (json['dailyForecast'] as List?)
              ?.map((e) => DailyForecast.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Converts WMO weather code to a short condition name.
  static String _wmoCondition(int code) {
    if (code == 0) return 'Clear';
    if (code <= 3) return 'Cloudy';
    if (code <= 49) return 'Fog';
    if (code <= 59) return 'Drizzle';
    if (code <= 69) return 'Rain';
    if (code <= 79) return 'Snow';
    if (code <= 84) return 'Showers';
    if (code <= 89) return 'Snow';
    if (code <= 99) return 'Thunderstorm';
    return 'Unknown';
  }

  /// Converts WMO weather code to a human-readable description.
  static String _wmoDescription(int code) {
    switch (code) {
      case 0:
        return 'Clear sky';
      case 1:
        return 'Mainly clear';
      case 2:
        return 'Partly cloudy';
      case 3:
        return 'Overcast';
      case 45:
        return 'Foggy';
      case 48:
        return 'Depositing rime fog';
      case 51:
        return 'Light drizzle';
      case 53:
        return 'Moderate drizzle';
      case 55:
        return 'Dense drizzle';
      case 56:
        return 'Freezing light drizzle';
      case 57:
        return 'Freezing dense drizzle';
      case 61:
        return 'Slight rain';
      case 63:
        return 'Moderate rain';
      case 65:
        return 'Heavy rain';
      case 66:
        return 'Freezing light rain';
      case 67:
        return 'Freezing heavy rain';
      case 71:
        return 'Slight snowfall';
      case 73:
        return 'Moderate snowfall';
      case 75:
        return 'Heavy snowfall';
      case 77:
        return 'Snow grains';
      case 80:
        return 'Slight rain showers';
      case 81:
        return 'Moderate rain showers';
      case 82:
        return 'Violent rain showers';
      case 85:
        return 'Slight snow showers';
      case 86:
        return 'Heavy snow showers';
      case 95:
        return 'Thunderstorm';
      case 96:
        return 'Thunderstorm with slight hail';
      case 99:
        return 'Thunderstorm with heavy hail';
      default:
        return 'Unknown';
    }
  }
}

/// Represents a single hourly forecast entry.
class HourlyForecast {
  final String time;
  final double temperature;
  final String condition;
  final int weatherCode;
  final int rainChance;
  final DateTime dateTime;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.condition,
    required this.weatherCode,
    required this.rainChance,
    required this.dateTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'temperature': temperature,
      'condition': condition,
      'weatherCode': weatherCode,
      'rainChance': rainChance,
      'dateTime': dateTime.millisecondsSinceEpoch,
    };
  }

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: json['time'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      condition: json['condition'] as String,
      weatherCode: (json['weatherCode'] as num?)?.toInt() ?? 0,
      rainChance: json['rainChance'] as int,
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        (json['dateTime'] as num?)?.toInt() ?? 0,
      ),
    );
  }
}

/// Represents aggregated daily forecast data.
class DailyForecast {
  final String date;
  final double tempMax;
  final double tempMin;
  final String condition;
  final String description;
  final int weatherCode;

  DailyForecast({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.condition,
    required this.description,
    required this.weatherCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'tempMax': tempMax,
      'tempMin': tempMin,
      'condition': condition,
      'description': description,
      'weatherCode': weatherCode,
    };
  }

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: json['date'] as String? ?? json['day'] as String,
      tempMax: (json['tempMax'] as num).toDouble(),
      tempMin: (json['tempMin'] as num).toDouble(),
      condition: json['condition'] as String,
      description: json['description'] as String? ?? json['condition'] as String,
      weatherCode: (json['weatherCode'] as num?)?.toInt() ?? 0,
    );
  }
}
