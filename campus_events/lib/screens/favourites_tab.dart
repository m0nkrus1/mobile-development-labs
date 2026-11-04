import 'package:flutter/material.dart';

import '../models/item.dart';
import '../widgets/empty_state.dart';
import '../widgets/items_view.dart';

/// Tab 2: the favourited events, soonest first.
class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.items,
    required this.onOpen,
    required this.onToggleFavourite,
    required this.onBrowse,
  });

  final List<Item> items;
  final ValueChanged<Item> onOpen;
  final ValueChanged<Item> onToggleFavourite;

  /// Asks the shell to switch to the events tab (R28).
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final favourites = [
      for (final i in items)
        if (i.favourite) i,
    ]..sort((a, b) => a.startsAt.compareTo(b.startsAt));

    if (favourites.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border,
        message: 'No favourites yet. Tap the heart on an event.',
        buttonLabel: 'Browse events',
        onPressed: onBrowse,
      );
    }
    return ItemsView(
      items: favourites,
      onOpen: onOpen,
      onToggleFavourite: onToggleFavourite,
    );
  }
}
