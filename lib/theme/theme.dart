import 'package:flutter/cupertino.dart';

abstract class ICTheme {
  static const typefaces = _Typeface();
}

class _Typeface {
  const _Typeface();

  TextStyle get bold30 =>
      const TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
}
