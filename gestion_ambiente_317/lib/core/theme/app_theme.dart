import 'package:flutter/material.dart';

class AppTheme {
  static const Color azulSena = Color(0xFF00324D);
  static const Color verdeOperativo = Color(0xFF2E7D32);
  static const Color rojoFalla = Color(0xFFC62828);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: azulSena,
      scaffoldBackgroundColor: const Color(0xFFF4F6F8),
      appBarTheme: const AppBarTheme(
        backgroundColor: azulSena,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: azulSena,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        ),
      ),
    );
  }
}