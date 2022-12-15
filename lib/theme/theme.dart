import 'package:flutter/cupertino.dart';

abstract class ICTheme {
  static const typefaces = _Typeface();
  static const paddings = _Padding();
}

class _Typeface {
  const _Typeface();

  TextStyle get headline =>
      const TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  TextStyle get body =>
      const TextStyle(fontSize: 24, fontWeight: FontWeight.normal);
}

class _Padding {
  const _Padding();

  double get p4 => 4.0;
  double get p8 => 8.0;
  double get p16 => 16.0;
}
