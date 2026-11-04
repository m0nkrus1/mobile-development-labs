import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/event_category.dart';
import '../models/item.dart';
import '../routes.dart';
import '../utils/format.dart';

typedef _Snapshot = (
  String title,
  String place,
  String limit,
  EventCategory? category,
  bool online,
  DateTime? date,
  TimeOfDay? time,
  String description,
);

const _auto = AutovalidateMode.onUserInteraction;

class FormScreen extends StatefulWidget {
  const FormScreen({super.key, required this.args});

  final FormArgs args;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  // R33: Form + GlobalKey<FormState>.
  final _formKey = GlobalKey<FormState>();

  final _titleNode = FocusNode();
  final _placeNode = FocusNode();
  final _limitNode = FocusNode();
  final _descriptionNode = FocusNode();

  late final TextEditingController _title;
  late final TextEditingController _place;
  late final TextEditingController _limit;
  late final TextEditingController _description;
  late final TextEditingController _dateText;
  late final TextEditingController _timeText;

  late final bool _isNew;
  late final int _currentCount;
  late final _Snapshot _initial;

  EventCategory? _category;
  bool _online = false;
  DateTime? _date;
  TimeOfDay? _time;

  bool _dirty = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.args.item;
    final base = existing ?? Item.empty();
    _isNew = existing == null;
    _currentCount = base.count;

    _title = TextEditingController(text: base.title);
    _place = TextEditingController(text: base.location);
    _limit = TextEditingController(text: base.capacity.toString());
    _description = TextEditingController(text: base.description ?? '');

    _category = existing?.category;
    _online = base.online;
    if (existing != null) {
      final s = existing.startsAt;
      _date = DateTime(s.year, s.month, s.day);
      _time = TimeOfDay.fromDateTime(s);
    }
    final date = _date;
    final time = _time;
    _dateText = TextEditingController(
      text: date == null ? '' : formatDay(date),
    );
    _timeText = TextEditingController(
      text: time == null ? '' : formatClock(time),
    );
    _initial = _snapshot();
  }

  @override
  void dispose() {
    _title.dispose();
    _place.dispose();
    _limit.dispose();
    _description.dispose();
    _dateText.dispose();
    _timeText.dispose();
    _titleNode.dispose();
    _placeNode.dispose();
    _limitNode.dispose();
    _descriptionNode.dispose();
    super.dispose();
  }

  _Snapshot _snapshot() => (
    _title.text,
    _place.text,
    _limit.text,
    _category,
    _online,
    _date,
    _time,
    _description.text,
  );

  /// R30: dirty = current values differ from the ones the form opened with.
  void _refreshDirty() {
    final dirty = _snapshot() != _initial;
    if (dirty != _dirty) setState(() => _dirty = dirty);
  }

  DateTime? _startsAt() {
    final d = _date;
    final t = _time;
    if (d == null || t == null) return null;
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  // ---- validators (R34) ----

  String? _validateTitle(String? value) {
    final v = value?.trim() ?? '';
    if (v.length < 3) return 'At least 3 characters';
    if (v.length > 60) return 'At most 60 characters';
    return null;
  }

  String? _validatePlace(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty)
      return _online ? 'A link is required' : 'A place is required';
    if (_online && !v.contains('://'))
      return 'Must be a link, e.g. https://...';
    return null;
  }

  String? _validateLimit(String? value) {
    final n = int.tryParse(value?.trim() ?? '');
    if (n == null) return 'Enter a whole number';
    if (n < 1 || n > 500) return 'Between 1 and 500';
    if (!_isNew && n < _currentCount) {
      return 'Already $_currentCount registered';
    }
    return null;
  }

  String? _validateCategory(EventCategory? value) =>
      value == null ? 'Choose a category' : null;

  String? _validateDate(String? value) {
    final d = _date;
    if (d == null) return 'Pick a date';
    final now = DateTime.now();
    if (_isNew && d.isBefore(DateTime(now.year, now.month, now.day))) {
      return 'The date is in the past';
    }
    return null;
  }

  String? _validateTime(String? value) {
    if (_time == null) return 'Pick a time';
    final start = _startsAt();
    if (_isNew && start != null && !start.isAfter(DateTime.now())) {
      return 'Must be in the future';
    }
    return null;
  }

  String? _validateDescription(String? value) =>
      (value ?? '').length > 200 ? 'At most 200 characters' : null;

  // ---- pickers (R36): Cancel returns null and keeps the old value ----

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null || !mounted) return;
    setState(() => _date = picked);
    _dateText.text = formatDay(picked);
    _refreshDirty();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked == null || !mounted) return;
    setState(() => _time = picked);
    _timeText.text = formatClock(picked);
    _refreshDirty();
  }

  void _dismiss(PointerDownEvent event) =>
      FocusManager.instance.primaryFocus?.unfocus();

  // ---- save (R17) ----

  Item _buildItem() {
    final base = widget.args.item ?? Item.empty();
    final description = _description.text.trim();
    return base.copyWith(
      id: base.id.isEmpty
          ? DateTime.now().microsecondsSinceEpoch.toString()
          : base.id,
      title: _title.text.trim(),
      category: _category ?? base.category,
      startsAt: _startsAt() ?? base.startsAt,
      capacity: int.tryParse(_limit.text.trim()) ?? base.capacity,
      online: _online,
      location: _place.text.trim(),
      description: () => description.isEmpty ? null : description,
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    // R33: a single validate() call runs every field's validator.
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.of(context).pop(_buildItem());
  }

  Future<bool> _askDiscard() async {
    final answer = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your edits will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return answer ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // R30: a clean form pops directly; a dirty one asks first. Save pops
    // with Navigator.pop, which does not consult PopScope, so it never asks.
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final discard = await _askDiscard();
        if (!discard || !mounted) return;
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isNew ? 'New event' : 'Edit event')),
        // R37: the whole form scrolls; Save is the last child of the column.
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Form(
              key: _formKey,
              onChanged: _refreshDirty,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _title,
                    focusNode: _titleNode,
                    maxLength: 60,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    autovalidateMode: _auto,
                    validator: _validateTitle,
                    onFieldSubmitted: (_) => _placeNode.requestFocus(),
                    onTapOutside: _dismiss,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<EventCategory>(
                    initialValue: _category,
                    autovalidateMode: _auto,
                    validator: _validateCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final c in EventCategory.values)
                        DropdownMenuItem(
                          value: c,
                          child: Row(
                            children: [
                              Icon(c.icon),
                              const SizedBox(width: 12),
                              Text(c.label),
                            ],
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      setState(() => _category = value);
                      _refreshDirty();
                    },
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text('Online event'),
                    subtitle: const Text('The place becomes a link'),
                    value: _online,
                    onChanged: (value) {
                      setState(() => _online = value ?? false);
                      _refreshDirty();
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _place,
                    focusNode: _placeNode,
                    textInputAction: TextInputAction.next,
                    keyboardType: _online
                        ? TextInputType.url
                        : TextInputType.text,
                    autovalidateMode: _auto,
                    validator: _validatePlace,
                    onFieldSubmitted: (_) => _limitNode.requestFocus(),
                    onTapOutside: _dismiss,
                    decoration: InputDecoration(
                      labelText: _online ? 'Link' : 'Place',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _limit,
                    focusNode: _limitNode,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    autovalidateMode: _auto,
                    validator: _validateLimit,
                    onFieldSubmitted: (_) => _descriptionNode.requestFocus(),
                    onTapOutside: _dismiss,
                    decoration: const InputDecoration(
                      labelText: 'Capacity',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _dateText,
                          readOnly: true,
                          autovalidateMode: _auto,
                          validator: _validateDate,
                          onTap: _pickDate,
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            suffixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _timeText,
                          readOnly: true,
                          autovalidateMode: _auto,
                          validator: _validateTime,
                          onTap: _pickTime,
                          decoration: const InputDecoration(
                            labelText: 'Time',
                            suffixIcon: Icon(Icons.schedule),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _description,
                    focusNode: _descriptionNode,
                    maxLength: 200,
                    maxLines: 3,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    autovalidateMode: _auto,
                    validator: _validateDescription,
                    onTapOutside: _dismiss,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
