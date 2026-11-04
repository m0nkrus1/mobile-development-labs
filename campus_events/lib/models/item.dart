import 'package:flutter/foundation.dart';

import 'countdown.dart';
import 'event_category.dart';

/// One campus event (R1). Immutable: final fields, const constructor,
/// [copyWith]. The names list is private and only exposed unmodifiable.
@immutable
class Item {
  const Item({
    required this.id,
    required this.title,
    required this.category,
    required this.startsAt,
    required this.capacity,
    required this.location,
    List<String> names = const [],
    this.online = false,
    this.description,
    this.favourite = false,
  }) : _names = names;

  /// R3: defaults for a new event.
  Item.empty()
    : this(
        id: '',
        title: '',
        category: EventCategory.tech,
        startsAt: DateTime.now().add(const Duration(days: 1)),
        capacity: 20,
        location: '',
      );

  /// How long an event is considered "running" after it starts.
  static const Duration length = Duration(hours: 3);

  final String id;
  final String title;
  final EventCategory category;
  final DateTime startsAt;

  /// The limit the list counts against.
  final int capacity;

  /// A place, or a link when [online] is on (the mode flag).
  final String location;
  final bool online;

  /// Optional text, shown only when present.
  final String? description;
  final bool favourite;

  final List<String> _names;

  /// Attendees. A fresh unmodifiable copy, so callers cannot mutate state.
  List<String> get names => List.unmodifiable(_names);

  // R4: derived values are getters, never fields.
  int get count => _names.length;
  int get freePlaces => capacity > count ? capacity - count : 0;
  bool get isFull => count >= capacity;
  bool get isPast => startsAt.isBefore(DateTime.now());
  bool contains(String name) => _names.contains(name);

  /// R5: taken / free as a record.
  ({int taken, int free}) get places => (taken: count, free: freePlaces);

  /// R9: where the event is relative to [now].
  Countdown countdownAt(DateTime now) {
    final diff = startsAt.difference(now);
    if (!diff.isNegative) return Upcoming(diff);
    final since = -diff;
    return since < length ? Started(since) : const Ended();
  }

  /// [description] takes a callback so `() => null` can clear it.
  Item copyWith({
    String? id,
    String? title,
    EventCategory? category,
    DateTime? startsAt,
    int? capacity,
    String? location,
    List<String>? names,
    bool? online,
    String? Function()? description,
    bool? favourite,
  }) {
    return Item(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      startsAt: startsAt ?? this.startsAt,
      capacity: capacity ?? this.capacity,
      location: location ?? this.location,
      names: List<String>.unmodifiable(names ?? _names),
      online: online ?? this.online,
      description: description != null ? description() : this.description,
      favourite: favourite ?? this.favourite,
    );
  }
}
