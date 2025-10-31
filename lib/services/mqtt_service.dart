import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'api_config.dart';

/// MQTT Service for real-time IoT device communication
class MqttService extends ChangeNotifier {
  MqttServerClient? _client;
  bool _isConnected = false;
  final Map<String, StreamSubscription<List<MqttReceivedMessage<MqttMessage?>>>>
      _subscriptions = {};

  bool get isConnected => _isConnected;

  /// Connect to MQTT broker
  Future<bool> connect() async {
    try {
      _client = MqttServerClient.withPort(
        ApiConfig.mqttBroker,
        '${ApiConfig.mqttClientId}_${DateTime.now().millisecondsSinceEpoch}',
        ApiConfig.mqttPort,
      );

      _client!.logging(on: kDebugMode);
      _client!.keepAlivePeriod = 20;
      _client!.onConnected = _onConnected;
      _client!.onDisconnected = _onDisconnected;
      _client!.onSubscribed = _onSubscribed;
      _client!.onAutoReconnect = _onAutoReconnect;

      final connMessage = MqttConnectMessage()
          .withClientIdentifier(_client!.clientIdentifier!)
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);
      _client!.connectionMessage = connMessage;

      await _client!.connect();

      return _isConnected;
    } catch (e) {
      debugPrint('MQTT Connection error: $e');
      return false;
    }
  }

  void _onConnected() {
    _isConnected = true;
    notifyListeners();
    debugPrint('MQTT Client connected');
  }

  void _onDisconnected() {
    _isConnected = false;
    notifyListeners();
    debugPrint('MQTT Client disconnected');
  }

  void _onSubscribed(String topic) {
    debugPrint('MQTT Subscribed to topic: $topic');
  }

  void _onAutoReconnect() {
    debugPrint('MQTT Auto reconnecting...');
  }

  /// Subscribe to device status topic
  Future<void> subscribeToDevice(String deviceId) async {
    if (_client == null || !_isConnected) {
      throw Exception('MQTT client not connected');
    }

    final topic = 'devices/$deviceId/status';
    _client!.subscribe(topic, MqttQos.atLeastOnce);

    final subscription =
        _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>> c) {
      final recMess = c[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      if (c[0].topic == topic) {
        _handleDeviceUpdate(deviceId, payload);
      }
    });

    _subscriptions[deviceId] = subscription;
  }

  /// Subscribe to all devices topic
  Future<void> subscribeToAllDevices() async {
    if (_client == null || !_isConnected) {
      throw Exception('MQTT client not connected');
    }

    final topic = 'devices/+/status';
    _client!.subscribe(topic, MqttQos.atLeastOnce);

    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>> c) {
      final recMess = c[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      // Extract deviceId from topic (devices/{deviceId}/status)
      final topicParts = c[0].topic.split('/');
      if (topicParts.length >= 2) {
        final deviceId = topicParts[1];
        _handleDeviceUpdate(deviceId, payload);
      }
    });
  }

  /// Publish command to device
  Future<void> publishCommand(
      String deviceId, Map<String, dynamic> command) async {
    if (_client == null || !_isConnected) {
      throw Exception('MQTT client not connected');
    }

    final topic = 'devices/$deviceId/command';
    final builder = MqttClientPayloadBuilder();
    builder.addString(jsonEncode(command));

    _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  /// Subscribe to energy data topic
  Future<void> subscribeToEnergy(String deviceId) async {
    if (_client == null || !_isConnected) {
      throw Exception('MQTT client not connected');
    }

    final topic = 'energy/$deviceId';
    _client!.subscribe(topic, MqttQos.atLeastOnce);

    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>> c) {
      final recMess = c[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      if (c[0].topic == topic) {
        _handleEnergyUpdate(deviceId, payload);
      }
    });
  }

  void _handleDeviceUpdate(String deviceId, String payload) {
    try {
      jsonDecode(payload) as Map<String, dynamic>;
      // Notify listeners about device update
      notifyListeners();
      // Can emit event or use callback here
    } catch (e) {
      debugPrint('Error parsing device update: $e');
    }
  }

  void _handleEnergyUpdate(String deviceId, String payload) {
    try {
      jsonDecode(payload) as Map<String, dynamic>;
      // Notify listeners about energy update
      notifyListeners();
    } catch (e) {
      debugPrint('Error parsing energy update: $e');
    }
  }

  /// Disconnect from MQTT broker
  void disconnect() {
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();

    _client?.disconnect();
    _isConnected = false;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
