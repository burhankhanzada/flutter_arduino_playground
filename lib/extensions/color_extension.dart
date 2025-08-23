import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  Color alphaFromOpacity(double opacity) {
    assert(
      opacity >= 0.0 && opacity <= 1.0,
      'value shoulde between or equalt to 0.0 and 1.0',
    );
    return withAlpha(Color.getAlphaFromOpacity(opacity));
  }
}
