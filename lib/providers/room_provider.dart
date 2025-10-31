import 'package:flutter/foundation.dart';
import '../models/room.dart';
import '../models/device.dart';
import '../services/api_service.dart';

class RoomProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Room> _rooms = [];
  bool _isLoading = false;
  String? _error;

  List<Room> get rooms => _rooms;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get favorite rooms
  List<Room> get favoriteRooms => _rooms.where((r) => r.isFavorite).toList();

  RoomProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService() {
    _initializeRooms();
  }

  Future<void> _initializeRooms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try to load from API first
      final apiRooms = await _apiService.getRooms();
      // Always use default 6 rooms if API returns 2 or fewer (for demo purposes)
      // This ensures users see Kitchen, Bathroom, Study Room, Dining Room etc.
      if (apiRooms.length <= 2) {
        _rooms = _getDefaultRooms();
        if (kDebugMode) {
          print(
              '🔄 Using default rooms: ${_rooms.length} rooms (API returned ${apiRooms.length})');
        }
      } else {
        // Use API rooms if we have more than 2
        _rooms = apiRooms;
        if (kDebugMode) {
          print('✅ Using API rooms: ${_rooms.length} rooms');
        }
      }
      notifyListeners();
    } catch (e) {
      // Fallback to default rooms if API fails
      if (kDebugMode) {
        print('API failed, using default rooms: $e');
      }
      _error = 'Using offline data: ${e.toString()}';
      _rooms = _getDefaultRooms();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Room> _getDefaultRooms() {
    return [
      Room(
        id: '1',
        name: 'Living Room',
        description: 'Main living space',
        type: RoomType.livingRoom,
        devices: [
          Device(
            id: 'd1',
            name: 'Main Light',
            type: DeviceType.light,
            roomId: '1',
            state: DeviceState(isOn: false, brightness: 100),
          ),
          Device(
            id: 'd2',
            name: 'Ceiling Fan',
            type: DeviceType.fan,
            roomId: '1',
            state: DeviceState(isOn: false, fanSpeed: 3),
          ),
          Device(
            id: 'd3',
            name: 'Smart TV',
            type: DeviceType.tv,
            roomId: '1',
            state: DeviceState(isOn: false),
          ),
          Device(
            id: 'd4',
            name: 'Air Conditioner',
            type: DeviceType.airConditioner,
            roomId: '1',
            state: DeviceState(isOn: false, temperature: 26, mode: 'cool'),
          ),
        ],
      ),
      Room(
        id: '2',
        name: 'Bedroom 1',
        description: 'Master bedroom',
        type: RoomType.bedroom1,
        devices: [
          Device(
            id: 'd5',
            name: 'Bedside Lamp',
            type: DeviceType.light,
            roomId: '2',
            state: DeviceState(isOn: false, brightness: 50),
          ),
          Device(
            id: 'd6',
            name: 'Ceiling Fan',
            type: DeviceType.fan,
            roomId: '2',
            state: DeviceState(isOn: false, fanSpeed: 2),
          ),
          Device(
            id: 'd7',
            name: 'TV',
            type: DeviceType.tv,
            roomId: '2',
            state: DeviceState(isOn: false),
          ),
          Device(
            id: 'd8',
            name: 'AC',
            type: DeviceType.airConditioner,
            roomId: '2',
            state: DeviceState(isOn: true, temperature: 24, mode: 'cool'),
          ),
        ],
      ),
      Room(
        id: '3',
        name: 'Kitchen',
        description: 'Cooking area',
        type: RoomType.kitchen,
        devices: [
          Device(
            id: 'd9',
            name: 'Kitchen Light',
            type: DeviceType.light,
            roomId: '3',
            state: DeviceState(isOn: false, brightness: 100),
          ),
          Device(
            id: 'd10',
            name: 'Exhaust Fan',
            type: DeviceType.exhaustFan,
            roomId: '3',
            state: DeviceState(isOn: false),
          ),
          Device(
            id: 'd11',
            name: 'Hot Plate',
            type: DeviceType.hotPlate,
            roomId: '3',
            state: DeviceState(isOn: false),
          ),
          Device(
            id: 'd12',
            name: 'Rice Cooker',
            type: DeviceType.riceCooker,
            roomId: '3',
            state: DeviceState(isOn: false),
          ),
          Device(
            id: 'd13',
            name: 'Fridge',
            type: DeviceType.fridge,
            roomId: '3',
            state: DeviceState(isOn: true),
          ),
        ],
      ),
      Room(
        id: '4',
        name: 'Bathroom 1',
        description: 'Main bathroom',
        type: RoomType.bathroom1,
        devices: [
          Device(
            id: 'd14',
            name: 'Bathroom Light',
            type: DeviceType.light,
            roomId: '4',
            state: DeviceState(isOn: false, brightness: 80),
          ),
          Device(
            id: 'd15',
            name: 'Exhaust Fan',
            type: DeviceType.exhaustFan,
            roomId: '4',
            state: DeviceState(isOn: false),
          ),
          Device(
            id: 'd16',
            name: 'Water Heater',
            type: DeviceType.waterHeater,
            roomId: '4',
            state: DeviceState(isOn: false),
          ),
        ],
      ),
      Room(
        id: '5',
        name: 'Study Room',
        description: 'Study and reading area',
        type: RoomType.studyRoom,
        devices: [
          Device(
            id: 'd17',
            name: 'Desk Lamp',
            type: DeviceType.light,
            roomId: '5',
            state: DeviceState(isOn: false, brightness: 90),
          ),
          Device(
            id: 'd18',
            name: 'Computer',
            type: DeviceType.computer,
            roomId: '5',
            state: DeviceState(isOn: false),
          ),
          Device(
            id: 'd19',
            name: 'Printer',
            type: DeviceType.printer,
            roomId: '5',
            state: DeviceState(isOn: false),
          ),
          Device(
            id: 'd20',
            name: 'Ceiling Fan',
            type: DeviceType.fan,
            roomId: '5',
            state: DeviceState(isOn: false, fanSpeed: 2),
          ),
        ],
      ),
      Room(
        id: '6',
        name: 'Dining Room',
        description: 'Dining area',
        type: RoomType.diningRoom,
        devices: [
          Device(
            id: 'd21',
            name: 'Dining Light',
            type: DeviceType.light,
            roomId: '6',
            state: DeviceState(isOn: false, brightness: 70),
          ),
          Device(
            id: 'd22',
            name: 'Ceiling Fan',
            type: DeviceType.fan,
            roomId: '6',
            state: DeviceState(isOn: false, fanSpeed: 2),
          ),
        ],
      ),
    ];
  }

  Future<void> loadRooms() async {
    await _initializeRooms();
  }

  // Force reload with default rooms (useful for testing)
  void loadDefaultRooms() {
    _rooms = _getDefaultRooms();
    notifyListeners();
  }

  void toggleRoomFavorite(String roomId) {
    final index = _rooms.indexWhere((r) => r.id == roomId);
    if (index != -1) {
      _rooms[index] = _rooms[index].copyWith(
        isFavorite: !_rooms[index].isFavorite,
      );
      notifyListeners();
    }
  }

  Room? getRoomById(String roomId) {
    try {
      return _rooms.firstWhere((r) => r.id == roomId);
    } catch (e) {
      return null;
    }
  }

  // Update device in a room (for real-time sync)
  void updateDeviceInRoom(
      String roomId, String deviceId, Device updatedDevice) {
    final roomIndex = _rooms.indexWhere((r) => r.id == roomId);
    if (roomIndex != -1) {
      final room = _rooms[roomIndex];
      final deviceIndex = room.devices.indexWhere((d) => d.id == deviceId);
      if (deviceIndex != -1) {
        final updatedDevices = List<Device>.from(room.devices);
        updatedDevices[deviceIndex] = updatedDevice;
        _rooms[roomIndex] = room.copyWith(devices: updatedDevices);
        notifyListeners();
      }
    }
  }
}
