import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import 'widgets/twinkling_stars_background.dart';
import 'widgets/metric_card.dart';

/// Detail view showing comprehensive weather information for a city.
///
/// Displays temperature, feels like, condition, humidity, pressure,
/// visibility, wind speed, sunrise/sunset, and a 5-day daily forecast.
class WeatherDetailView extends StatelessWidget {
  final WeatherModel weather;

  const WeatherDetailView({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TwinklingStarsBackground(
        child: SafeArea(
          child: Column(
            children: [
              // --- Top Bar ---
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(CupertinoIcons.back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        weather.cityName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'Details',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // --- Scrollable Content ---
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                  children: [
                    // --- Main Temperature Card ---
                    _buildTemperatureCard(),
                    const SizedBox(height: 20),

                    // --- Weather Metrics Grid ---
                    _buildSectionTitle('CONDITIONS'),
                    const SizedBox(height: 12),
                    _buildMetricsGrid(),
                    const SizedBox(height: 24),

                    // --- Sun Times ---
                    _buildSectionTitle('SUN'),
                    const SizedBox(height: 12),
                    _buildSunTimesRow(),
                    const SizedBox(height: 24),

                    // --- 5-Day Forecast ---
                    if (weather.dailyForecast.isNotEmpty) ...[
                      _buildSectionTitle('5-DAY FORECAST'),
                      const SizedBox(height: 12),
                      ...weather.dailyForecast.map(
                        (day) => _buildDailyForecastRow(day),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTemperatureCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xDD48319D), Color(0xDD2A2550)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF6E56A3), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Column(
            children: [
              // Temperature
              Text(
                '${weather.temperature.toStringAsFixed(0)}°',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 72,
                  fontWeight: FontWeight.w200,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              // Condition
              Text(
                weather.description.isNotEmpty
                    ? weather.description[0].toUpperCase() +
                        weather.description.substring(1)
                    : weather.condition,
                style: const TextStyle(
                  color: Color(0x99EBEBF5),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              // Feels like + High/Low
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Feels like ${weather.feelsLike.toStringAsFixed(0)}°',
                    style: const TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  Container(width: 1, height: 14, color: Colors.white24),
                  const SizedBox(width: 16),
                  Text(
                    'H:${weather.tempHigh.toStringAsFixed(0)}° L:${weather.tempLow.toStringAsFixed(0)}°',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.0,
      children: [
        MetricCard(
          icon: CupertinoIcons.wind,
          title: 'WIND SPEED',
          value: '${weather.windSpeed.toStringAsFixed(1)} m/s',
          subtitle: '${(weather.windSpeed * 3.6).toStringAsFixed(1)} km/h',
        ),
        MetricCard(
          icon: CupertinoIcons.drop,
          title: 'HUMIDITY',
          value: '${weather.humidity}%',
          subtitle: _getHumidityDescription(weather.humidity),
        ),
        MetricCard(
          icon: CupertinoIcons.gauge,
          title: 'PRESSURE',
          value: '${weather.pressure} hPa',
          subtitle: _getPressureDescription(weather.pressure),
        ),
        MetricCard(
          icon: CupertinoIcons.eye,
          title: 'VISIBILITY',
          value: '${(weather.visibility / 1000).toStringAsFixed(1)} km',
          subtitle: _getVisibilityDescription(weather.visibility),
        ),
      ],
    );
  }

  Widget _buildSunTimesRow() {
    final sunrise = DateTime.tryParse(weather.sunrise) ?? DateTime.now();
    final sunset = DateTime.tryParse(weather.sunset) ?? DateTime.now();
    final sunriseStr = DateFormat('h:mm a').format(sunrise.toLocal());
    final sunsetStr = DateFormat('h:mm a').format(sunset.toLocal());

    return Row(
      children: [
        Expanded(
          child: MetricCard(
            icon: CupertinoIcons.sunrise,
            title: 'SUNRISE',
            value: sunriseStr,
            subtitle: 'Dawn breaks early.',
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: MetricCard(
            icon: CupertinoIcons.sunset,
            title: 'SUNSET',
            value: sunsetStr,
            subtitle: 'Golden hour approaches.',
          ),
        ),
      ],
    );
  }

  Widget _buildDailyForecastRow(DailyForecast day) {
    String dayLabel;
    try {
      final date = DateTime.parse(day.date);
      final now = DateTime.now();
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        dayLabel = 'Today';
      } else {
        dayLabel = DateFormat('EEEE').format(date);
      }
    } catch (_) {
      dayLabel = day.date;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0x2248319D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              dayLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            _getWeatherIcon(day.condition),
            color: Colors.white70,
            size: 22,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              day.description.isNotEmpty
                  ? day.description[0].toUpperCase() + day.description.substring(1)
                  : day.condition,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${day.tempMax.toStringAsFixed(0)}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${day.tempMin.toStringAsFixed(0)}°',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  String _getHumidityDescription(int humidity) {
    if (humidity < 30) return 'Air is very dry.';
    if (humidity < 50) return 'Comfortable humidity level.';
    if (humidity < 70) return 'Moderately humid.';
    return 'High humidity — feels muggy.';
  }

  String _getPressureDescription(int pressure) {
    if (pressure < 1000) return 'Low pressure — storms possible.';
    if (pressure < 1015) return 'Normal atmospheric pressure.';
    return 'High pressure — clear skies likely.';
  }

  String _getVisibilityDescription(int visibility) {
    if (visibility < 1000) return 'Very poor visibility.';
    if (visibility < 5000) return 'Reduced visibility — be cautious.';
    return 'Clear and good visibility.';
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return CupertinoIcons.sun_max_fill;
      case 'sunny':
        return CupertinoIcons.sun_max_fill;
      case 'rain':
      case 'drizzle':
        return CupertinoIcons.cloud_rain_fill;
      case 'clouds':
      case 'cloudy':
        return CupertinoIcons.cloud_fill;
      case 'thunderstorm':
        return CupertinoIcons.cloud_bolt_rain_fill;
      case 'snow':
        return CupertinoIcons.snow;
      case 'mist':
      case 'fog':
      case 'haze':
        return CupertinoIcons.cloud_fog_fill;
      default:
        return CupertinoIcons.cloud_sun_fill;
    }
  }
}
