import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/weather_model.dart';
import 'package:intl/intl.dart';

/// Reusable card widget for displaying a single daily forecast entry.
class DailyForecastCard extends StatelessWidget {
  final DailyForecast forecast;
  final bool isActive;

  const DailyForecastCard({
    super.key,
    required this.forecast,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    // Parse the date string to get a day name
    String dayLabel;
    try {
      final date = DateTime.parse(forecast.date);
      final now = DateTime.now();
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        dayLabel = 'Today';
      } else {
        dayLabel = DateFormat('EEE').format(date);
      }
    } catch (_) {
      dayLabel = forecast.date;
    }

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
              dayLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(
              _getWeatherIcon(forecast.condition),
              color: Colors.white,
              size: 24,
            ),
            Column(
              children: [
                Text(
                  '${forecast.tempMax.toStringAsFixed(0)}°',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${forecast.tempMin.toStringAsFixed(0)}°',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
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
