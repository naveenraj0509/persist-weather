class WeatherModel {
  final String cityName;
  final double temperature;
  final String condition;
  final double windSpeed;
  final int humidity;
  final double tempHigh;
  final double tempLow;
  final List<HourlyForecast> hourlyForecast;
  final List<WeeklyForecast> weeklyForecast;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.windSpeed,
    required this.humidity,
    required this.tempHigh,
    required this.tempLow,
    required this.hourlyForecast,
    required this.weeklyForecast,
  });

  WeatherModel copyWith({
    String? cityName,
    double? temperature,
    String? condition,
    double? windSpeed,
    int? humidity,
    double? tempHigh,
    double? tempLow,
    List<HourlyForecast>? hourlyForecast,
    List<WeeklyForecast>? weeklyForecast,
  }) {
    return WeatherModel(
      cityName: cityName ?? this.cityName,
      temperature: temperature ?? this.temperature,
      condition: condition ?? this.condition,
      windSpeed: windSpeed ?? this.windSpeed,
      humidity: humidity ?? this.humidity,
      tempHigh: tempHigh ?? this.tempHigh,
      tempLow: tempLow ?? this.tempLow,
      hourlyForecast: hourlyForecast ?? this.hourlyForecast,
      weeklyForecast: weeklyForecast ?? this.weeklyForecast,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'temperature': temperature,
      'condition': condition,
      'windSpeed': windSpeed,
      'humidity': humidity,
      'tempHigh': tempHigh,
      'tempLow': tempLow,
      'hourlyForecast': hourlyForecast.map((x) => x.toJson()).toList(),
      'weeklyForecast': weeklyForecast.map((x) => x.toJson()).toList(),
    };
  }

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['cityName'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      condition: json['condition'] as String,
      windSpeed: (json['windSpeed'] as num).toDouble(),
      humidity: json['humidity'] as int,
      tempHigh: (json['tempHigh'] as num?)?.toDouble() ?? (json['temperature'] as num).toDouble() + 4.0,
      tempLow: (json['tempLow'] as num?)?.toDouble() ?? (json['temperature'] as num).toDouble() - 2.0,
      hourlyForecast: (json['hourlyForecast'] as List?)
              ?.map((e) => HourlyForecast.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      weeklyForecast: (json['weeklyForecast'] as List?)
              ?.map((e) => WeeklyForecast.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class HourlyForecast {
  final String time;
  final double temperature;
  final String condition;
  final int rainChance;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.condition,
    required this.rainChance,
  });

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'temperature': temperature,
      'condition': condition,
      'rainChance': rainChance,
    };
  }

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: json['time'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      condition: json['condition'] as String,
      rainChance: json['rainChance'] as int,
    );
  }
}

class WeeklyForecast {
  final String day;
  final double tempMax;
  final double tempMin;
  final String condition;

  WeeklyForecast({
    required this.day,
    required this.tempMax,
    required this.tempMin,
    required this.condition,
  });

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'tempMax': tempMax,
      'tempMin': tempMin,
      'condition': condition,
    };
  }

  factory WeeklyForecast.fromJson(Map<String, dynamic> json) {
    return WeeklyForecast(
      day: json['day'] as String,
      tempMax: (json['tempMax'] as num).toDouble(),
      tempMin: (json['tempMin'] as num).toDouble(),
      condition: json['condition'] as String,
    );
  }
}
