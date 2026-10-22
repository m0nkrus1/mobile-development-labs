import 'package:flutter/material.dart';

import 'models/book.dart';

enum BookAction { toggleRead, delete }

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.book});

  final Book book;

  Future<void> _delete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete '${book.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (!context.mounted) return;
    Navigator.of(context).pop(BookAction.delete);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Book')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(title: const Text('Title'), subtitle: Text(book.title)),
        ListTile(title: const Text('Author'), subtitle: Text(book.author)),
        ListTile(title: const Text('Pages'), subtitle: Text('${book.pages}')),
        ListTile(
          title: const Text('Year'),
          subtitle: Text(book.year == null ? 'Year unknown' : '${book.year}'),
        ),
        ListTile(
          title: const Text('Status'),
          subtitle: Text(book.read ? 'Read' : 'Unread'),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(BookAction.toggleRead),
          child: Text(book.read ? 'Mark as unread' : 'Mark as read'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => _delete(context),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
