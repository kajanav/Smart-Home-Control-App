/// Automation Model
/// Represents an automated routine or scene
class Automation {
  final String id;
  final String name;
  final AutomationType type;
  final String? description;
  final List<AutomationAction> actions;
  final AutomationTrigger trigger;
  final bool isEnabled;
  final DateTime? createdAt;
  final DateTime? lastExecuted;

  Automation({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    required this.actions,
    required this.trigger,
    this.isEnabled = true,
    this.createdAt,
    this.lastExecuted,
  });

  Automation copyWith({
    String? id,
    String? name,
    AutomationType? type,
    String? description,
    List<AutomationAction>? actions,
    AutomationTrigger? trigger,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? lastExecuted,
  }) {
    return Automation(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      actions: actions ?? this.actions,
      trigger: trigger ?? this.trigger,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      lastExecuted: lastExecuted ?? this.lastExecuted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'description': description,
      'actions': actions.map((a) => a.toJson()).toList(),
      'trigger': trigger.toJson(),
      'isEnabled': isEnabled,
      'createdAt': createdAt?.toIso8601String(),
      'lastExecuted': lastExecuted?.toIso8601String(),
    };
  }

  factory Automation.fromJson(Map<String, dynamic> json) {
    return Automation(
      id: json['id'],
      name: json['name'],
      type: AutomationType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => AutomationType.custom,
      ),
      description: json['description'],
      actions: (json['actions'] as List)
          .map((a) => AutomationAction.fromJson(a))
          .toList(),
      trigger: AutomationTrigger.fromJson(json['trigger']),
      isEnabled: json['isEnabled'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      lastExecuted: json['lastExecuted'] != null
          ? DateTime.parse(json['lastExecuted'])
          : null,
    );
  }
}

/// Automation Action
class AutomationAction {
  final String deviceId;
  final ActionType actionType;
  final Map<String, dynamic> parameters;

  AutomationAction({
    required this.deviceId,
    required this.actionType,
    required this.parameters,
  });

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'actionType': actionType.toString(),
      'parameters': parameters,
    };
  }

  factory AutomationAction.fromJson(Map<String, dynamic> json) {
    return AutomationAction(
      deviceId: json['deviceId'],
      actionType: ActionType.values.firstWhere(
        (e) => e.toString() == json['actionType'],
        orElse: () => ActionType.turnOn,
      ),
      parameters: json['parameters'] ?? {},
    );
  }
}

/// Action Types
enum ActionType {
  turnOn,
  turnOff,
  setBrightness,
  setFanSpeed,
  setTemperature,
  setMode,
  toggle;

  String get displayName {
    switch (this) {
      case ActionType.turnOn:
        return 'Turn On';
      case ActionType.turnOff:
        return 'Turn Off';
      case ActionType.setBrightness:
        return 'Set Brightness';
      case ActionType.setFanSpeed:
        return 'Set Fan Speed';
      case ActionType.setTemperature:
        return 'Set Temperature';
      case ActionType.setMode:
        return 'Set Mode';
      case ActionType.toggle:
        return 'Toggle';
    }
  }
}

/// Automation Trigger
class AutomationTrigger {
  final TriggerType type;
  final TimeTrigger? timeTrigger;
  final LocationTrigger? locationTrigger;
  final SensorTrigger? sensorTrigger;
  final ManualTrigger? manualTrigger;

  AutomationTrigger({
    required this.type,
    this.timeTrigger,
    this.locationTrigger,
    this.sensorTrigger,
    this.manualTrigger,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'timeTrigger': timeTrigger?.toJson(),
      'locationTrigger': locationTrigger?.toJson(),
      'sensorTrigger': sensorTrigger?.toJson(),
      'manualTrigger': manualTrigger?.toJson(),
    };
  }

  factory AutomationTrigger.fromJson(Map<String, dynamic> json) {
    return AutomationTrigger(
      type: TriggerType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => TriggerType.manual,
      ),
      timeTrigger: json['timeTrigger'] != null
          ? TimeTrigger.fromJson(json['timeTrigger'])
          : null,
      locationTrigger: json['locationTrigger'] != null
          ? LocationTrigger.fromJson(json['locationTrigger'])
          : null,
      sensorTrigger: json['sensorTrigger'] != null
          ? SensorTrigger.fromJson(json['sensorTrigger'])
          : null,
      manualTrigger: json['manualTrigger'] != null
          ? ManualTrigger.fromJson(json['manualTrigger'])
          : null,
    );
  }
}

/// Trigger Types
enum TriggerType {
  manual,
  time,
  location,
  sensor;

  String get displayName {
    switch (this) {
      case TriggerType.manual:
        return 'Manual';
      case TriggerType.time:
        return 'Time-based';
      case TriggerType.location:
        return 'Location-based';
      case TriggerType.sensor:
        return 'Sensor-based';
    }
  }
}

/// Time Trigger
class TimeTrigger {
  final String time; // HH:mm format
  final List<int> daysOfWeek; // 0-6 (Sunday-Saturday)
  final bool isRecurring;

  TimeTrigger({
    required this.time,
    required this.daysOfWeek,
    this.isRecurring = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'daysOfWeek': daysOfWeek,
      'isRecurring': isRecurring,
    };
  }

  factory TimeTrigger.fromJson(Map<String, dynamic> json) {
    return TimeTrigger(
      time: json['time'],
      daysOfWeek: List<int>.from(json['daysOfWeek']),
      isRecurring: json['isRecurring'] ?? true,
    );
  }
}

/// Location Trigger (Geofencing)
class LocationTrigger {
  final double latitude;
  final double longitude;
  final double radius; // meters
  final LocationEvent event; // enter or exit

  LocationTrigger({
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.event,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'event': event.toString(),
    };
  }

  factory LocationTrigger.fromJson(Map<String, dynamic> json) {
    return LocationTrigger(
      latitude: json['latitude'],
      longitude: json['longitude'],
      radius: json['radius'],
      event: LocationEvent.values.firstWhere(
        (e) => e.toString() == json['event'],
        orElse: () => LocationEvent.enter,
      ),
    );
  }
}

enum LocationEvent {
  enter,
  exit;
}

/// Sensor Trigger
class SensorTrigger {
  final String sensorId;
  final SensorType sensorType;
  final String condition; // "motion_detected", "temperature_above", etc.
  final dynamic threshold;

  SensorTrigger({
    required this.sensorId,
    required this.sensorType,
    required this.condition,
    this.threshold,
  });

  Map<String, dynamic> toJson() {
    return {
      'sensorId': sensorId,
      'sensorType': sensorType.toString(),
      'condition': condition,
      'threshold': threshold,
    };
  }

  factory SensorTrigger.fromJson(Map<String, dynamic> json) {
    return SensorTrigger(
      sensorId: json['sensorId'],
      sensorType: SensorType.values.firstWhere(
        (e) => e.toString() == json['sensorType'],
        orElse: () => SensorType.motion,
      ),
      condition: json['condition'],
      threshold: json['threshold'],
    );
  }
}

enum SensorType {
  motion,
  temperature,
  humidity,
  light;
}

/// Manual Trigger
class ManualTrigger {
  final bool requiresConfirmation;

  ManualTrigger({this.requiresConfirmation = false});

  Map<String, dynamic> toJson() {
    return {
      'requiresConfirmation': requiresConfirmation,
    };
  }

  factory ManualTrigger.fromJson(Map<String, dynamic> json) {
    return ManualTrigger(
      requiresConfirmation: json['requiresConfirmation'] ?? false,
    );
  }
}

/// Automation Types
enum AutomationType {
  leaveHome,
  arriveHome,
  schedule,
  energySave,
  scene,
  custom;

  String get displayName {
    switch (this) {
      case AutomationType.leaveHome:
        return 'Leave Home';
      case AutomationType.arriveHome:
        return 'Arrive Home';
      case AutomationType.schedule:
        return 'Schedule';
      case AutomationType.energySave:
        return 'Energy Save';
      case AutomationType.scene:
        return 'Scene';
      case AutomationType.custom:
        return 'Custom';
    }
  }

  String get icon {
    switch (this) {
      case AutomationType.leaveHome:
        return '🚪';
      case AutomationType.arriveHome:
        return '🏠';
      case AutomationType.schedule:
        return '⏰';
      case AutomationType.energySave:
        return '💡';
      case AutomationType.scene:
        return '🎬';
      case AutomationType.custom:
        return '⚙️';
    }
  }
}

