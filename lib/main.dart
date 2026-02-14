import 'package:flutter/material.dart';
import 'screens/calculator_screen.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Калькулятор',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          surface: const Color(0xFF0D0D0F),
          primary: const Color(0xFFE8C547),
          secondary: const Color(0xFF2A2A32),
          tertiary: const Color(0xFF1A1A22),
        ),
      ),
      home: const CalculatorScreen(),
    );
  }
}