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
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeNavigation(),
    );
  }
}
