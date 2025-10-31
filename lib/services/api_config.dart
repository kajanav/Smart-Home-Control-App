/// Backend API Configuration
class ApiConfig {
  // Base URL - Update this to your backend server URL
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );

  // MQTT Configuration
  static const String mqttBroker = String.fromEnvironment(
    'MQTT_BROKER',
    defaultValue: 'localhost',
  );
  static const int mqttPort = int.fromEnvironment(
    'MQTT_PORT',
    defaultValue: 1883,
  );
  static const String mqttClientId = String.fromEnvironment(
    'MQTT_CLIENT_ID',
    defaultValue: 'smart_home_app',
  );

  // API Endpoints
  static const String devicesEndpoint = '/devices';
  static const String roomsEndpoint = '/rooms';
  static const String energyEndpoint = '/energy';
  static const String automationEndpoint = '/automations';
  static const String userEndpoint = '/users';

  // Headers
  static Map<String, String> getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get full URL for endpoint
  static String getUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}
