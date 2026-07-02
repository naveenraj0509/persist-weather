/// Represents current weather data for a city.
///
/// Maps to the OpenWeatherMap `/data/2.5/weather` API response.
class WeatherModel {
  final String cityName;
  final double temperature;
  final double feelsLike;
  final String condition;
  final String description;
  final String weatherIcon;
  final double windSpeed;
  final int humidity;
  final double tempHigh;
  final double tempLow;
  final int pressure;
  final int visibility;
  final int sunrise;
  final int sunset;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.description,
    required this.weatherIcon,
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
    double? temperature,
    double? feelsLike,
    String? condition,
    String? description,
    String? weatherIcon,
    double? windSpeed,
    int? humidity,
    double? tempHigh,
    double? tempLow,
    int? pressure,
    int? visibility,
    int? sunrise,
    int? sunset,
    List<HourlyForecast>? hourlyForecast,
    List<DailyForecast>? dailyForecast,
  }) {
    return WeatherModel(
      cityName: cityName ?? this.cityName,
      temperature: temperature ?? this.temperature,
      feelsLike: feelsLike ?? this.feelsLike,
      condition: condition ?? this.condition,
      description: description ?? this.description,
      weatherIcon: weatherIcon ?? this.weatherIcon,
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

  /// Creates a [WeatherModel] from combined current weather + forecast JSON.
  ///
  /// [currentJson] maps to `/data/2.5/weather` response.
  /// [forecastJson] maps to `/data/2.5/forecast` response.
  factory WeatherModel.fromApiResponses(
    Map<String, dynamic> currentJson,
    Map<String, dynamic> forecastJson,
  ) {
    final main = currentJson['main'] as Map<String, dynamic>;
    final weather = (currentJson['weather'] as List).first as Map<String, dynamic>;
    final wind = currentJson['wind'] as Map<String, dynamic>;
    final sys = currentJson['sys'] as Map<String, dynamic>;

    // Parse hourly forecast (next 8 entries = ~24 hours)
    final forecastList = (forecastJson['list'] as List)
        .take(8)
        .map((e) => HourlyForecast.fromForecastJson(e as Map<String, dynamic>))
        .toList();

    // Parse daily forecast (group by date, aggregate min/max temps)
    final dailyForecast = _parseDailyForecast(forecastJson['list'] as List);

    return WeatherModel(
      cityName: currentJson['name'] as String,
      temperature: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      condition: weather['main'] as String,
      description: weather['description'] as String,
      weatherIcon: weather['icon'] as String,
      windSpeed: (wind['speed'] as num).toDouble(),
      humidity: (main['humidity'] as num).toInt(),
      tempHigh: (main['temp_max'] as num).toDouble(),
      tempLow: (main['temp_min'] as num).toDouble(),
      pressure: (main['pressure'] as num).toInt(),
      visibility: (currentJson['visibility'] as num?)?.toInt() ?? 10000,
      sunrise: (sys['sunrise'] as num).toInt(),
      sunset: (sys['sunset'] as num).toInt(),
      hourlyForecast: forecastList,
      dailyForecast: dailyForecast,
    );
  }

  /// Groups the 3-hour forecast entries by date and aggregates into daily forecasts.
  static List<DailyForecast> _parseDailyForecast(List forecastList) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final entry in forecastList) {
      final map = entry as Map<String, dynamic>;
      final dtTxt = map['dt_txt'] as String;
      final dateKey = dtTxt.split(' ')[0]; // "YYYY-MM-DD"

      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(map);
    }

    final List<DailyForecast> dailyForecasts = [];
    for (final entry in grouped.entries) {
      if (dailyForecasts.length >= 5) break;

      final items = entry.value;
      double maxTemp = double.negativeInfinity;
      double minTemp = double.infinity;
      // Use the midday entry (or first available) for condition/icon
      Map<String, dynamic>? representativeEntry;

      for (final item in items) {
        final main = item['main'] as Map<String, dynamic>;
        final tempMax = (main['temp_max'] as num).toDouble();
        final tempMin = (main['temp_min'] as num).toDouble();
        if (tempMax > maxTemp) maxTemp = tempMax;
        if (tempMin < minTemp) minTemp = tempMin;

        // Prefer the 12:00 or 15:00 entry as representative
        final dtTxt = item['dt_txt'] as String;
        if (dtTxt.contains('12:00') || dtTxt.contains('15:00')) {
          representativeEntry = item;
        }
      }
      representativeEntry ??= items.first;
      final weather = (representativeEntry['weather'] as List).first
          as Map<String, dynamic>;

      dailyForecasts.add(DailyForecast(
        date: entry.key,
        tempMax: maxTemp,
        tempMin: minTemp,
        condition: weather['main'] as String,
        description: weather['description'] as String,
        icon: weather['icon'] as String,
      ));
    }

    return dailyForecasts;
  }

  /// Serializes to JSON for local cache storage.
  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'temperature': temperature,
      'feelsLike': feelsLike,
      'condition': condition,
      'description': description,
      'weatherIcon': weatherIcon,
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
      temperature: (json['temperature'] as num).toDouble(),
      feelsLike: (json['feelsLike'] as num?)?.toDouble() ?? (json['temperature'] as num).toDouble(),
      condition: json['condition'] as String,
      description: json['description'] as String? ?? json['condition'] as String,
      weatherIcon: json['weatherIcon'] as String? ?? '01d',
      windSpeed: (json['windSpeed'] as num).toDouble(),
      humidity: json['humidity'] as int,
      tempHigh: (json['tempHigh'] as num).toDouble(),
      tempLow: (json['tempLow'] as num).toDouble(),
      pressure: (json['pressure'] as num?)?.toInt() ?? 1013,
      visibility: (json['visibility'] as num?)?.toInt() ?? 10000,
      sunrise: (json['sunrise'] as num?)?.toInt() ?? 0,
      sunset: (json['sunset'] as num?)?.toInt() ?? 0,
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

  /// Returns the OpenWeatherMap icon URL for the current weather.
  String get iconUrl => 'https://openweathermap.org/img/wn/$weatherIcon@2x.png';
}

/// Represents a single 3-hour forecast entry.
class HourlyForecast {
  final String time;
  final double temperature;
  final String condition;
  final String icon;
  final int rainChance;
  final DateTime dateTime;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.condition,
    required this.icon,
    required this.rainChance,
    required this.dateTime,
  });

  /// Creates from a single entry in the `/data/2.5/forecast` `list` array.
  factory HourlyForecast.fromForecastJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    final dt = json['dt'] as int;
    final dateTime = DateTime.fromMillisecondsSinceEpoch(dt * 1000);

    // Rain probability comes from `pop` field (0.0 to 1.0)
    final pop = (json['pop'] as num?)?.toDouble() ?? 0.0;

    return HourlyForecast(
      time: '${dateTime.hour.toString().padLeft(2, '0')}:00',
      temperature: (main['temp'] as num).toDouble(),
      condition: weather['main'] as String,
      icon: weather['icon'] as String,
      rainChance: (pop * 100).round(),
      dateTime: dateTime,
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'temperature': temperature,
      'condition': condition,
      'icon': icon,
      'rainChance': rainChance,
      'dateTime': dateTime.millisecondsSinceEpoch,
    };
  }

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: json['time'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      condition: json['condition'] as String,
      icon: json['icon'] as String? ?? '01d',
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
  final String icon;

  DailyForecast({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.condition,
    required this.description,
    required this.icon,
  });

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'tempMax': tempMax,
      'tempMin': tempMin,
      'condition': condition,
      'description': description,
      'icon': icon,
    };
  }

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: json['date'] as String? ?? json['day'] as String,
      tempMax: (json['tempMax'] as num).toDouble(),
      tempMin: (json['tempMin'] as num).toDouble(),
      condition: json['condition'] as String,
      description: json['description'] as String? ?? json['condition'] as String,
      icon: json['icon'] as String? ?? '01d',
    );
  }
}
