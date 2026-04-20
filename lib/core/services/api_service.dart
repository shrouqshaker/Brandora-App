import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://brandora-app-production-536f.up.railway.app/api';

  static Future<String?> _getToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return await user.getIdToken(false);
  }

  static Future<Map<String, String>> _jsonHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static String _buildUrl(String endpoint) {
    String base = baseUrl;
    String end = endpoint;
    if (base.endsWith('/')) base = base.substring(0, base.length - 1);
    if (!end.startsWith('/')) end = '/$end';
    return '$base$end';
  }

  static Future<http.Response> get(String endpoint) async {
    final headers = await _jsonHeaders();
    return http.get(Uri.parse(_buildUrl(endpoint)), headers: headers);
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final headers = await _jsonHeaders();
    return http.post(
      Uri.parse(_buildUrl(endpoint)),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final headers = await _jsonHeaders();
    return http.put(
      Uri.parse(_buildUrl(endpoint)),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> patch(String endpoint, Map<String, dynamic> body) async {
    final headers = await _jsonHeaders();
    return http.patch(
      Uri.parse(_buildUrl(endpoint)),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> delete(String endpoint) async {
    final headers = await _jsonHeaders();
    return http.delete(Uri.parse(_buildUrl(endpoint)), headers: headers);
  }

  static Future<http.StreamedResponse> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    File? imageFile,
    String imageFieldName = 'image',
  }) async {
    final token = await _getToken();
    final request = http.MultipartRequest('POST', Uri.parse(_buildUrl(endpoint)));
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(fields);
    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(imageFieldName, imageFile.path));
    }
    return request.send();
  }

  static String parseError(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return body['message'] ?? 'Unknown error (${response.statusCode})';
    } catch (_) {
      return 'Error ${response.statusCode}';
    }
  }
}
