import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../models/item.dart';
import '../models/profile.dart';
import '../routes.dart';
import '../widgets/app_drawer.dart';
import 'favourites_tab.dart';
import 'list_tab.dart';
import 'profile_tab.dart';

/// R10: the item list and the profile live here. Tabs get them as
/// constructor parameters and send changes up through callbacks.
class Shell extends StatefulWidget {
  const Shell({super.key, required this.themeMode, required this.onThemeMode});

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeMode;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  static const _titles = ['Events', 'Favourites', 'Profile'];

  List<Item> _items = buildSeed();
  Profile _profile = const Profile.empty();
  int _tab = 0;

  // R12: every setState below wraps the change only.

  void _toggleFavourite(Item item) {
    setState(() {
      _items = [
        for (final i in _items)
          i.id == item.id ? i.copyWith(favourite: !i.favourite) : i,
      ];
    });
  }

  void _replace(Item updated) {
    setState(() {
      _items = [for (final i in _items) i.id == updated.id ? updated : i];
    });
  }

  void _delete(Item item) {
    setState(() {
      _items = [
        for (final i in _items)
          if (i.id != item.id) i,
      ];
    });
  }

  void _setProfile(Profile profile) => setState(() => _profile = profile);

  /// R28: tab switches go through the shell.
  void _goToTab(int index) => setState(() => _tab = index);

  /// Called from a pushed screen: uncover the bar, then switch.
  void _openProfileTab() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    _goToTab(2);
  }

  void _openDetail(Item item) {
    Navigator.of(context).pushNamed(
      Routes.detail,
      arguments: DetailArgs(
        item: item,
        profileName: _profile.name,
        onChanged: _replace,
        onDelete: _delete,
        onOpenProfile: _openProfileTab,
      ),
    );
  }

  // R27: await the pushed form, check null and mounted, then setState.
  Future<void> _openForm() async {
    final created = await Navigator.of(
      context,
    ).pushNamed<Item>(Routes.form, arguments: const FormArgs());
    if (created == null || !mounted) return;
    setState(() => _items = [..._items, created]);
  }

  Future<void> _showAbout() {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('About'),
        content: const Text(
          'Campus Events: find an event, check the places left, '
          'register. All data lives in memory.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset data?'),
        content: const Text(
          'This restores the original events and clears your profile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() {
      _items = buildSeed();
      _profile = const Profile.empty();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_tab])),
      drawer: AppDrawer(onAbout: _showAbout, onReset: _confirmReset),
      body: IndexedStack(
        index: _tab,
        children: [
          ListTab(
            items: _items,
            onOpen: _openDetail,
            onToggleFavourite: _toggleFavourite,
          ),
          FavouritesTab(
            items: _items,
            onOpen: _openDetail,
            onToggleFavourite: _toggleFavourite,
            onBrowse: () => _goToTab(0),
          ),
          ProfileTab(
            profile: _profile,
            items: _items,
            themeMode: widget.themeMode,
            onProfileChanged: _setProfile,
            onThemeMode: widget.onThemeMode,
          ),
        ],
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton(
              tooltip: 'New event',
              onPressed: _openForm,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _goToTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
