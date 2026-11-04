import 'package:flutter/material.dart';

import '../models/item.dart';
import '../models/profile.dart';

/// Tab 3: name, group, theme mode.
class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.items,
    required this.themeMode,
    required this.onProfileChanged,
    required this.onThemeMode,
  });

  final Profile profile;
  final List<Item> items;
  final ThemeMode themeMode;
  final ValueChanged<Profile> onProfileChanged;
  final ValueChanged<ThemeMode> onThemeMode;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  // e.g. SE-2301
  static final _groupPattern = RegExp(r'^[A-Z]{2,4}-\d{2,4}$');

  final _nameKey = GlobalKey<FormFieldState<String>>();
  final _groupKey = GlobalKey<FormFieldState<String>>();
  final _groupNode = FocusNode();
  late final TextEditingController _name;
  late final TextEditingController _group;

  @override
  void initState() {
    super.initState();
    // R38: controllers initialised from the model.
    _name = TextEditingController(text: widget.profile.name);
    _group = TextEditingController(text: widget.profile.group);
  }

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The drawer's "Reset data" clears the profile from outside.
    if (oldWidget.profile != widget.profile) {
      _name.text = widget.profile.name;
      _group.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    _groupNode.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final v = value?.trim() ?? '';
    return v.length > 40 ? 'At most 40 characters' : null;
  }

  String? _validateGroup(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty || _groupPattern.hasMatch(v)) return null;
    return 'Use the format SE-2301';
  }

  
  void _submitName() {
    if (_nameKey.currentState?.validate() ?? false) {
      widget.onProfileChanged(widget.profile.copyWith(name: _name.text.trim()));
    }
    _groupNode.requestFocus();
  }

  void _submitGroup() {
    if (_groupKey.currentState?.validate() ?? false) {
      widget.onProfileChanged(
        widget.profile.copyWith(group: _group.text.trim()),
      );
    }
  }

  void _dismiss(PointerDownEvent event) =>
      FocusManager.instance.primaryFocus?.unfocus();

  String _modeLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'System',
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = widget.profile.name;
    final lists = name.isEmpty
        ? 0
        : widget.items.where((i) => i.contains(name)).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextFormField(
          key: _nameKey,
          controller: _name,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.name,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validateName,
          onFieldSubmitted: (_) => _submitName(),
          onTapOutside: _dismiss,
          decoration: const InputDecoration(
            labelText: 'Your name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: _groupKey,
          controller: _group,
          focusNode: _groupNode,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.characters,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validateGroup,
          onFieldSubmitted: (_) => _submitGroup(),
          onTapOutside: _dismiss,
          decoration: const InputDecoration(
            labelText: 'Group',
            hintText: 'SE-2301',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Press Enter on a field to save it.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 24),
        Text(
          'You are on $lists ${lists == 1 ? 'list' : 'lists'}',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 24),
        Text('Theme', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final mode in ThemeMode.values)
              ChoiceChip(
                label: Text(_modeLabel(mode)),
                selected: widget.themeMode == mode,
                onSelected: (_) => widget.onThemeMode(mode),
              ),
          ],
        ),
      ],
    );
  }
}
