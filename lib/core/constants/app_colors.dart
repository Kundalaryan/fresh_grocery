import 'package:flutter/material.dart';

class AppColors {
  // We convert hex #135bec to ARGB: 0xFF + 135BEC
  static const Color primary = Color(0xFF135BEC);

  // A lighter version for backgrounds/shadows
  static final Color primaryLight = const Color(0xFF135BEC).withOpacity(0.1);

  static const Color textBlack = Color(0xFF1A1A1A);
  static const Color textGrey = Color(0xFF9E9E9E);
  static const Color background = Colors.white;
}