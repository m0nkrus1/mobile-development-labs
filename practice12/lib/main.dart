import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/net/api_client.dart';
import 'core/storage/secure_store.dart';
import 'features/auth/auth_model.dart';
import 'features/settings/settings_model.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_cache.dart';
import 'features/users/users_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = SharedPreferencesAsync();
  final dark = await prefs.getBool('darkMode') ?? false;
  final city = await prefs.getString('cityFilter');
  final avatarPath = await prefs.getString('avatarPath');

  const store = SecureStore();
  final token = await store.readToken();

  final api = ApiClient(http.Client(), store);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsModel(
            prefs,
            dark: dark,
            city: city,
            avatarPath: avatarPath,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthModel(store, signedIn: token != null),
        ),
        ChangeNotifierProvider(
          create: (_) => UsersModel(UserRepository(api, UsersCache()))..load(),
        ),
      ],
      child: const App(),
    ),
  );
}
