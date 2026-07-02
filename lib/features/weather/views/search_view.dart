import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'widgets/twinkling_stars_background.dart';

/// Full-screen search view for searching and selecting a city.
///
/// Features a text input, popular cities chips, and recent search history.
/// On city selection, fetches weather and navigates back to the home screen.
class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  static const List<String> _popularCities = [
    'London',
    'New York',
    'Tokyo',
    'Paris',
    'Sydney',
    'Dubai',
    'Singapore',
    'Mumbai',
    'Toronto',
    'Berlin',
  ];

  @override
  void initState() {
    super.initState();
    // Auto-focus the search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onCitySelected(String city) {
    final viewModel = context.read<WeatherViewModel>();
    viewModel.fetchWeather(city);
    Navigator.of(context).pop();
  }

  void _onSearchSubmitted() {
    final city = _searchController.text.trim();
    if (city.isNotEmpty) {
      _onCitySelected(city);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WeatherViewModel>();
    final recentCities = viewModel.recentCities;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: TwinklingStarsBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    const Text(
                      'Search City',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- Search Field ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0x332A2550),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF6E56A3), width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Enter city name...',
                          hintStyle: const TextStyle(color: Colors.white38),
                          prefixIcon: const Icon(CupertinoIcons.search, color: Colors.white54),
                          suffixIcon: IconButton(
                            icon: const Icon(CupertinoIcons.arrow_right_circle_fill,
                                color: Color(0xFFA18CFF)),
                            onPressed: _onSearchSubmitted,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onSubmitted: (_) => _onSearchSubmitted(),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // --- Scrollable content ---
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Recent Cities
                    if (recentCities.isNotEmpty) ...[
                      const Text(
                        'RECENT',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...recentCities.map(
                        (city) => _buildCityTile(city, isRecent: true),
                      ),
                      const SizedBox(height: 28),
                    ],

                    // Popular Cities
                    const Text(
                      'POPULAR CITIES',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _popularCities
                          .map((city) => _buildCityChip(city))
                          .toList(),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityTile(String city, {bool isRecent = false}) {
    return GestureDetector(
      onTap: () => _onCitySelected(city),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0x2248319D),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Icon(
              isRecent ? CupertinoIcons.clock : CupertinoIcons.location,
              color: Colors.white54,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                city,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: Colors.white24,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityChip(String city) {
    return GestureDetector(
      onTap: () => _onCitySelected(city),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0x4448319D),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0x80A18CFF)),
        ),
        child: Text(
          city,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
