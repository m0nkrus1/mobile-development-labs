import 'package:flutter/material.dart';

import '../models/event_category.dart';
import '../models/item.dart';
import '../widgets/empty_state.dart';
import '../widgets/items_view.dart';

class ListTab extends StatefulWidget {
  const ListTab({
    super.key,
    required this.items,
    required this.onOpen,
    required this.onToggleFavourite,
  });

  final List<Item> items;
  final ValueChanged<Item> onOpen;
  final ValueChanged<Item> onToggleFavourite;

  @override
  State<ListTab> createState() => _ListTabState();
}

class _ListTabState extends State<ListTab> {
  final _search = TextEditingController();
  String _query = '';
  EventCategory? _category;
  bool _hidePast = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// R7: where/collection-for build a new list; sorting works on a copy.
  /// Upcoming first by date, past ones last.
  List<Item> get _visible {
    final q = _query.trim().toLowerCase();
    final filtered = [
      for (final i in widget.items)
        if ((_category == null || i.category == _category) &&
            (!_hidePast || !i.isPast) &&
            (q.isEmpty || i.title.toLowerCase().contains(q)))
          i,
    ];
    final sorted = [...filtered]
      ..sort((a, b) {
        if (a.isPast != b.isPast) return a.isPast ? 1 : -1;
        return a.startsAt.compareTo(b.startsAt);
      });
    return sorted;
  }

  void _clearSearch() {
    _search.clear();
    setState(() => _query = '');
  }

  void _resetFilters() {
    _search.clear();
    setState(() {
      _query = '';
      _category = null;
      _hidePast = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

    final Widget body;
    if (visible.isNotEmpty) {
      body = ItemsView(
        items: visible,
        onOpen: widget.onOpen,
        onToggleFavourite: widget.onToggleFavourite,
      );
    } else if (widget.items.isEmpty) {
      body = const EmptyState(
        icon: Icons.event_busy,
        message: 'No events yet. Tap + to add one.',
      );
    } else {
      body = EmptyState(
        icon: Icons.search_off,
        message: 'No events match your search.',
        buttonLabel: 'Reset filters',
        onPressed: _resetFilters,
      );
    }

    // R21: one Column, the list in Expanded. No shrinkWrap, no fixed heights.
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Search events',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _category == null,
                onSelected: (_) => setState(() => _category = null),
              ),
              for (final c in EventCategory.values) ...[
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: Icon(c.icon),
                  label: Text(c.label),
                  selected: _category == c,
                  onSelected: (_) => setState(() => _category = c),
                ),
              ],
              const SizedBox(width: 16),
              FilterChip(
                label: const Text('Hide past'),
                selected: _hidePast,
                onSelected: (value) => setState(() => _hidePast = value),
              ),
            ],
          ),
        ),
        Expanded(child: body),
      ],
    );
  }
}
