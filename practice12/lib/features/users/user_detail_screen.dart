import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/storage/secure_store.dart';
import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});

  final User user;

  Future<void> _open(BuildContext context, Uri uri) async {
    var ok = false;
    try {
      ok = await launchUrl(uri);
    } on PlatformException {
      ok = false;
    }
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No app can open this')));
    }
  }

  Future<void> _copyToken(BuildContext context) async {
    final token = await const SecureStore().readToken();
    if (token == null) return;
    await Clipboard.setData(ClipboardData(text: token));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Token copied')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.email),
            title: Text(user.email),
            onTap: () =>
                _open(context, Uri(scheme: 'mailto', path: user.email)),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text(user.phone),
            onTap: () =>
                _open(context, Uri(scheme: 'tel', path: user.phoneDigits)),
          ),
          ListTile(
            leading: const Icon(Icons.public),
            title: Text(user.website),
            onTap: () => _open(context, Uri.parse('https://${user.website}')),
          ),
          if (kDebugMode)
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton(
                onPressed: () => _copyToken(context),
                child: const Text('Copy token to clipboard'),
              ),
            ),
        ],
      ),
    );
  }
}
