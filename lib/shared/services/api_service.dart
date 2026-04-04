import 'dart:convert';
// import 'package:http/http.dart' as http; // Add http to pubspec later

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  // Example GET request skeleton
  Future<dynamic> get(String endpoint) async {
    // try {
    //   final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
    //   return _handleResponse(response);
    // } catch (e) {
    //   rethrow;
    // }
    return null;
  }

  // Example POST request skeleton
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    // try {
    //   final response = await http.post(
    //     Uri.parse('$baseUrl/$endpoint'),
    //     headers: {'Content-Type': 'application/json'},
    //     body: jsonEncode(data),
    //   );
    //   return _handleResponse(response);
    // } catch (e) {
    //   rethrow;
    // }
    return null;
  }

  // Handle errors / responses
  // dynamic _handleResponse(http.Response response) {
  //   if (response.statusCode >= 200 && response.statusCode < 300) {
  //     return jsonDecode(response.body);
  //   } else {
  //     throw Exception('API Error: ${response.statusCode}');
  //   }
  // }
}
