import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../settings/settings_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();

  void _say(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _choose() => _pick(ImageSource.gallery);

  Future<void> _take() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    switch (status) {
      case PermissionStatus.granted ||
          PermissionStatus.limited ||
          PermissionStatus.provisional:
        await _pick(ImageSource.camera);
      case PermissionStatus.denied:
        _say(
          'Camera access is needed to take a photo. You can still choose one from the gallery.',
        );
      case PermissionStatus.restricted:
        _say('The camera is restricted on this device.');
      case PermissionStatus.permanentlyDenied:
        await _showSettingsDialog();
    }
  }

  Future<void> _showSettingsDialog() async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Camera access is off'),
        content: const Text(
          'Camera permission was denied permanently. Open Settings to allow it, or choose a photo from the gallery instead.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
    if (go == true) await openAppSettings();
  }

  Future<void> _pick(ImageSource source) async {
    XFile? picked;
    try {
      picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );
    } on PlatformException {
      if (mounted) _say('Could not open the picker');
      return;
    }
    if (picked == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final dest = File('${dir.path}${Platform.pathSeparator}avatar.jpg');
    if (await dest.exists()) await dest.delete();
    await File(picked.path).copy(dest.path);
    await FileImage(dest).evict();
    if (!mounted) return;
    await context.read<SettingsModel>().setAvatarPath(dest.path);
  }

  @override
  Widget build(BuildContext context) {
    final path = context.select<SettingsModel, String?>((s) => s.avatarPath);
    final file = (path != null && File(path).existsSync()) ? File(path) : null;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 56,
              backgroundImage: file == null ? null : FileImage(file),
              child: file == null ? const Icon(Icons.person, size: 56) : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _choose,
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose photo'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _take,
              icon: const Icon(Icons.photo_camera),
              label: const Text('Take photo'),
            ),
          ],
        ),
      ),
    );
  }
}
