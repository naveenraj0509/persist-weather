import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/weather/viewmodels/weather_viewmodel.dart';
import 'features/weather/views/weather_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherViewModel()),
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
