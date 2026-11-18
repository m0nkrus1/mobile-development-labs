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
