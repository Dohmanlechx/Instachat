import 'package:flutter/material.dart';

abstract class UI {
  // Theme data
  static final theme = ThemeData(primarySwatch: Colors.indigo);

  // Border radius
  static final radius = BorderRadius.circular(10);

  // Paddings
  static const p4 = 4.0;
  static const p8 = 8.0;
  static const p16 = 16.0;

  // Text styles
  static const regular30 =
      TextStyle(fontSize: 30, fontWeight: FontWeight.normal);
  static const regular20 =
      TextStyle(fontSize: 20, fontWeight: FontWeight.normal);
}
