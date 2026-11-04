import 'package:flutter/material.dart';

/// R32: About and Reset data. Each tile closes the drawer with
/// Navigator.pop first; the dialogs are opened by the shell, whose context
/// outlives the drawer.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.onAbout, required this.onReset});

  final VoidCallback onAbout;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Campus Events',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              onAbout();
            },
          ),
          ListTile(
            leading: const Icon(Icons.restart_alt),
            title: const Text('Reset data'),
            onTap: () {
              Navigator.pop(context);
              onReset();
            },
          ),
        ],
      ),
    );
  }
}
