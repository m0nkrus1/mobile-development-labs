import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../profile/profile_screen.dart';
import '../settings/settings_model.dart';
import '../settings/settings_screen.dart';
import 'user.dart';
import 'user_detail_screen.dart';
import 'users_model.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<UsersModel>();
    final city = context.select<SettingsModel, String?>((s) => s.city);
    final shown = [
      for (final u in model.items)
        if (city == null || u.city == city) u,
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (model.fromCache)
            MaterialBanner(
              content: const Text('Saved data · no connection'),
              actions: [
                TextButton(onPressed: model.load, child: const Text('Retry')),
              ],
            ),
          Expanded(child: _content(model, shown)),
        ],
      ),
    );
  }

  Widget _content(UsersModel model, List<User> shown) {
    if (model.loading && model.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (model.offline) {
      return _Message(
        icon: Icons.wifi_off,
        text: 'Offline',
        onRetry: model.load,
      );
    }
    if (model.error case final e?) {
      return _Message(icon: Icons.error_outline, text: e, onRetry: model.load);
    }
    return ListView.builder(
      itemCount: shown.length,
      itemBuilder: (context, i) {
        final u = shown[i];
        return ListTile(
          title: Text(u.name),
          subtitle: Text('${u.email} · ${u.city}'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => UserDetailScreen(user: u)),
          ),
        );
      },
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.text,
    required this.onRetry,
  });

  final IconData icon;
  final String text;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48),
          const SizedBox(height: 8),
          Text(text),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
