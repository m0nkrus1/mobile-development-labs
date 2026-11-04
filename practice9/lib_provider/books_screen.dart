import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_badge.dart';
import 'models/book.dart';
import 'models/cart.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  String _query = ''; // ephemeral: only this screen cares

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');
    final shown = books
        .where((b) => b.title.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        actions: const [CartBadge()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search',
                filled: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
        ),
      ),
      body: ListView(children: [for (final b in shown) _BookTile(book: b)]),
    );
  }
}

class _BookTile extends StatelessWidget {
  const _BookTile({required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) {
    debugPrint('row ${book.title}');
    final inCart = context.watch<Cart>().items.contains(book);
    return ListTile(
      title: Text(book.title),
      subtitle: Text(book.author),
      trailing: inCart
          ? const Text('Added')
          : OutlinedButton(
              child: const Text('Add'),
              onPressed: () {
                final ok = context.read<Cart>().add(book);
                if (ok) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Added')));
                }
              },
            ),
    );
  }
}
