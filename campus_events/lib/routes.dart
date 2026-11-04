import 'package:flutter/material.dart';

import 'models/item.dart';
import 'screens/detail_screen.dart';
import 'screens/form_screen.dart';

/// R25: the only file with route-name literals.
class Routes {
  static const home = '/';
  static const detail = '/detail';
  static const form = '/form';
}

/// R26: what the detail screen receives. The item plus callbacks.
class DetailArgs {
  const DetailArgs({
    required this.item,
    required this.profileName,
    required this.onChanged,
    required this.onDelete,
    required this.onOpenProfile,
  });

  final Item item;
  final String profileName;
  final ValueChanged<Item> onChanged;
  final ValueChanged<Item> onDelete;
  final VoidCallback onOpenProfile;
}

/// R26: the form receives an `Item?` (null = new) and returns an Item
/// through pop.
class FormArgs {
  const FormArgs({this.item});

  final Item? item;
}

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  final args = settings.arguments;
  if (settings.name == Routes.detail && args is DetailArgs) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (context) => DetailScreen(args: args),
    );
  }
  if (settings.name == Routes.form && args is FormArgs) {
    return MaterialPageRoute<Item>(
      settings: settings,
      builder: (context) => FormScreen(args: args),
    );
  }
  return null;
}

Route<dynamic> onUnknownRoute(RouteSettings settings) {
  return MaterialPageRoute<void>(
    settings: settings,
    builder: (context) => Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: const Center(child: Text('Not found')),
    ),
  );
}
