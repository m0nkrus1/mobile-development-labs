import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../storage/secure_store.dart';

class NoConnectionException implements Exception {
  const NoConnectionException();
}

class ApiException implements Exception {
  const ApiException(this.status);
  final int status;
}

class ApiClient {
  ApiClient(this._client, this._store);

  final http.Client _client;
  final SecureStore _store;

  Future<Map<String, String>> _headers() async => {
    'Accept': 'application/json',
    if (await _store.readToken() case final t?) 'Authorization': 'Bearer $t',
  };

  Future<dynamic> getJson(String url) async {
    final http.Response r;
    try {
      r = await _client
          .get(Uri.parse(url), headers: await _headers())
          .timeout(const Duration(seconds: 10));
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    } on http.ClientException {
      throw const NoConnectionException();
    }
    if (r.statusCode != 200) throw ApiException(r.statusCode);
    return jsonDecode(r.body);
  }
}
