import 'package:flutter/material.dart';
import 'screens/home_navigation.dart';

void main() {
  runApp(const AmanahBotApp());
}

class AmanahBotApp extends StatelessWidget {
  const AmanahBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Amanah-Bot EaaS',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF010208), // Near black
        fontFamily: 'Inter', // High-end typography
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Indigo
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFF6366F1),
          secondary: const Color(0xFF8B5CF6), // Purple
          tertiary: const Color(0xFF10B981), // Emerald
          surface: const Color(0xFF030712),
          onSurface: Colors.white,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1.5, color: Colors.white),
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
          labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2.0),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 4, color: Colors.white70),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
            shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.3),
            textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.03),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20), 
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2)
          ),
          hintStyle: const TextStyle(color: Colors.white24),
        ),
      ),
      home: const HomeNavigation(),
    );
  }
}

