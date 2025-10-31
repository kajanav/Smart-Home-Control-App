import 'package:flutter/foundation.dart';
import '../models/automation.dart';
// import '../services/automation_service.dart';

class AutomationProvider with ChangeNotifier {
  List<Automation> _automations = [];
  bool _isLoading = false;
  String? _error;

  List<Automation> get automations => _automations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get automations by type
  List<Automation> getAutomationsByType(AutomationType type) {
    return _automations.where((a) => a.type == type).toList();
  }

  // Get enabled automations
  List<Automation> get enabledAutomations =>
      _automations.where((a) => a.isEnabled).toList();

  AutomationProvider() {
    _initializeAutomations();
  }

  Future<void> _initializeAutomations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _automations = await _loadDefaultAutomations();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Automation>> _loadDefaultAutomations() async {
    // Load default automation presets
    return _getDefaultAutomations();
  }

  List<Automation> _getDefaultAutomations() {
    final now = DateTime.now();
    return [
      // Leave Home Mode
      Automation(
        id: 'leave-home',
        name: 'Leave Home',
        type: AutomationType.leaveHome,
        description: 'Turn off all lights, fans, ACs, and appliances',
        actions: [
          // Add sample actions
          AutomationAction(
            deviceId: 'all-lights',
            actionType: ActionType.turnOff,
            parameters: {},
          ),
          AutomationAction(
            deviceId: 'all-fans',
            actionType: ActionType.turnOff,
            parameters: {},
          ),
          AutomationAction(
            deviceId: 'all-acs',
            actionType: ActionType.setTemperature,
            parameters: {'temperature': 26},
          ),
        ],
        trigger: AutomationTrigger(
          type: TriggerType.manual,
          manualTrigger: ManualTrigger(requiresConfirmation: false),
        ),
        createdAt: now,
      ),

      // Arrive Home Mode
      Automation(
        id: 'arrive-home',
        name: 'Arrive Home',
        type: AutomationType.arriveHome,
        description: 'Welcome home with lights and climate control',
        actions: [
          AutomationAction(
            deviceId: 'entry-lights',
            actionType: ActionType.turnOn,
            parameters: {},
          ),
          AutomationAction(
            deviceId: 'living-room-ac',
            actionType: ActionType.setTemperature,
            parameters: {'temperature': 24},
          ),
        ],
        trigger: AutomationTrigger(
          type: TriggerType.location,
          locationTrigger: LocationTrigger(
            latitude: 0.0, // To be configured
            longitude: 0.0, // To be configured
            radius: 100,
            event: LocationEvent.enter,
          ),
        ),
        createdAt: now,
      ),

      // Morning Schedule
      Automation(
        id: 'morning-routine',
        name: 'Morning Routine',
        type: AutomationType.schedule,
        description: 'Wake up with lights and climate control',
        actions: [
          AutomationAction(
            deviceId: 'bedroom-lights',
            actionType: ActionType.setBrightness,
            parameters: {'brightness': 80},
          ),
          AutomationAction(
            deviceId: 'bedroom-ac',
            actionType: ActionType.setTemperature,
            parameters: {'temperature': 22},
          ),
        ],
        trigger: AutomationTrigger(
          type: TriggerType.time,
          timeTrigger: TimeTrigger(
            time: '06:30',
            daysOfWeek: [1, 2, 3, 4, 5], // Monday-Friday
            isRecurring: true,
          ),
        ),
        createdAt: now,
      ),
    ];
  }

  // Add new automation
  Future<void> addAutomation(Automation automation) async {
    _automations.add(automation);
    notifyListeners();
    
    // Save to backend
    await _saveAutomation(automation);
  }

  // Update automation
  Future<void> updateAutomation(Automation automation) async {
    final index = _automations.indexWhere((a) => a.id == automation.id);
    if (index != -1) {
      _automations[index] = automation;
      notifyListeners();
      await _saveAutomation(automation);
    }
  }

  // Delete automation
  Future<void> deleteAutomation(String automationId) async {
    _automations.removeWhere((a) => a.id == automationId);
    notifyListeners();
    await _deleteAutomation(automationId);
  }

  // Toggle automation
  void toggleAutomation(String automationId) {
    final index = _automations.indexWhere((a) => a.id == automationId);
    if (index != -1) {
      _automations[index] = _automations[index].copyWith(
        isEnabled: !_automations[index].isEnabled,
      );
      notifyListeners();
    }
  }

  // Execute automation
  Future<void> executeAutomation(String automationId) async {
    final automation = _automations.firstWhere((a) => a.id == automationId);
    
    if (!automation.isEnabled) {
      throw Exception('Automation is disabled');
    }

    try {
      // Execute each action
      for (final action in automation.actions) {
        await _executeAction(action);
      }

      // Update last executed time
      final index = _automations.indexWhere((a) => a.id == automationId);
      if (index != -1) {
        _automations[index] = automation.copyWith(
          lastExecuted: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to execute automation: $e');
    }
  }

  // Execute individual action
  Future<void> _executeAction(AutomationAction action) async {
    // TODO: Implement actual device control
    print('Executing action: ${action.actionType} on device ${action.deviceId}');
    
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // Save automation to backend
  Future<void> _saveAutomation(Automation automation) async {
    // TODO: Implement API call
    print('Saving automation: ${automation.name}');
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // Delete automation from backend
  Future<void> _deleteAutomation(String automationId) async {
    // TODO: Implement API call
    print('Deleting automation: $automationId');
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

