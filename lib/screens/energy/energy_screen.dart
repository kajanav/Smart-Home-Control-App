import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/energy_provider.dart';
import '../../providers/room_provider.dart';
import '../../models/energy.dart';

class EnergyScreen extends StatelessWidget {
  const EnergyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Energy Monitoring'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Real-time'),
              Tab(text: 'Reports'),
              Tab(text: 'Insights'),
              Tab(text: 'Export'),
            ],
          ),
        ),
        body: Consumer2<EnergyProvider, RoomProvider>(
          builder: (context, energy, rooms, _) {
            final report = energy.generateReport();
            return TabBarView(
              children: [
                _RealtimeTab(),
                _ReportsTab(report: report),
                _InsightsTab(report: report),
                _ExportTab(report: report),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RealtimeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final energy = Provider.of<EnergyProvider>(context);
    final rooms = Provider.of<RoomProvider>(context).rooms;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Estimated Monthly Bill',
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 6),
                    Text(
                        'Rs ${energy.getEstimatedMonthlyBillRs().toStringAsFixed(0)}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: [
                    const Text('Rs/kWh'),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        initialValue: energy.rsPerKWh.toStringAsFixed(1),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onFieldSubmitted: (v) {
                          final d = double.tryParse(v);
                          if (d != null) energy.setTariff(d);
                        },
                        decoration: const InputDecoration(
                            isDense: true, border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...rooms.expand((r) => r.devices).map((d) {
          final now = DateTime.now();
          final last = energy.samples.where((s) =>
              s.deviceId == d.id &&
              s.timestamp.isAfter(now.subtract(const Duration(minutes: 5))));
          final lastWatts = last.isEmpty ? 0.0 : last.last.watts;
          return Card(
            child: ListTile(
              leading: const Icon(Icons.power),
              title: Text(d.name),
              subtitle: Text(d.type.displayName),
              trailing: Text('${lastWatts.toStringAsFixed(0)} W'),
            ),
          );
        }),
      ],
    );
  }
}

class _ReportsTab extends StatelessWidget {
  final EnergyReport report;
  const _ReportsTab({required this.report});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Daily (last 24h)',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _MiniBars(buckets: report.daily),
        const SizedBox(height: 16),
        Text('Weekly (last 7d)',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _MiniBars(buckets: report.weekly),
        const SizedBox(height: 16),
        Text('Monthly (last 30d)',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _MiniBars(buckets: report.monthly),
      ],
    );
  }
}

class _MiniBars extends StatelessWidget {
  final List<EnergySummaryBucket> buckets;
  const _MiniBars({required this.buckets});

  @override
  Widget build(BuildContext context) {
    final max = buckets.fold<double>(0, (m, b) => b.kWh > m ? b.kWh : m);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: buckets.map((b) {
              final double h = max == 0 ? 0.0 : (b.kWh / max) * 100.0;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                          height: h,
                          color: Theme.of(context).colorScheme.primary,
                          width: 8),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _InsightsTab extends StatelessWidget {
  final EnergyReport report;
  const _InsightsTab({required this.report});

  @override
  Widget build(BuildContext context) {
    final rooms = Provider.of<RoomProvider>(context).rooms;

    // Create a map of deviceId -> device name
    final deviceMap = <String, String>{};
    for (final room in rooms) {
      for (final device in room.devices) {
        deviceMap[device.id] = device.name;
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('High-energy devices',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...report.deviceRanking.take(10).map((i) {
          final deviceName = deviceMap[i.deviceId] ?? i.deviceId;
          return Card(
            child: ListTile(
              leading: const Icon(Icons.bolt),
              title: Text(deviceName),
              subtitle: Text('${i.avgWatts.toStringAsFixed(0)} W avg'),
              trailing: Text('${i.totalKWh.toStringAsFixed(2)} kWh'),
            ),
          );
        }),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Smart suggestions',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                const Text(
                    'Coming soon: personalized tips to reduce energy usage.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ExportTab extends StatelessWidget {
  final EnergyReport report;
  const _ExportTab({required this.report});

  @override
  Widget build(BuildContext context) {
    final energy = Provider.of<EnergyProvider>(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          title: const Text('Overconsumption alerts'),
          subtitle: Text(
              'Daily threshold: ${energy.alertKWhDaily.toStringAsFixed(1)} kWh'),
          value: energy.alertsEnabled,
          onChanged: energy.setAlerts,
        ),
        ListTile(
          title: const Text('Set daily alert threshold (kWh)'),
          trailing: SizedBox(
            width: 90,
            child: TextFormField(
              initialValue: energy.alertKWhDaily.toStringAsFixed(1),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onFieldSubmitted: (v) {
                final d = double.tryParse(v);
                if (d != null) energy.setDailyAlertThreshold(d);
              },
              decoration: const InputDecoration(
                  isDense: true, border: OutlineInputBorder()),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () async {
            await energy.exportPdf(report);
          },
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('Export PDF'),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () async {
            await energy.exportExcel(report);
          },
          icon: const Icon(Icons.table_chart),
          label: const Text('Export Excel'),
        ),
      ],
    );
  }
}
