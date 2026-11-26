# Practice 11 — Notes

## Level 1: Postman

GET /users → 200, Content-Type: application/json; charset=utf-8, body is a JSON array of 10 users.
GET /users/1 → 200, a single object.
GET /users?id=3 → 200, an array with one user (not an object).
GET /users/999 → 404, body `{}`.
POST /users (JSON body, Content-Type: application/json) → 201, the server echoes the sent fields and adds `"id": 11`; nothing is persisted.

### User

| field | JSON type | Dart type | nullable? |
|---|---|---|---|
| id | number (int) | int | no |
| name | string | String | no |
| username | string | String | no |
| email | string | String | no |
| address | object | Address | no |
| phone | string | String | no |
| website | string | String? | treated as optional |
| company | object | ({String name, String catchPhrase}) | no |

### address

| field | JSON type | Dart type | nullable? |
|---|---|---|---|
| street | string | String | no |
| suite | string | String | no |
| city | string | String | no |
| zipcode | string | String | no |
| geo | object | Geo | no |

### address.geo

| field | JSON type | Dart type | nullable? |
|---|---|---|---|
| lat | string ("-37.3159") | double (double.parse) | no |
| lng | string ("81.1496") | double (double.parse) | no |

### company

| field | JSON type | Dart type | nullable? |
|---|---|---|---|
| name | string | String | no |
| catchPhrase | string | String | no |
| bs | string | not modelled | — |

Nested objects: address, company. Nested twice: address.geo.

## Level 5: timings

- Airplane mode → Offline view after: ___ s
- Wi-Fi without internet → Offline view after: ___ s (expected ≈ 10 s)


---

# Practice 12 — NOTES

## Package verdicts
Fill month/year and points from each pub.dev page before the defence (Versions + Scores tabs).

1. shared_preferences — verified publisher flutter.dev, last release <month year>, all six platforms, <N>/160 points, few open issues and recent commits in flutter/packages, depends only on its own platform-interface packages, BSD-3.
2. flutter_secure_storage — verified publisher steenbakker.dev, last release <month year>, Android/iOS/macOS/Linux/Windows/web, <N>/160 points, small issue backlog with recent commits, depends on its per-platform packages, BSD-3.
3. path_provider — verified publisher flutter.dev, last release <month year>, all six platforms, <N>/160 points, tracked in flutter/packages, depends on its platform-interface packages, BSD-3.
4. image_picker — verified publisher flutter.dev, last release <month year>, Android/iOS/web/macOS/Windows/Linux, <N>/160 points, tracked in flutter/packages, depends on its platform-interface packages, BSD-3.
5. permission_handler — verified publisher baseflow.com, last release <month year>, Android/iOS/Windows/web, <N>/160 points, many open issues but active commits, depends on its per-platform packages, MIT.
6. url_launcher — verified publisher flutter.dev, last release <month year>, all six platforms, <N>/160 points, tracked in flutter/packages, depends on its platform-interface packages, BSD-3.

## Carets and the lockfile
- `http: ^1.2.0` accepts `>=1.2.0 <2.0.0` (1.2.1, 1.3.0, 1.9.9) and refuses 1.1.x and anything below 1.2.0 (too old for the API I use) and 2.0.0+ (a major version may break the API).
- `pubspec.lock` holds the exact version pub resolved for `http` (<x.y.z from my lock>). It is committed for an app so every machine and CI build the same versions; a library does not commit it because its consumers resolve their own.
- Break-on-purpose: `http: 1.2.0` without caret pinned exactly 1.2.0 and `flutter pub outdated` listed newer versions as unavailable. Caret restored.
- `flutter pub outdated`: <package> could be newer; not upgraded because <reason, e.g. the newer major needs a higher Dart/Flutter SDK or has breaking changes I did not want mid-practice>.

## Level 3 — where the token lives
- `prefs.setString('token', …)` would write it in plain text: an XML file in `shared_prefs/` on Android, a plist (NSUserDefaults) on iOS, inside the app folder. Readable from a device backup, by root, or from a connected cable (adb / iTunes backup).
- iOS surprise: Keychain items can survive an uninstall, so a reinstalled app may find the old token.
- Android surprise: keys in the Keystore tied to the lock screen can be invalidated when the lock screen is removed or changed, so the stored token becomes unreadable (read fails or returns null) and the user must sign in again.

## Level 5 — permissions
- Android sequence: 1st tap → system dialog → Don't allow (denied); 2nd tap → dialog → Don't allow; 3rd tap → no system dialog, status permanentlyDenied → my dialog → openAppSettings().
- iOS sequence: the system asks once; the first No already gives permanentlyDenied (1 No), after that only Settings can change it. The fourth Photos state is `limited` (the user shared only selected photos); the others are granted, denied/permanentlyDenied and restricted.
- `launchUrl(Uri.parse('kbtu.edu.kz'))` without a scheme returns false and nothing opens; with `https://` the browser opens.
- Defence sentence: handle the No; the feature keeps working without the photo.
