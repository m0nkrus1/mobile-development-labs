import 'package:flutter/material.dart';

import '../models/item.dart';
import 'event_card.dart';

/// R20: a list on phones, a grid with cells of at most 360 px from 600 px.
/// The decision uses the width this widget is given (LayoutBuilder), not
/// the width of the whole screen (MediaQuery).
class ItemsView extends StatelessWidget {
  const ItemsView({
    super.key,
    required this.items,
    required this.onOpen,
    required this.onToggleFavourite,
  });

  final List<Item> items;
  final ValueChanged<Item> onOpen;
  final ValueChanged<Item> onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Widget cardAt(int index) {
          final item = items[index];
          return EventCard(
            item: item,
            onTap: () => onOpen(item),
            onToggleFavourite: () => onToggleFavourite(item),
          );
        }

        if (constraints.maxWidth >= 600) {
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 360,
              childAspectRatio: 2.0,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) => cardAt(index),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) => cardAt(index),
        );
      },
    );
  }
}
