import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(const MurasuApp());
}

class MurasuApp extends StatelessWidget {
  const MurasuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'முரசு - Murasu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
