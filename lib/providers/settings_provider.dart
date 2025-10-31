import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_profile.dart';
import '../services/api_service.dart';

class SettingsProvider with ChangeNotifier {
  final ApiService _apiService;

  ThemeMode _themeMode = ThemeMode.system;
  AppLanguage _language = AppLanguage.en;
  bool _notificationsPower = true;
  bool _notificationsAutomation = true;
  bool _notificationsUpdates = true;
  bool _accessibilitySimpleMode = false;

  UserProfile _profile = const UserProfile(
    userId: 'u1',
    name: 'Guest User',
    address: '—',
    preferredUnit: 'kWh',
    homes: [HomeProfile(id: 'h1', name: 'My Home', address: '—')],
  );

  final List<ControlLogEntry> _logs = [];

  bool _isInitialized = false;
  bool _isSyncing = false;

  SettingsProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load theme
      final themeIndex = prefs.getInt('themeMode');
      if (themeIndex != null) {
        _themeMode = ThemeMode.values[themeIndex];
      }

      // Load language
      final langIndex = prefs.getInt('language');
      if (langIndex != null) {
        _language = AppLanguage.values[langIndex];
      }

      // Load notifications
      _notificationsPower = prefs.getBool('notificationsPower') ?? true;
      _notificationsAutomation =
          prefs.getBool('notificationsAutomation') ?? true;
      _notificationsUpdates = prefs.getBool('notificationsUpdates') ?? true;
      _accessibilitySimpleMode = prefs.getBool('accessibilityMode') ?? false;

      // Try to load profile from MongoDB first, fallback to local storage
      try {
        final profileData = await _apiService.getUserProfile();
        if (profileData.containsKey('profile')) {
          final profileMap = profileData['profile'] as Map<String, dynamic>;
          _profile = _profileFromJson(profileMap);
          // Update local cache
          await _saveSettingsLocal();
        } else {
          _loadProfileFromLocal();
        }
      } catch (e) {
        // Silently fallback to local storage if backend is not available
        // This is expected behavior when backend server is not running
        if (kDebugMode && e.toString().contains('Status: 0')) {
          debugPrint('Backend server not available, using local storage');
        }
        _loadProfileFromLocal();
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
      _isInitialized = true;
    }
  }

  void _loadProfileFromLocal() {
    try {
      SharedPreferences.getInstance().then((prefs) {
        final profileJson = prefs.getString('userProfile');
        if (profileJson != null) {
          final profileData = jsonDecode(profileJson) as Map<String, dynamic>;
          _profile = UserProfile(
            userId: profileData['userId'] as String? ?? 'u1',
            name: profileData['name'] as String? ?? 'Guest User',
            address: profileData['address'] as String? ?? '—',
            preferredUnit: profileData['preferredUnit'] as String? ?? 'kWh',
            homes: (profileData['homes'] as List?)
                    ?.map((h) => HomeProfile(
                          id: h['id'] as String,
                          name: h['name'] as String,
                          address: h['address'] as String,
                        ))
                    .toList() ??
                [const HomeProfile(id: 'h1', name: 'My Home', address: '—')],
          );
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('Error loading profile from local: $e');
    }
  }

  UserProfile _profileFromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String? ?? json['_id'] as String? ?? 'u1',
      name: json['name'] as String? ?? 'Guest User',
      address: json['address'] as String? ?? '—',
      preferredUnit: json['preferredUnit'] as String? ?? 'kWh',
      homes: (json['homes'] as List?)
              ?.map((h) => HomeProfile(
                    id: h['id'] as String? ??
                        h['_id'] as String? ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    name: h['name'] as String,
                    address: h['address'] as String,
                  ))
              .toList() ??
          [const HomeProfile(id: 'h1', name: 'My Home', address: '—')],
    );
  }

  Future<void> _saveSettings() async {
    // Save to local storage first (for offline access)
    await _saveSettingsLocal();

    // Sync to MongoDB in background (non-blocking)
    _syncToMongoDB();
  }

  Future<void> _saveSettingsLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save theme
      await prefs.setInt('themeMode', _themeMode.index);

      // Save language
      await prefs.setInt('language', _language.index);

      // Save notifications
      await prefs.setBool('notificationsPower', _notificationsPower);
      await prefs.setBool('notificationsAutomation', _notificationsAutomation);
      await prefs.setBool('notificationsUpdates', _notificationsUpdates);
      await prefs.setBool('accessibilityMode', _accessibilitySimpleMode);

      // Save profile locally
      await prefs.setString(
          'userProfile',
          jsonEncode({
            'userId': _profile.userId,
            'name': _profile.name,
            'address': _profile.address,
            'preferredUnit': _profile.preferredUnit,
            'homes': _profile.homes
                .map((h) => {
                      'id': h.id,
                      'name': h.name,
                      'address': h.address,
                    })
                .toList(),
          }));
    } catch (e) {
      debugPrint('Error saving settings locally: $e');
    }
  }

  Future<void> _syncToMongoDB() async {
    if (_isSyncing) return;

    _isSyncing = true;
    try {
      // Prepare profile data for MongoDB
      final profileData = {
        'userId': _profile.userId,
        'name': _profile.name,
        'address': _profile.address,
        'preferredUnit': _profile.preferredUnit,
        'homes': _profile.homes
            .map((h) => {
                  'id': h.id,
                  'name': h.name,
                  'address': h.address,
                })
            .toList(),
        'settings': {
          'themeMode': _themeMode.index,
          'language': _language.index,
          'notificationsPower': _notificationsPower,
          'notificationsAutomation': _notificationsAutomation,
          'notificationsUpdates': _notificationsUpdates,
          'accessibilityMode': _accessibilitySimpleMode,
        },
      };

      // Save to MongoDB via API
      await _apiService.updateUserProfile(profileData);
      debugPrint('Profile synced to MongoDB successfully');
    } catch (e) {
      debugPrint('Error syncing to MongoDB: $e');
      // Profile is still saved locally, will sync next time
    } finally {
      _isSyncing = false;
    }
  }

  // getters
  ThemeMode get themeMode => _themeMode;
  AppLanguage get language => _language;
  bool get notificationsPower => _notificationsPower;
  bool get notificationsAutomation => _notificationsAutomation;
  bool get notificationsUpdates => _notificationsUpdates;
  bool get accessibilitySimpleMode => _accessibilitySimpleMode;
  UserProfile get profile => _profile;
  List<ControlLogEntry> get logs => List.unmodifiable(_logs);

  // setters
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
    _saveSettings();
  }

  void setLanguage(AppLanguage lang) {
    _language = lang;
    notifyListeners();
    _saveSettings();
  }

  void setNotificationsPower(bool v) {
    _notificationsPower = v;
    notifyListeners();
    _saveSettings();
  }

  void setNotificationsAutomation(bool v) {
    _notificationsAutomation = v;
    notifyListeners();
    _saveSettings();
  }

  void setNotificationsUpdates(bool v) {
    _notificationsUpdates = v;
    notifyListeners();
    _saveSettings();
  }

  void setAccessibilitySimpleMode(bool v) {
    _accessibilitySimpleMode = v;
    notifyListeners();
    _saveSettings();
  }

  Future<void> updateProfile(UserProfile profile) async {
    _profile = profile;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> addHome(HomeProfile home) async {
    _profile = _profile.copyWith(homes: [..._profile.homes, home]);
    notifyListeners();
    await _saveSettings();
  }

  Future<void> removeHome(String homeId) async {
    _profile = _profile.copyWith(
        homes: _profile.homes.where((h) => h.id != homeId).toList());
    notifyListeners();
    await _saveSettings();
  }

  // Manual sync method (can be called from UI)
  Future<void> syncProfileToMongoDB() async {
    await _syncToMongoDB();
  }

  // history
  void logControl(ControlLogEntry entry) {
    _logs.add(entry);
    notifyListeners();
  }
}
