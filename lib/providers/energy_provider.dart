import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/energy.dart';
import '../models/device.dart';
import '../services/api_service.dart';
import 'room_provider.dart';

class EnergyProvider with ChangeNotifier {
  final RoomProvider roomProvider;
  final ApiService _apiService;

  final List<EnergySample> _samples = [];
  Timer? _timer;
  double _rsPerKWh = 22.0; // default tariff
  double _alertKWhDaily = 10.0; // example threshold
  bool _alertsEnabled = true;

  EnergyProvider({
    required this.roomProvider,
    ApiService? apiService,
  }) : _apiService = apiService ?? ApiService() {
    _startSampling();
    _loadHistoricalData();
  }

  Future<void> _loadHistoricalData() async {
    try {
      final now = DateTime.now();
      final start = now.subtract(const Duration(days: 30));
      final data = await _apiService.getEnergyData(start: start, end: now);

      if (data.containsKey('samples')) {
        final samplesList = data['samples'] as List;
        _samples.clear();
        _samples.addAll(samplesList.map((s) => EnergySample(
              deviceId: s['deviceId'] as String,
              timestamp: DateTime.parse(s['timestamp'] as String),
              watts: (s['watts'] as num).toDouble(),
            )));
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading historical energy data: $e');
      }
      // Continue with local sampling if API fails
    }
  }

  List<EnergySample> get samples => List.unmodifiable(_samples);
  double get rsPerKWh => _rsPerKWh;
  bool get alertsEnabled => _alertsEnabled;
  double get alertKWhDaily => _alertKWhDaily;

  void setTariff(double rsPerKWh) {
    _rsPerKWh = rsPerKWh.clamp(0, 1000).toDouble();
    notifyListeners();
  }

  void setAlerts(bool enabled) {
    _alertsEnabled = enabled;
    notifyListeners();
  }

  void setDailyAlertThreshold(double kWh) {
    _alertKWhDaily = kWh.clamp(0, 10000).toDouble();
    notifyListeners();
  }

  void _startSampling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _sampleOnce());
  }

  void _sampleOnce() async {
    final now = DateTime.now();
    final rooms = roomProvider.rooms;
    if (rooms.isEmpty) return;

    for (final room in rooms) {
      for (final device in room.devices) {
        final watts = _estimateWatts(device);
        final sample =
            EnergySample(deviceId: device.id, timestamp: now, watts: watts);
        _samples.add(sample);

        // Sync to backend (non-blocking)
        _apiService.postEnergySample(device.id, watts, now).catchError((e) {
          if (kDebugMode) {
            print('Error syncing energy sample: $e');
          }
        });
      }
    }

    _enforceRetention();
    _checkDailyAlert();
    notifyListeners();
  }

  double _estimateWatts(Device device) {
    if (!device.state.isOn) return 0;
    // Priority: explicit currentLoad, then by type heuristic
    if (device.currentLoad != null)
      return device.currentLoad!.clamp(0, 10000).toDouble();
    switch (device.type) {
      case DeviceType.light:
        final b = device.state.brightness ?? 100;
        return 10 + 0.9 * b; // 10-100W
      case DeviceType.fan:
        final s = device.state.fanSpeed ?? 3;
        return 20.0 * s; // 20-100W
      case DeviceType.tv:
        return 120;
      case DeviceType.airConditioner:
        return 900; // simplified
      case DeviceType.fridge:
        return 150;
      case DeviceType.hotPlate:
        return 1500;
      case DeviceType.riceCooker:
        return 700;
      case DeviceType.exhaustFan:
        return 60;
      case DeviceType.waterHeater:
        return 2000;
      case DeviceType.washingMachine:
        return 500;
      case DeviceType.computer:
        return 200;
      case DeviceType.printer:
        return 50;
      case DeviceType.gateMotor:
        return 300;
      case DeviceType.cctvCamera:
        return 10;
      case DeviceType.gardenLight:
        return 18;
      case DeviceType.generic:
        return 100;
    }
  }

  void _enforceRetention() {
    final cutoff = DateTime.now().subtract(const Duration(days: 35));
    _samples.removeWhere((s) => s.timestamp.isBefore(cutoff));
  }

  double _integrateKWh(Iterable<EnergySample> samples) {
    if (samples.isEmpty) return 0;
    // Convert discrete samples to kWh assuming step sampling every 5s
    final secondsPerSample = 5.0;
    final wattSeconds =
        samples.fold<double>(0, (sum, s) => sum + s.watts * secondsPerSample);
    return wattSeconds / 3600000.0;
  }

  double getEstimatedMonthlyBillRs() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final monthSamples = _samples.where((s) => !s.timestamp.isBefore(start));
    final kwh = _integrateKWh(monthSamples);
    return kwh * _rsPerKWh;
  }

  EnergyReport generateReport() {
    final now = DateTime.now();

    List<EnergySummaryBucket> daily = [];
    for (int h = 23; h >= 0; h--) {
      final start =
          DateTime(now.year, now.month, now.day, 0).add(Duration(hours: h));
      final end = start.add(const Duration(hours: 1));
      final kwh = _integrateKWh(_samples.where(
          (s) => !s.timestamp.isBefore(start) && s.timestamp.isBefore(end)));
      daily.add(EnergySummaryBucket(periodStart: start, kWh: kwh));
    }

    List<EnergySummaryBucket> weekly = [];
    for (int d = 6; d >= 0; d--) {
      final start =
          DateTime(now.year, now.month, now.day).subtract(Duration(days: d));
      final end = start.add(const Duration(days: 1));
      final kwh = _integrateKWh(_samples.where(
          (s) => !s.timestamp.isBefore(start) && s.timestamp.isBefore(end)));
      weekly.add(EnergySummaryBucket(periodStart: start, kWh: kwh));
    }

    List<EnergySummaryBucket> monthly = [];
    for (int d = 29; d >= 0; d--) {
      final start =
          DateTime(now.year, now.month, now.day).subtract(Duration(days: d));
      final end = start.add(const Duration(days: 1));
      final kwh = _integrateKWh(_samples.where(
          (s) => !s.timestamp.isBefore(start) && s.timestamp.isBefore(end)));
      monthly.add(EnergySummaryBucket(periodStart: start, kWh: kwh));
    }

    // Device ranking
    final deviceIds = {for (final s in _samples) s.deviceId};
    final insights = <DeviceEnergyInsights>[];
    for (final id in deviceIds) {
      final ds = _samples.where((s) => s.deviceId == id);
      final kwh = _integrateKWh(ds);
      final avg = ds.isEmpty
          ? 0.0
          : ds.fold<double>(0, (sum, s) => sum + s.watts) / ds.length;
      insights.add(
          DeviceEnergyInsights(deviceId: id, totalKWh: kwh, avgWatts: avg));
    }
    insights.sort((a, b) => b.totalKWh.compareTo(a.totalKWh));

    return EnergyReport(
        daily: daily,
        weekly: weekly,
        monthly: monthly,
        deviceRanking: insights);
  }

  void _checkDailyAlert() {
    if (!_alertsEnabled) return;
    final todayStart =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final todayKWh =
        _integrateKWh(_samples.where((s) => !s.timestamp.isBefore(todayStart)));
    if (todayKWh > _alertKWhDaily) {
      if (kDebugMode) {
        print(
            'Energy alert: Daily usage ${todayKWh.toStringAsFixed(2)} kWh exceeded threshold $_alertKWhDaily');
      }
      // Hook for notifications/email integration
    }
  }

  // Export stubs (to be implemented with pdf/excel integrations)
  Future<void> exportPdf(EnergyReport report) async {}
  Future<void> exportExcel(EnergyReport report) async {}

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
