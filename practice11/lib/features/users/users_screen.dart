import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/net/api_client.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_model.dart';
import '../settings/settings_screen.dart';
import 'user.dart';
import 'user_detail_screen.dart';
import 'user_form_screen.dart';
import 'users_model.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();
    final city = context.select<SettingsModel, String?>((s) => s.city);
    final shown = [
      for (final u in m.items)
        if (city == null || u.address.city == city) u,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const UserFormScreen())),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          if (m.fromCache)
            MaterialBanner(
              content: const Text('Saved data · no connection'),
              actions: [
                TextButton(onPressed: m.load, child: const Text('Retry')),
              ],
            ),
          Expanded(
            child: m.loading && m.items.isEmpty
                ? const LoadingView()
                : RefreshIndicator(
                    onRefresh: m.load,
                    child: switch (m.error) {
                      null => UserList(items: shown),
                      NoConnectionException() => Offline(onRetry: m.load),
                      NotFoundException() ||
                      UnauthorizedException() => const GenericError(),
                      ServerException(:final status) => ServerError(
                        status: status,
                        onRetry: m.load,
                      ),
                      BadResponseException() => const GenericError(),
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.onRetry});

  final IconData icon;
  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.25),
        Icon(icon, size: 64),
        const SizedBox(height: 16),
        Text(text, textAlign: TextAlign.center),
        if (onRetry != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: FilledButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ),
          ),
      ],
    );
  }
}

class Offline extends StatelessWidget {
  const Offline({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) =>
      _Message(icon: Icons.wifi_off, text: 'No connection', onRetry: onRetry);
}

class ServerError extends StatelessWidget {
  const ServerError({super.key, required this.status, required this.onRetry});

  final int status;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => _Message(
    icon: Icons.cloud_off,
    text: 'Server error ($status)',
    onRetry: onRetry,
  );
}

class GenericError extends StatelessWidget {
  const GenericError({super.key});

  @override
  Widget build(BuildContext context) =>
      const _Message(icon: Icons.error_outline, text: 'Something went wrong');
}

class UserList extends StatelessWidget {
  const UserList({super.key, required this.items});

  final List<User> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final u = items[i];
        return ListTile(
          title: Text(u.name),
          subtitle: Text('${u.email} · ${u.address.city}'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => UserDetailScreen(user: u)),
          ),
        );
      },
    );
  }
}
