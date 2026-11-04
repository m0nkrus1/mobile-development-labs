import 'package:flutter/material.dart';

// R22: no hard-coded colours or font sizes anywhere in lib/. The seed is
// taken from the framework's own default scheme; every other colour is a
// colorScheme role, and text sizes come from the theme's textTheme.
final Color _seed = ThemeData().colorScheme.primary;

ThemeData buildTheme(Brightness brightness) => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: brightness),
);
