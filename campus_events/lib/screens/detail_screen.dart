import 'dart:async';

import 'package:flutter/material.dart';

import '../models/countdown.dart';
import '../models/item.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';

enum _Menu { edit, delete }

/// Detail of one event, pushed from a card. R26: the item and callbacks
/// arrive through [DetailArgs].
class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Item _item;
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _item = widget.args.item;
    _now = DateTime.now();
    // R13: created here, cancelled in dispose.
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _name => widget.args.profileName.trim();

  String _countdownLabel(Countdown countdown) => switch (countdown) {
    Upcoming(:final left) => 'Starts in ${formatDuration(left)}',
    Started(:final since) => 'Started ${formatDuration(since)} ago',
    Ended() => 'Ended',
  };

  Future<bool> _ask({
    required String title,
    required String message,
    required String confirm,
  }) async {
    final answer = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirm),
          ),
        ],
      ),
    );
    return answer ?? false;
  }

  /// R15: ask, then act on true. With an empty profile name, a SnackBar
  /// whose action switches to the profile tab.
  Future<void> _register() async {
    final name = _name;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Set your name in the profile first.'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: widget.args.onOpenProfile,
          ),
        ),
      );
      return;
    }
    final ok = await _ask(
      title: 'Register?',
      message: 'Add "$name" to "${_item.title}"?',
      confirm: 'Register',
    );
    if (!ok || !mounted) return;
    final updated = _item.copyWith(names: [..._item.names, name]);
    setState(() => _item = updated);
    widget.args.onChanged(updated);
  }

  /// The opposite of the primary action.
  void _unregister() {
    final updated = _item.copyWith(
      names: [
        for (final n in _item.names)
          if (n != _name) n,
      ],
    );
    setState(() => _item = updated);
    widget.args.onChanged(updated);
  }

  Future<void> _edit() async {
    final updated = await Navigator.of(context)
        .pushNamed<Item>(Routes.form, arguments: FormArgs(item: _item));
    if (updated == null || !mounted) return;
    setState(() => _item = updated);
    widget.args.onChanged(updated);
  }

  Future<void> _delete() async {
    final ok = await _ask(
      title: 'Delete event?',
      message: '"${_item.title}" will be removed.',
      confirm: 'Delete',
    );
    if (!ok || !mounted) return;
    widget.args.onDelete(_item);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final item = _item;
    final name = _name;
    final joined = name.isNotEmpty && item.contains(name);
    final description = item.description;
    // R5: destructured where shown.
    final (:taken, :free) = item.places;

    // R16: onPressed: null when the button cannot act.
    final VoidCallback? onPressed = joined
        ? _unregister
        : (item.isFull || item.isPast)
        ? null
        : _register;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event'),
        actions: [
          PopupMenuButton<_Menu>(
            onSelected: (menu) => switch (menu) {
              _Menu.edit => _edit(),
              _Menu.delete => _delete(),
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: _Menu.edit, child: Text('Edit')),
              PopupMenuItem(value: _Menu.delete, child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // R24: image from assets, icon, category and countdown.
            SizedBox(
              height: 150,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/header.png', fit: BoxFit.cover),
                  Center(
                    child: Icon(
                      item.category.icon,
                      size: 64,
                      color: scheme.onPrimary,
                    ),
                  ),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Chip(label: Text(item.category.label)),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Chip(
                      label: Text(_countdownLabel(item.countdownAt(_now))),
                    ),
                  ),
                ],
              ),
            ),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                // R29: the count in the label is live.
                Tab(text: 'Names (${item.count})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Text(
                          item.title,
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.schedule),
                        title: Text(formatDate(item.startsAt)),
                      ),
                      ListTile(
                        leading: Icon(item.online ? Icons.link : Icons.place),
                        title: Text(item.location),
                        subtitle: Text(
                          item.online ? 'Online event' : 'On campus',
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.people_outline),
                        title: Text('$taken of ${item.capacity} places taken'),
                        subtitle: Text('$free free'),
                      ),
                      if (description != null)
                        ListTile(
                          leading: const Icon(Icons.notes),
                          title: Text(description),
                        ),
                    ],
                  ),
                  item.count == 0
                      ? const EmptyState(
                          icon: Icons.people_outline,
                          message: 'Nobody has registered yet.',
                        )
                      : ListView(
                          children: [
                            for (final n in item.names)
                              ListTile(
                                tileColor: n == name
                                    ? scheme.primaryContainer
                                    : null,
                                leading: CircleAvatar(
                                  child: Text(n.isEmpty ? '?' : n[0]),
                                ),
                                title: Text(
                                  n == name ? '$n · You' : n,
                                  style: n == name
                                      ? theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        )
                                      : null,
                                ),
                              ),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton(
            onPressed: onPressed,
            child: Text(joined ? 'Cancel registration' : 'Register'),
          ),
        ),
      ),
    );
  }
}
