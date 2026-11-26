import 'package:flutter/foundation.dart';

import '../../core/net/api_client.dart';
import 'user.dart';
import 'user_repository.dart';

class UsersModel extends ChangeNotifier {
  UsersModel(this._repo);

  final UserRepository _repo;

  List<User> items = const [];
  ApiException? error;
  bool loading = false;
  bool saving = false;
  bool fromCache = false;

  List<String> get cities => ({
    for (final u in items)
      if (u.address.city.isNotEmpty) u.address.city,
  }.toList()..sort());

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final r = await _repo.getAll();
      items = r.items;
      fromCache = r.fromCache;
    } on ApiException catch (e) {
      if (e is NoConnectionException) {
        items = const [];
      }
      fromCache = false;
      error = e;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<ApiException?> create(User draft) async {
    if (saving) return null;
    saving = true;
    notifyListeners();
    try {
      final created = await _repo.create(draft);
      items = [created, ...items];
      return null;
    } on ApiException catch (e) {
      return e;
    } finally {
      saving = false;
      notifyListeners();
    }
  }
}
