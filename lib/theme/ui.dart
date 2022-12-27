import 'package:flutter/material.dart';

abstract class UI {
  // Theme data
  static final theme = ThemeData();

  // Colors
  static const primary = Color(0xFF593F62);
  static const secondary = Color(0xFFD3D0CB);
  static const chatbox = Color(0xFFE2C044);
  static const myChatbox = Color(0xFF7C9082);

  // Border radius
  static final radius = BorderRadius.circular(10);

  // Paddings
  static const p4 = 4.0;
  static const p8 = 8.0;
  static const p16 = 16.0;
  static const p24 = 24.0;

  // Text styles
  static const regular30 =
      TextStyle(fontSize: 30, fontWeight: FontWeight.normal);
  static const regular20 =
      TextStyle(fontSize: 20, fontWeight: FontWeight.normal);
}
