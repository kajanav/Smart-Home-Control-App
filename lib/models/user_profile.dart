class HomeProfile {
  final String id;
  final String name;
  final String address;

  const HomeProfile(
      {required this.id, required this.name, required this.address});
}

enum AppLanguage { si, ta, en, hi }

class UserProfile {
  final String userId;
  final String name;
  final String address;
  final String preferredUnit; // 'kWh' or 'Rs'
  final List<HomeProfile> homes;

  const UserProfile({
    required this.userId,
    required this.name,
    required this.address,
    this.preferredUnit = 'kWh',
    this.homes = const [],
  });

  UserProfile copyWith({
    String? userId,
    String? name,
    String? address,
    String? preferredUnit,
    List<HomeProfile>? homes,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      address: address ?? this.address,
      preferredUnit: preferredUnit ?? this.preferredUnit,
      homes: homes ?? this.homes,
    );
  }
}

class ControlLogEntry {
  final DateTime timestamp;
  final String userId;
  final String deviceId;
  final String action; // e.g. toggled on, set brightness, etc.

  const ControlLogEntry({
    required this.timestamp,
    required this.userId,
    required this.deviceId,
    required this.action,
  });
}
