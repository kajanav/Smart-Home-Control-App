import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../models/device.dart';
import '../models/room.dart';

/// API Service for REST API communication
class ApiService {
  String? _authToken;

  void setAuthToken(String? token) {
    _authToken = token;
  }

  String? get authToken => _authToken;

  /// Generic GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final url = Uri.parse(ApiConfig.getUrl(endpoint));
      final response = await http
          .get(
            url,
            headers: ApiConfig.getHeaders(_authToken),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw ApiException(
          'GET request failed: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      // Connection failed - backend might not be running
      throw ApiException('Connection failed: ${e.message}', 0);
    } on Exception catch (e) {
      throw ApiException('Network error: $e', 0);
    }
  }

  /// Generic POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final url = Uri.parse(ApiConfig.getUrl(endpoint));
      final response = await http
          .post(
            url,
            headers: ApiConfig.getHeaders(_authToken),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw ApiException(
          'POST request failed: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw ApiException('Connection failed: ${e.message}', 0);
    } on Exception catch (e) {
      throw ApiException('Network error: $e', 0);
    }
  }

  /// Generic PUT request
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final url = Uri.parse(ApiConfig.getUrl(endpoint));
      final response = await http
          .put(
            url,
            headers: ApiConfig.getHeaders(_authToken),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw ApiException(
          'PUT request failed: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw ApiException('Connection failed: ${e.message}', 0);
    } on Exception catch (e) {
      throw ApiException('Network error: $e', 0);
    }
  }

  /// Generic DELETE request
  Future<void> delete(String endpoint) async {
    try {
      final url = Uri.parse(ApiConfig.getUrl(endpoint));
      final response = await http
          .delete(
            url,
            headers: ApiConfig.getHeaders(_authToken),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          'DELETE request failed: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw ApiException('Connection failed: ${e.message}', 0);
    } on Exception catch (e) {
      throw ApiException('Network error: $e', 0);
    }
  }

  // Device-specific endpoints
  Future<List<Device>> getDevices() async {
    final response = await get(ApiConfig.devicesEndpoint);
    final devicesList = response['devices'] as List;
    return devicesList
        .map((d) => Device.fromJson(d as Map<String, dynamic>))
        .toList();
  }

  Future<Device> getDevice(String deviceId) async {
    final response = await get('${ApiConfig.devicesEndpoint}/$deviceId');
    return Device.fromJson(response['device'] as Map<String, dynamic>);
  }

  Future<Device> updateDevice(
      String deviceId, Map<String, dynamic> command) async {
    final response = await put(
      '${ApiConfig.devicesEndpoint}/$deviceId/control',
      command,
    );
    return Device.fromJson(response['device'] as Map<String, dynamic>);
  }

  Future<List<Room>> getRooms() async {
    final response = await get(ApiConfig.roomsEndpoint);
    final roomsList = response['rooms'] as List;
    return roomsList
        .map((r) => Room.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<Room> getRoom(String roomId) async {
    final response = await get('${ApiConfig.roomsEndpoint}/$roomId');
    return Room.fromJson(response['room'] as Map<String, dynamic>);
  }

  // Energy endpoints
  Future<Map<String, dynamic>> getEnergyData({
    DateTime? start,
    DateTime? end,
    String? deviceId,
  }) async {
    final queryParams = <String, String>{};
    if (start != null) queryParams['start'] = start.toIso8601String();
    if (end != null) queryParams['end'] = end.toIso8601String();
    if (deviceId != null) queryParams['deviceId'] = deviceId;

    final queryString = Uri(queryParameters: queryParams).query;
    final endpoint = queryString.isEmpty
        ? ApiConfig.energyEndpoint
        : '${ApiConfig.energyEndpoint}?$queryString';

    return await get(endpoint);
  }

  Future<void> postEnergySample(
      String deviceId, double watts, DateTime timestamp) async {
    await post(ApiConfig.energyEndpoint, {
      'deviceId': deviceId,
      'watts': watts,
      'timestamp': timestamp.toIso8601String(),
    });
  }

  // User/Authentication endpoints
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await post('${ApiConfig.userEndpoint}/login', {
      'email': email,
      'password': password,
    });
    return response;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    return await post('${ApiConfig.userEndpoint}/register', userData);
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    return await get('${ApiConfig.userEndpoint}/profile');
  }

  Future<void> updateUserProfile(Map<String, dynamic> profile) async {
    await put('${ApiConfig.userEndpoint}/profile', profile);
  }
}

/// API Exception class
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
