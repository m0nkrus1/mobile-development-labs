import 'package:flutter/material.dart';

/// Enhanced enum: every value carries a label and an icon (R2).
enum EventCategory {
  tech('Tech', Icons.code),
  sports('Sports', Icons.sports_soccer),
  music('Music', Icons.music_note),
  art('Art', Icons.palette),
  career('Career', Icons.work_outline),
  food('Food', Icons.restaurant);

  const EventCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  /// Exhaustive switch expression: adding a value breaks the build here
  /// until it is given a colorScheme role.
  Color color(ColorScheme scheme) => switch (this) {
    EventCategory.tech => scheme.primary,
    EventCategory.sports => scheme.secondary,
    EventCategory.music => scheme.tertiary,
    EventCategory.art => scheme.error,
    EventCategory.career => scheme.outline,
    EventCategory.food => scheme.primaryContainer,
  };
}
