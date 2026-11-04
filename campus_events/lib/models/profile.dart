import 'package:flutter/foundation.dart';

/// The user: name and group (R1).
@immutable
class Profile {
  const Profile({required this.name, required this.group});

  /// R3
  const Profile.empty() : this(name: '', group: '');

  final String name;
  final String group;

  Profile copyWith({String? name, String? group}) =>
      Profile(name: name ?? this.name, group: group ?? this.group);

  @override
  bool operator ==(Object other) =>
      other is Profile && other.name == name && other.group == group;

  @override
  int get hashCode => Object.hash(name, group);
}
