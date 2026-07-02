class WeatherModel {
  final String cityName;
  final double temperature;
  final String condition;
  final double windSpeed;
  final int humidity;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.windSpeed,
    required this.humidity,
  });

  WeatherModel copyWith({
    String? cityName,
    double? temperature,
    String? condition,
    double? windSpeed,
    int? humidity,
  }) {
    return WeatherModel(
      cityName: cityName ?? this.cityName,
      temperature: temperature ?? this.temperature,
      condition: condition ?? this.condition,
      windSpeed: windSpeed ?? this.windSpeed,
      humidity: humidity ?? this.humidity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'temperature': temperature,
      'condition': condition,
      'windSpeed': windSpeed,
      'humidity': humidity,
    };
  }

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['cityName'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      condition: json['condition'] as String,
      windSpeed: (json['windSpeed'] as num).toDouble(),
      humidity: json['humidity'] as int,
    );
  }
}
