/// Device Model
/// Represents a smart device in the home
class Device {
  final String id;
  final String name;
  final DeviceType type;
  final String roomId;
  final bool isOnline;
  final DeviceState state;
  final double? currentLoad; // Watts
  final DateTime? lastUpdate;
  final Map<String, dynamic>? properties;

  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.roomId,
    this.isOnline = false,
    this.state = const DeviceState(),
    this.currentLoad,
    this.lastUpdate,
    this.properties,
  });

  Device copyWith({
    String? id,
    String? name,
    DeviceType? type,
    String? roomId,
    bool? isOnline,
    DeviceState? state,
    double? currentLoad,
    DateTime? lastUpdate,
    Map<String, dynamic>? properties,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      roomId: roomId ?? this.roomId,
      isOnline: isOnline ?? this.isOnline,
      state: state ?? this.state,
      currentLoad: currentLoad ?? this.currentLoad,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      properties: properties ?? this.properties,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'roomId': roomId,
      'isOnline': isOnline,
      'state': state.toJson(),
      'currentLoad': currentLoad,
      'lastUpdate': lastUpdate?.toIso8601String(),
      'properties': properties,
    };
  }

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      name: json['name'],
      type: DeviceType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => DeviceType.generic,
      ),
      roomId: json['roomId'],
      isOnline: json['isOnline'] ?? false,
      state: DeviceState.fromJson(json['state'] ?? {}),
      currentLoad: json['currentLoad']?.toDouble(),
      lastUpdate: json['lastUpdate'] != null
          ? DateTime.parse(json['lastUpdate'])
          : null,
      properties: json['properties'],
    );
  }
}

/// Device State
class DeviceState {
  final bool isOn;
  final int? brightness; // 0-100
  final int? fanSpeed; // 1-5
  final double? temperature; // Celsius
  final String? mode;

  const DeviceState({
    this.isOn = false,
    this.brightness,
    this.fanSpeed,
    this.temperature,
    this.mode,
  });

  DeviceState copyWith({
    bool? isOn,
    int? brightness,
    int? fanSpeed,
    double? temperature,
    String? mode,
  }) {
    return DeviceState(
      isOn: isOn ?? this.isOn,
      brightness: brightness ?? this.brightness,
      fanSpeed: fanSpeed ?? this.fanSpeed,
      temperature: temperature ?? this.temperature,
      mode: mode ?? this.mode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isOn': isOn,
      'brightness': brightness,
      'fanSpeed': fanSpeed,
      'temperature': temperature,
      'mode': mode,
    };
  }

  factory DeviceState.fromJson(Map<String, dynamic> json) {
    return DeviceState(
      isOn: json['isOn'] ?? false,
      brightness: json['brightness'],
      fanSpeed: json['fanSpeed'],
      temperature: json['temperature']?.toDouble(),
      mode: json['mode'],
    );
  }
}

/// Device Types
enum DeviceType {
  light,
  fan,
  tv,
  airConditioner,
  fridge,
  hotPlate,
  riceCooker,
  exhaustFan,
  waterHeater,
  washingMachine,
  computer,
  printer,
  gateMotor,
  cctvCamera,
  gardenLight,
  generic;

  String get displayName {
    switch (this) {
      case DeviceType.light:
        return 'Light';
      case DeviceType.fan:
        return 'Fan';
      case DeviceType.tv:
        return 'TV';
      case DeviceType.airConditioner:
        return 'Air Conditioner';
      case DeviceType.fridge:
        return 'Refrigerator';
      case DeviceType.hotPlate:
        return 'Hot Plate';
      case DeviceType.riceCooker:
        return 'Rice Cooker';
      case DeviceType.exhaustFan:
        return 'Exhaust Fan';
      case DeviceType.waterHeater:
        return 'Water Heater';
      case DeviceType.washingMachine:
        return 'Washing Machine';
      case DeviceType.computer:
        return 'Computer';
      case DeviceType.printer:
        return 'Printer';
      case DeviceType.gateMotor:
        return 'Gate Motor';
      case DeviceType.cctvCamera:
        return 'CCTV Camera';
      case DeviceType.gardenLight:
        return 'Garden Light';
      case DeviceType.generic:
        return 'Device';
    }
  }
}

