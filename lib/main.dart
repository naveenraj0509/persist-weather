import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/weather/services/weather_service.dart';
import 'features/weather/services/cache_service.dart';
import 'features/weather/viewmodels/weather_viewmodel.dart';
import 'features/weather/views/weather_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences before the app starts
  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WeatherViewModel(
            weatherService: WeatherService(),
            cacheService: CacheService(prefs),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Persist Weather',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Inter',
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4A00E0),
            brightness: Brightness.dark,
          ),
        ),
        home: const WeatherView(),
      ),
    );
  }
}
