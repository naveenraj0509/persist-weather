import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/weather_viewmodel.dart';
import '../models/weather_model.dart';
import 'widgets/twinkling_stars_background.dart';
import 'widgets/stylized_weather_house.dart';
import 'widgets/custom_bottom_nav_bar.dart';

class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isHourlyForecast = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Returns weather icon mapping for high-fidelity look
  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
        return CupertinoIcons.sun_max_fill;
      case 'rainy':
        return CupertinoIcons.cloud_rain_fill;
      case 'cloudy':
        return CupertinoIcons.cloud_fill;
      case 'partly cloudy':
        return CupertinoIcons.cloud_sun_fill;
      case 'mostly clear':
      case 'clear':
        return CupertinoIcons.cloud_moon_fill;
      case 'windy':
        return CupertinoIcons.wind;
      default:
        return CupertinoIcons.cloud_sun_fill;
    }
  }

  // Show a beautiful glassmorphic search overlay dialog
  void _showSearchDialog(BuildContext context) {
    final viewModel = context.read<WeatherViewModel>();
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AlertDialog(
            backgroundColor: const Color(0xEE2A2550),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
              side: const BorderSide(color: Color(0xFF6E56A3), width: 1.5),
            ),
            title: const Text(
              'Search Weather',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter city (e.g., London, Tokyo...)',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(CupertinoIcons.search, color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0x331C1B33),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF6E56A3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFA18CFF), width: 2),
                    ),
                  ),
                  onSubmitted: (value) {
                    viewModel.fetchWeather(value);
                    Navigator.of(context).pop();
                    _searchController.clear();
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Popular Cities',
                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'Montreal',
                    'New York',
                    'London',
                    'Tokyo',
                    'Paris',
                  ].map((city) {
                    return GestureDetector(
                      onTap: () {
                        viewModel.fetchWeather(city);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0x4448319D),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0x80A18CFF)),
                        ),
                        child: Text(
                          city,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF48319D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Search'),
                onPressed: () {
                  viewModel.fetchWeather(_searchController.text);
                  Navigator.of(context).pop();
                  _searchController.clear();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WeatherViewModel>();
    final weather = viewModel.weather;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: TwinklingStarsBackground(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // 1. App Content Area (Upper half)
            if (viewModel.isLoading)
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA18CFF)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Updating weather forecast...',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              )
            else if (viewModel.errorMessage != null)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xBB3B267B),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF6E56A3)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.exclamationmark_triangle, color: Colors.white, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        viewModel.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF48319D),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => viewModel.fetchWeather('Montreal'),
                        child: const Text('Reset to Montreal', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              )
            else if (weather != null) ...[
              // Primary Weather Data Header
              Positioned(
                top: 76,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    // City Name
                    GestureDetector(
                      onTap: () => _showSearchDialog(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            weather.cityName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.37,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(CupertinoIcons.search, color: Colors.white60, size: 18),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Temperature
                    Text(
                      '${weather.temperature.toStringAsFixed(0)}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 96,
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w200,
                        height: 1.0,
                        letterSpacing: 0.37,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Weather Condition
                    Text(
                      weather.condition,
                      style: const TextStyle(
                        color: Color(0x99EBEBF5),
                        fontSize: 20,
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.38,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // High & Low Temperature
                    Text(
                      'H:${weather.tempHigh.toStringAsFixed(0)}°   L:${weather.tempLow.toStringAsFixed(0)}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.38,
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Stylized 3D House Illustration (Centered)
              const Positioned(
                top: 260,
                child: StylizedWeatherHouse(),
              ),

              // 3. Sliding Glassmorphic Forecast bottom sheet
              Positioned.fill(
                child: DraggableScrollableSheet(
                  initialChildSize: 0.38,
                  minChildSize: 0.38,
                  maxChildSize: 0.85,
                  builder: (BuildContext context, ScrollController scrollController) {
                    return Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xEE2E335A), // Semi-transparent top
                            Color(0xFA1C1B33), // Dark solid base
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(44),
                          topRight: Radius.circular(44),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 20,
                            offset: Offset(0, -5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(44),
                          topRight: Radius.circular(44),
                        ),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: ListView(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
                            children: [
                              // Grabber Handle
                              Center(
                                child: Container(
                                  width: 48,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(2.5),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Forecast Tab Headers
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isHourlyForecast = true;
                                      });
                                    },
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Hourly Forecast',
                                          style: TextStyle(
                                            color: _isHourlyForecast ? Colors.white : Colors.white60,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          height: 2,
                                          width: 100,
                                          color: _isHourlyForecast ? const Color(0xFFA18CFF) : Colors.transparent,
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isHourlyForecast = false;
                                      });
                                    },
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Weekly Forecast',
                                          style: TextStyle(
                                            color: !_isHourlyForecast ? Colors.white : Colors.white60,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          height: 2,
                                          width: 100,
                                          color: !_isHourlyForecast ? const Color(0xFFA18CFF) : Colors.transparent,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Horizontal forecast carousel list
                              SizedBox(
                                height: 146,
                                child: _isHourlyForecast
                                    ? ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: weather.hourlyForecast.length,
                                        itemBuilder: (context, index) {
                                          final hourly = weather.hourlyForecast[index];
                                          // Highlight the card labeled 'Now'
                                          final isNow = hourly.time.toLowerCase() == 'now';
                                          return _buildHourlyCard(hourly, isNow);
                                        },
                                      )
                                    : ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: weather.weeklyForecast.length,
                                        itemBuilder: (context, index) {
                                          final weekly = weather.weeklyForecast[index];
                                          // Highlight first day as active
                                          final isActive = index == 0;
                                          return _buildWeeklyCard(weekly, isActive);
                                        },
                                      ),
                              ),
                              const SizedBox(height: 24),

                              // Grid of weather metrics (2x2)
                              GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 14,
                                childAspectRatio: 1.0,
                                children: [
                                  _buildMetricCard(
                                    icon: CupertinoIcons.wind,
                                    title: 'WIND SPEED',
                                    value: '${weather.windSpeed.toStringAsFixed(1)} km/h',
                                    subtitle: 'Current direction: NE',
                                  ),
                                  _buildMetricCard(
                                    icon: CupertinoIcons.drop,
                                    title: 'HUMIDITY',
                                    value: '${weather.humidity}%',
                                    subtitle: 'The dew point is 12° right now.',
                                  ),
                                  _buildMetricCard(
                                    icon: CupertinoIcons.sun_max,
                                    title: 'UV INDEX',
                                    value: '3',
                                    subtitle: 'Moderate levels during mid-day.',
                                  ),
                                  _buildMetricCard(
                                    icon: CupertinoIcons.sunrise,
                                    title: 'SUNRISE',
                                    value: '6:05 AM',
                                    subtitle: 'Sunset expected at 8:41 PM.',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            // 4. CURVED BOTTOM NAVIGATION BAR (Anchored at the very bottom)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomBottomNavBar(
                onMapPressed: () => _showSearchDialog(context),
                onAddPressed: () => _showSearchDialog(context),
                onListPressed: () => _showSearchDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hourly forecast Card UI builder
  Widget _buildHourlyCard(HourlyForecast forecast, bool isActive) {
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

  // Weekly forecast Card UI builder
  Widget _buildWeeklyCard(WeeklyForecast forecast, bool isActive) {
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
              forecast.day,
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

  // Weather Metrics Card UI builder
  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      decoration: ShapeDecoration(
        color: const Color(0x2248319D),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Colors.white.withOpacity(0.15)),
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Internal soft gradient glow
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF612FAB).withOpacity(0.15),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: Colors.white60, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
