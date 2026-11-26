import 'package:flutter/foundation.dart';

import '../../core/net/api_client.dart';
import 'user.dart';
import 'user_repository.dart';

class UsersModel extends ChangeNotifier {
  UsersModel(this._repo);

  final UserRepository _repo;
  List<User> _items = const [];
  bool _loading = false;
  bool _fromCache = false;
  bool _offline = false;
  String? _error;

  List<User> get items => _items;
  bool get loading => _loading;
  bool get fromCache => _fromCache;
  bool get offline => _offline;
  String? get error => _error;

  List<String> get cities => ({
    for (final u in _items)
      if (u.city.isNotEmpty) u.city,
  }.toList()..sort());

  Future<void> load() async {
    _loading = true;
    _error = null;
    _offline = false;
    notifyListeners();
    try {
      final r = await _repo.getAll();
      _items = r.items;
      _fromCache = r.fromCache;
    } on NoConnectionException {
      _items = const [];
      _fromCache = false;
      _offline = true;
    } on ApiException catch (e) {
      _error = 'Server error ${e.status}';
    }
    _loading = false;
    notifyListeners();
  }
}
