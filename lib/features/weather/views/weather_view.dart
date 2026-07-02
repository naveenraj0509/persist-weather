import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'widgets/twinkling_stars_background.dart';
import 'widgets/stylized_weather_house.dart';
import 'widgets/custom_bottom_nav_bar.dart';
import 'widgets/hourly_forecast_card.dart';
import 'widgets/daily_forecast_card.dart';
import 'widgets/metric_card.dart';
import 'widgets/offline_banner.dart';
import 'search_view.dart';
import 'weather_detail_view.dart';

/// Home screen showing current weather for the selected city.
///
/// Displays temperature, condition, hourly/daily forecasts in a
/// glassmorphic bottom sheet, and a stylized house illustration.
/// Supports loading, empty, error+retry, and offline states.
class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  bool _isHourlyForecast = true;

  @override
  void initState() {
    super.initState();
    // Initialize the ViewModel after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherViewModel>().init();
    });
  }

  void _navigateToSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SearchView()),
    );
  }

  void _navigateToDetail() {
    final weather = context.read<WeatherViewModel>().weather;
    if (weather != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => WeatherDetailView(weather: weather),
        ),
      );
    }
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
            // --- Loading State ---
            if (viewModel.isLoading)
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFA18CFF)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Fetching weather data...',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              )

            // --- Error State ---
            else if (viewModel.errorMessage != null && weather == null)
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
                      const Icon(
                        CupertinoIcons.exclamationmark_triangle,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        viewModel.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF48319D),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(CupertinoIcons.refresh,
                                color: Colors.white, size: 16),
                            label: const Text('Retry',
                                style: TextStyle(color: Colors.white)),
                            onPressed: () => viewModel.retry(),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF6E56A3)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _navigateToSearch,
                            child: const Text('Search City',
                                style: TextStyle(color: Colors.white70)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )

            // --- Empty State (no city loaded yet) ---
            else if (viewModel.isEmpty)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const StylizedWeatherHouse(width: 200, height: 170),
                      const SizedBox(height: 24),
                      const Text(
                        'Welcome to Persist Weather',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Search for a city to see the weather forecast',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF48319D),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(CupertinoIcons.search,
                            color: Colors.white),
                        label: const Text('Search City',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                        onPressed: _navigateToSearch,
                      ),
                    ],
                  ),
                ),
              )

            // --- Weather Data Loaded ---
            else if (weather != null) ...[
              // Primary Weather Data Header
              Positioned(
                top: 76,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    // City Name (tap to search)
                    GestureDetector(
                      onTap: _navigateToSearch,
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
                          const Icon(CupertinoIcons.search,
                              color: Colors.white60, size: 18),
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

              // Stylized 3D House Illustration
              const Positioned(
                top: 260,
                child: StylizedWeatherHouse(),
              ),

              // Error message overlay (for 404 on search while data shown)
              if (viewModel.errorMessage != null)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 40,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xEE3B267B),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: const Color(0xFFFF6B6B), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.info,
                            color: Color(0xFFFF6B6B), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            viewModel.errorMessage!,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => viewModel.retry(),
                          child: const Icon(CupertinoIcons.xmark,
                              color: Colors.white54, size: 14),
                        ),
                      ],
                    ),
                  ),
                ),

              // Sliding Glassmorphic Forecast bottom sheet
              Positioned.fill(
                child: DraggableScrollableSheet(
                  initialChildSize: 0.38,
                  minChildSize: 0.38,
                  maxChildSize: 0.85,
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xEE2E335A),
                            Color(0xFA1C1B33),
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
                          filter:
                              ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: ListView(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(
                                20, 12, 20, 110),
                            children: [
                              // Grabber Handle
                              Center(
                                child: Container(
                                  width: 48,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    borderRadius:
                                        BorderRadius.circular(2.5),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Forecast Tab Headers
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isHourlyForecast = true;
                                      });
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Hourly Forecast',
                                          style: TextStyle(
                                            color: _isHourlyForecast
                                                ? Colors.white
                                                : Colors.white60,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          height: 2,
                                          width: 100,
                                          color: _isHourlyForecast
                                              ? const Color(0xFFA18CFF)
                                              : Colors.transparent,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Weekly Forecast',
                                          style: TextStyle(
                                            color: !_isHourlyForecast
                                                ? Colors.white
                                                : Colors.white60,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          height: 2,
                                          width: 100,
                                          color: !_isHourlyForecast
                                              ? const Color(0xFFA18CFF)
                                              : Colors.transparent,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Horizontal forecast carousel
                              SizedBox(
                                height: 146,
                                child: _isHourlyForecast
                                    ? weather.hourlyForecast.isEmpty
                                        ? const Center(
                                            child: Text(
                                              'No hourly forecast data',
                                              style: TextStyle(
                                                  color: Colors.white54),
                                            ),
                                          )
                                        : ListView.builder(
                                            scrollDirection:
                                                Axis.horizontal,
                                            itemCount: weather
                                                .hourlyForecast.length,
                                            itemBuilder:
                                                (context, index) {
                                              final hourly = weather
                                                  .hourlyForecast[index];
                                              final isNow = index == 0;
                                              return HourlyForecastCard(
                                                forecast: hourly,
                                                isActive: isNow,
                                              );
                                            },
                                          )
                                    : weather.dailyForecast.isEmpty
                                        ? const Center(
                                            child: Text(
                                              'No daily forecast data',
                                              style: TextStyle(
                                                  color: Colors.white54),
                                            ),
                                          )
                                        : ListView.builder(
                                            scrollDirection:
                                                Axis.horizontal,
                                            itemCount: weather
                                                .dailyForecast.length,
                                            itemBuilder:
                                                (context, index) {
                                              final daily = weather
                                                  .dailyForecast[index];
                                              final isActive =
                                                  index == 0;
                                              return DailyForecastCard(
                                                forecast: daily,
                                                isActive: isActive,
                                              );
                                            },
                                          ),
                              ),
                              const SizedBox(height: 24),

                              // Grid of weather metrics (2x2)
                              GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                physics:
                                    const NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 14,
                                childAspectRatio: 1.0,
                                children: [
                                  MetricCard(
                                    icon: CupertinoIcons.wind,
                                    title: 'WIND SPEED',
                                    value:
                                        '${weather.windSpeed.toStringAsFixed(1)} m/s',
                                    subtitle:
                                        '${(weather.windSpeed * 3.6).toStringAsFixed(1)} km/h',
                                  ),
                                  MetricCard(
                                    icon: CupertinoIcons.drop,
                                    title: 'HUMIDITY',
                                    value: '${weather.humidity}%',
                                    subtitle: weather.humidity > 70
                                        ? 'High humidity — feels muggy.'
                                        : 'Comfortable humidity level.',
                                  ),
                                  MetricCard(
                                    icon: CupertinoIcons.thermometer,
                                    title: 'FEELS LIKE',
                                    value:
                                        '${weather.feelsLike.toStringAsFixed(0)}°',
                                    subtitle: weather.feelsLike >
                                            weather.temperature
                                        ? 'Feels warmer due to humidity.'
                                        : 'Similar to actual temperature.',
                                  ),
                                  MetricCard(
                                    icon: CupertinoIcons.gauge,
                                    title: 'PRESSURE',
                                    value: '${weather.pressure} hPa',
                                    subtitle: weather.pressure > 1015
                                        ? 'High pressure — clear skies.'
                                        : 'Normal atmospheric pressure.',
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

            // --- Offline Banner ---
            if (viewModel.isOffline)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: OfflineBanner(),
              ),

            // --- Bottom Navigation Bar ---
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomBottomNavBar(
                onMapPressed: () => viewModel.fetchWeatherForCurrentLocation(),
                onAddPressed: _navigateToSearch,
                onListPressed: _navigateToDetail,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
