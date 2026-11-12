import 'dart:async';

import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'countdown_screen.dart';
import 'students_future_screen.dart';
import 'students_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'students_async', home: HomeScreen());
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    unawaited(
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('The Data Arrives Later')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              onPressed: () => _open(context, const StudentsScreen()),
              child: const Text('By hand'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => _open(context, const StudentsFutureScreen()),
              child: const Text('FutureBuilder'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => _open(context, const CountdownScreen()),
              child: const Text('Countdown'),
            ),
          ],
        ),
      ),
    );
  }
}
