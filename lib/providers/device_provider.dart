import 'package:flutter/foundation.dart';
import '../models/device.dart';
import '../services/api_service.dart';
import '../services/mqtt_service.dart';

class DeviceProvider with ChangeNotifier {
  final ApiService _apiService;
  final MqttService? _mqttService;

  Map<String, Device> _devices = {};
  bool _isLoading = false;
  String? _error;

  DeviceProvider({
    ApiService? apiService,
    MqttService? mqttService,
  })  : _apiService = apiService ?? ApiService(),
        _mqttService = mqttService {
    _initializeMqtt();
    loadDevices();
  }

  Map<String, Device> get devices => _devices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _initializeMqtt() {
    _mqttService?.addListener(_onMqttUpdate);
    if (_mqttService != null && !_mqttService!.isConnected) {
      _mqttService!.connect().then((connected) {
        if (connected) {
          _mqttService!.subscribeToAllDevices();
        }
      });
    }
  }

  void _onMqttUpdate() {
    // Handle MQTT updates if needed
    notifyListeners();
  }

  Future<void> loadDevices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final devices = await _apiService.getDevices();
      _devices = {for (var d in devices) d.id: d};
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle device on/off
  Future<void> toggleDevice(String deviceId) async {
    final device = _devices[deviceId];
    if (device != null) {
      final newState = device.state.copyWith(isOn: !device.state.isOn);
      _devices[deviceId] = device.copyWith(state: newState);
      notifyListeners();

      // Send command to device via API
      await _sendDeviceCommand(deviceId, {'isOn': newState.isOn});
    }
  }

  // Update brightness for lights
  Future<void> updateBrightness(String deviceId, int brightness) async {
    final device = _devices[deviceId];
    if (device != null) {
      final newState = device.state.copyWith(
        brightness: brightness.clamp(0, 100),
        isOn: brightness > 0,
      );
      _devices[deviceId] = device.copyWith(state: newState);
      notifyListeners();

      await _sendDeviceCommand(deviceId, {
        'brightness': brightness,
        'isOn': brightness > 0,
      });
    }
  }

  // Update fan speed
  Future<void> updateFanSpeed(String deviceId, int speed) async {
    final device = _devices[deviceId];
    if (device != null) {
      final newState = device.state.copyWith(
        fanSpeed: speed.clamp(1, 5),
        isOn: speed > 0,
      );
      _devices[deviceId] = device.copyWith(state: newState);
      notifyListeners();

      await _sendDeviceCommand(deviceId, {
        'fanSpeed': speed,
        'isOn': speed > 0,
      });
    }
  }

  // Update temperature for AC
  Future<void> updateTemperature(String deviceId, double temperature) async {
    final device = _devices[deviceId];
    if (device != null) {
      final newState = device.state.copyWith(
        temperature: temperature.clamp(16, 30),
      );
      _devices[deviceId] = device.copyWith(state: newState);
      notifyListeners();

      await _sendDeviceCommand(deviceId, {
        'temperature': temperature,
      });
    }
  }

  // Update device from external source (real-time updates)
  void updateDevice(String deviceId, Device newDevice) {
    _devices[deviceId] = newDevice;
    notifyListeners();
  }

  // Send command to device
  Future<void> _sendDeviceCommand(
      String deviceId, Map<String, dynamic> command) async {
    try {
      // Try MQTT first for real-time communication
      if (_mqttService != null && _mqttService!.isConnected) {
        await _mqttService!.publishCommand(deviceId, command);
      }

      // Also update via REST API for persistence
      final updatedDevice = await _apiService.updateDevice(deviceId, command);
      _devices[deviceId] = updatedDevice;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to send command: $e';
      notifyListeners();
      rethrow;
    }
  }

  Device? getDevice(String deviceId) {
    return _devices[deviceId];
  }
}
