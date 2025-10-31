import 'device.dart';

/// Room Model
/// Represents a room in the house with its devices
class Room {
  final String id;
  final String name;
  final String description;
  final RoomType type;
  final List<Device> devices;
  final String? imageUrl;
  final bool isFavorite;

  Room({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.devices,
    this.imageUrl,
    this.isFavorite = false,
  });

  // Calculated properties
  int get totalDevices => devices.length;
  int get onlineDevices => devices.where((d) => d.isOnline).length;
  int get activeDevices => devices.where((d) => d.state.isOn).length;
  
  double get totalLoad => devices
      .where((d) => d.currentLoad != null && d.state.isOn)
      .fold(0.0, (sum, device) => sum + (device.currentLoad ?? 0));

  Room copyWith({
    String? id,
    String? name,
    String? description,
    RoomType? type,
    List<Device>? devices,
    String? imageUrl,
    bool? isFavorite,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      devices: devices ?? this.devices,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString(),
      'devices': devices.map((d) => d.toJson()).toList(),
      'imageUrl': imageUrl,
      'isFavorite': isFavorite,
    };
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: RoomType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => RoomType.generic,
      ),
      devices: (json['devices'] as List)
          .map((d) => Device.fromJson(d))
          .toList(),
      imageUrl: json['imageUrl'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}

/// Room Types
enum RoomType {
  livingRoom,
  bedroom1,
  bedroom2,
  kitchen,
  bathroom1,
  bathroom2,
  studyRoom,
  officeRoom,
  diningRoom,
  garage,
  outdoor,
  storeRoom,
  generic;

  String get displayName {
    switch (this) {
      case RoomType.livingRoom:
        return 'Living Room';
      case RoomType.bedroom1:
        return 'Bedroom 1';
      case RoomType.bedroom2:
        return 'Bedroom 2';
      case RoomType.kitchen:
        return 'Kitchen';
      case RoomType.bathroom1:
        return 'Bathroom 1';
      case RoomType.bathroom2:
        return 'Bathroom 2';
      case RoomType.studyRoom:
        return 'Study Room';
      case RoomType.officeRoom:
        return 'Office Room';
      case RoomType.diningRoom:
        return 'Dining Room';
      case RoomType.garage:
        return 'Garage';
      case RoomType.outdoor:
        return 'Outdoor Area';
      case RoomType.storeRoom:
        return 'Store Room';
      case RoomType.generic:
        return 'Room';
    }
  }

  /// Icon representation for the room
  String get icon {
    switch (this) {
      case RoomType.livingRoom:
        return '🛋️';
      case RoomType.bedroom1:
      case RoomType.bedroom2:
        return '🛏️';
      case RoomType.kitchen:
        return '🍳';
      case RoomType.bathroom1:
      case RoomType.bathroom2:
        return '🚿';
      case RoomType.studyRoom:
        return '📚';
      case RoomType.officeRoom:
        return '💼';
      case RoomType.diningRoom:
        return '🍽️';
      case RoomType.garage:
        return '🚗';
      case RoomType.outdoor:
        return '🌳';
      case RoomType.storeRoom:
        return '📦';
      case RoomType.generic:
        return '🏠';
    }
  }
}

