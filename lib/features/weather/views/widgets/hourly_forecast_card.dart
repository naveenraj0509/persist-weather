import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/weather_model.dart';

/// Reusable card widget for displaying a single hourly forecast entry.
class HourlyForecastCard extends StatelessWidget {
  final HourlyForecast forecast;
  final bool isActive;

  const HourlyForecastCard({
    super.key,
    required this.forecast,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 65,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF48319D) : const Color(0x2248319D),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isActive ? const Color(0xFFA18CFF) : Colors.white.withOpacity(0.12),
          width: isActive ? 2.0 : 1.0,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF612FAB).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              forecast.time,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            Column(
              children: [
                Icon(
                  _getWeatherIcon(forecast.condition),
                  color: Colors.white,
                  size: 24,
                ),
                if (forecast.rainChance > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${forecast.rainChance}%',
                    style: const TextStyle(
                      color: Color(0xFF40C4FF),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            Text(
              '${forecast.temperature.toStringAsFixed(0)}°',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
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
