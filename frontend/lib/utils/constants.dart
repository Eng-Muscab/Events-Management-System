import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppColors {
  static const Color primary = Color(0xFF1018D5); 
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color background = Color(0xFFF3F4F6); // Gray-100
  static const Color textDark = Color(0xFF111827);
  static const Color textGray = Color(0xFF6B7280);
  static const Color white = Colors.white;
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
}

class AppConstants {
  // 10.0.2.2 is for Android Emulator, localhost is for Web/iOS
  static const String baseUrl = kIsWeb 
    ? 'http://localhost:5000/api' 
    : 'http://10.0.2.2:5000/api'; 
}
