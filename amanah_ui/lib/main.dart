import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF3F4F6), // Light Grey
        fontFamily: GoogleFonts.inter().fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1D1D1B),
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xFF1D1D1B), // Deep Ink
          secondary: const Color(0xFF64748B), // Slate
          surface: Colors.white.withOpacity(0.4),
          onSurface: const Color(0xFF1D1D1B),
        ),
        textTheme: GoogleFonts.loraTextTheme().copyWith(
          displayLarge: GoogleFonts.lora(
            fontSize: 40, 
            fontWeight: FontWeight.w900, 
            letterSpacing: -1.5, 
            color: const Color(0xFF1D1D1B),
          ),
          headlineMedium: GoogleFonts.lora(
            fontSize: 28, 
            fontWeight: FontWeight.w800, 
            color: const Color(0xFF1D1D1B),
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 16, 
            color: const Color(0xFF1D1D1B).withOpacity(0.8),
            height: 1.5,
          ),
          labelLarge: GoogleFonts.inter(
            fontSize: 13, 
            fontWeight: FontWeight.w900, 
            letterSpacing: 2.0,
            color: const Color(0xFF1D1D1B),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.w900, 
            letterSpacing: 4, 
            color: Color(0xFF1D1D1B),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1D1D1B),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
            textStyle: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20), 
            borderSide: const BorderSide(color: Color(0xFF1D1D1B), width: 1.5),
          ),
          hintStyle: TextStyle(color: const Color(0xFF1D1D1B).withOpacity(0.3)),
        ),
      ),
      home: const HomeNavigation(),
    );
  }
}

