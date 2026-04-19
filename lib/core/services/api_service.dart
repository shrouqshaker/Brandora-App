import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// ─────────────────────────────────────────────────────────────────────────────
/// ApiService — Single point for all HTTP communication with the backend.
///
/// • Automatically fetches a fresh Firebase ID token before every request.
/// • Attaches  Authorization: Bearer <token>  header.
/// • 10.0.2.2 = localhost on Android emulator.
///   For a real device, change baseUrl to your machine's LAN IP, e.g. 192.168.1.x
/// ─────────────────────────────────────────────────────────────────────────────
class ApiService {
  static const String baseUrl = 'https://brandora-app-production-536f.up.railway.app/api';

  // ── Get a fresh ID token from Firebase ──────────────────────────────────────
  static Future<String?> _getToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    // forceRefresh: false — uses cached token (auto-refreshed by SDK when expired)
    return await user.getIdToken(false);
  }

  // ── Build JSON headers with auth token ──────────────────────────────────────
  static Future<Map<String, String>> _jsonHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── GET ─────────────────────────────────────────────────────────────────────
  static Future<http.Response> get(String endpoint) async {
    final headers = await _jsonHeaders();
    return http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
  }

  // ── POST (JSON) ─────────────────────────────────────────────────────────────
  static Future<http.Response> post(
      String endpoint, Map<String, dynamic> body) async {
    final headers = await _jsonHeaders();
    return http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  // ── PUT (JSON) ──────────────────────────────────────────────────────────────
  static Future<http.Response> put(
      String endpoint, Map<String, dynamic> body) async {
    final headers = await _jsonHeaders();
    return http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  // ── PATCH (JSON) ─────────────────────────────────────────────────────────────
  static Future<http.Response> patch(
      String endpoint, Map<String, dynamic> body) async {
    final headers = await _jsonHeaders();
    return http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  // ── DELETE ───────────────────────────────────────────────────────────────────
  static Future<http.Response> delete(String endpoint) async {
    final headers = await _jsonHeaders();
    return http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
  }

  // ── POST Multipart (for file uploads) ───────────────────────────────────────
  static Future<http.StreamedResponse> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    File? imageFile,
    String imageFieldName = 'image',
  }) async {
    final token = await _getToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl$endpoint'),
    );

    // Attach auth header
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Attach text fields
    request.fields.addAll(fields);

    // Attach image file if provided
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(imageFieldName, imageFile.path),
      );
    }

    return request.send();
  }

  // ── Helper: parse error message from response body ──────────────────────────
  static String parseError(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return body['message'] ?? 'Unknown error (${response.statusCode})';
    } catch (_) {
      return 'Error ${response.statusCode}';
    }
  }
}
