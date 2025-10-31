class EnergySample {
  final String deviceId;
  final DateTime timestamp;
  final double watts; // instantaneous power in Watts

  const EnergySample({
    required this.deviceId,
    required this.timestamp,
    required this.watts,
  });
}

class EnergySummaryBucket {
  final DateTime periodStart;
  final double kWh; // energy over period

  const EnergySummaryBucket({
    required this.periodStart,
    required this.kWh,
  });
}

class DeviceEnergyInsights {
  final String deviceId;
  final double totalKWh;
  final double avgWatts;

  const DeviceEnergyInsights({
    required this.deviceId,
    required this.totalKWh,
    required this.avgWatts,
  });
}

class EnergyReport {
  final List<EnergySummaryBucket> daily; // last 24h hourly buckets
  final List<EnergySummaryBucket> weekly; // last 7 days daily buckets
  final List<EnergySummaryBucket> monthly; // last 30 days daily buckets
  final List<DeviceEnergyInsights> deviceRanking;

  const EnergyReport({
    required this.daily,
    required this.weekly,
    required this.monthly,
    required this.deviceRanking,
  });
}
