import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/weather_viewmodel.dart';

class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  final TextEditingController _cityController = TextEditingController();

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  // Returns gradient based on weather condition
  LinearGradient _getBackgroundGradient(String? condition) {
    if (condition == null) {
      return const LinearGradient(
        colors: [Color(0xFF2E3B4E), Color(0xFF1F2833)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }

    switch (condition.toLowerCase()) {
      case 'sunny':
        return const LinearGradient(
          colors: [Color(0xFFFF9900), Color(0xFFFF5E62)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'rainy':
        return const LinearGradient(
          colors: [Color(0xFF3A6073), Color(0xFF16222F)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'cloudy':
      case 'partly cloudy':
        return const LinearGradient(
          colors: [Color(0xFF617C8A), Color(0xFF2C3E50)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        );
      case 'windy':
        return const LinearGradient(
          colors: [Color(0xFF757F9A), Color(0xFFD7DDE8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
    }
  }

  IconData _getWeatherIcon(String? condition) {
    if (condition == null) return Icons.cloud_outlined;
    switch (condition.toLowerCase()) {
      case 'sunny':
        return Icons.wb_sunny_rounded;
      case 'rainy':
        return Icons.grain_rounded;
      case 'cloudy':
      case 'partly cloudy':
        return Icons.cloud_rounded;
      case 'windy':
        return Icons.wind_power_rounded;
      default:
        return Icons.wb_cloudy_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WeatherViewModel>();
    final weather = viewModel.weather;
    final gradient = _getBackgroundGradient(weather?.condition);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Persist Weather',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                    ),
                    if (weather != null)
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: () {
                          viewModel.fetchWeather(weather.cityName);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 24.0),

                // Search Box
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0x26FFFFFF),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: const Color(0x33FFFFFF)),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Icon(Icons.search, color: Colors.white70),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _cityController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Search city (e.g., Tokyo, London, Paris)',
                            hintStyle: TextStyle(color: Colors.white60),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                          ),
                          onSubmitted: (value) {
                            viewModel.fetchWeather(value);
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                        onPressed: () {
                          viewModel.fetchWeather(_cityController.text);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32.0),

                // Content Area
                Expanded(
                  child: Center(
                    child: Builder(
                      builder: (context) {
                        if (viewModel.isLoading) {
                          return const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                              SizedBox(height: 16.0),
                              Text(
                                'Loading weather forecast...',
                                style: TextStyle(color: Colors.white70, fontSize: 16.0),
                              ),
                            ],
                          );
                        }

                        if (viewModel.errorMessage != null) {
                          return Container(
                            padding: const EdgeInsets.all(24.0),
                            decoration: BoxDecoration(
                              color: const Color(0x33FF5252),
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(color: const Color(0x80FF5252)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Colors.white, size: 48.0),
                                const SizedBox(height: 16.0),
                                Text(
                                  viewModel.errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (weather == null) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.cloud_queue_rounded,
                                size: 80.0,
                                color: Color(0x99FFFFFF),
                              ),
                              const SizedBox(height: 16.0),
                              const Text(
                                'Find weather info for any city',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              const Text(
                                'Search above to get started',
                                style: TextStyle(
                                  color: Color(0x80FFFFFF),
                                  fontSize: 14.0,
                                ),
                              ),
                            ],
                          );
                        }

                        // Weather Display Card (Glassmorphic effect)
                        return SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // City Name
                              Text(
                                weather.cityName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16.0),

                              // Weather Icon
                              Icon(
                                _getWeatherIcon(weather.condition),
                                size: 100.0,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 16.0),

                              // Temperature
                              Text(
                                '${weather.temperature.toStringAsFixed(1)}°C',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 64.0,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                              const SizedBox(height: 8.0),

                              // Condition Description
                              Text(
                                weather.condition,
                                style: const TextStyle(
                                  color: Color(0xE6FFFFFF),
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 40.0),

                              // Additional Details Card
                              Container(
                                padding: const EdgeInsets.all(20.0),
                                decoration: BoxDecoration(
                                  color: const Color(0x1AFFFFFF),
                                  borderRadius: BorderRadius.circular(24.0),
                                  border: Border.all(color: const Color(0x26FFFFFF)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildDetailItem(
                                      icon: Icons.water_drop_outlined,
                                      label: 'Humidity',
                                      value: '${weather.humidity}%',
                                    ),
                                    Container(
                                      height: 40.0,
                                      width: 1.0,
                                      color: Colors.white24,
                                    ),
                                    _buildDetailItem(
                                      icon: Icons.air_rounded,
                                      label: 'Wind Speed',
                                      value: '${weather.windSpeed.toStringAsFixed(1)} km/h',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 28.0),
        const SizedBox(height: 8.0),
        Text(
          label,
          style: const TextStyle(color: Color(0x80FFFFFF), fontSize: 12.0),
        ),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
