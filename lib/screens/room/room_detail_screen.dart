import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/room_provider.dart';
import '../../providers/device_provider.dart';
import '../../models/device.dart';

class RoomDetailScreen extends StatelessWidget {
  final String roomId;

  const RoomDetailScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Details'),
      ),
      body: Consumer<RoomProvider>(
        builder: (context, roomProvider, _) {
          final room = roomProvider.getRoomById(roomId);

          if (room == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Room not found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Room Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      room.type.icon,
                      style: const TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      room.name,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      room.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _InfoChip(
                          icon: Icons.devices,
                          label: '${room.totalDevices} devices',
                        ),
                        const SizedBox(width: 16),
                        _InfoChip(
                          icon: Icons.power,
                          label: '${room.activeDevices} active',
                          color: room.activeDevices > 0
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Devices List
              Expanded(
                child: room.devices.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.devices_other_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No devices in this room',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: room.devices.length,
                        itemBuilder: (context, index) {
                          final device = room.devices[index];
                          return _DeviceCard(device: device, roomId: roomId);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(label),
      backgroundColor: color?.withOpacity(0.1),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final Device device;
  final String roomId;

  const _DeviceCard({
    required this.device,
    required this.roomId,
  });

  @override
  Widget build(BuildContext context) {
    final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
    final isOn = device.state.isOn;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isOn
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.grey[300],
          child: Icon(
            _getDeviceIcon(device.type),
            color:
                isOn ? Theme.of(context).colorScheme.primary : Colors.grey[600],
          ),
        ),
        title: Text(
          device.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isOn ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(device.type.displayName),
            if (device.currentLoad != null && isOn)
              Text(
                '${device.currentLoad!.toStringAsFixed(0)} W',
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: Switch(
          value: isOn,
          onChanged: (value) {
            deviceProvider.toggleDevice(device.id);
            // Update device in room provider
            Provider.of<RoomProvider>(context, listen: false)
                .updateDeviceInRoom(
              roomId,
              device.id,
              device.copyWith(state: device.state.copyWith(isOn: value)),
            );
          },
        ),
        onTap: () {
          // Show device details dialog or navigate to device control
          _showDeviceDetails(context, device);
        },
      ),
    );
  }

  IconData _getDeviceIcon(DeviceType type) {
    switch (type) {
      case DeviceType.light:
        return Icons.lightbulb;
      case DeviceType.fan:
        return Icons.ac_unit;
      case DeviceType.tv:
        return Icons.tv;
      case DeviceType.airConditioner:
        return Icons.ac_unit;
      case DeviceType.fridge:
        return Icons.kitchen;
      case DeviceType.hotPlate:
        return Icons.local_fire_department;
      case DeviceType.riceCooker:
        return Icons.restaurant;
      case DeviceType.exhaustFan:
        return Icons.air;
      case DeviceType.waterHeater:
        return Icons.water;
      case DeviceType.washingMachine:
        return Icons.local_laundry_service;
      case DeviceType.computer:
        return Icons.computer;
      case DeviceType.printer:
        return Icons.print;
      case DeviceType.gateMotor:
        return Icons.build;
      case DeviceType.cctvCamera:
        return Icons.videocam;
      case DeviceType.gardenLight:
        return Icons.light_mode;
      case DeviceType.generic:
        return Icons.devices;
    }
  }

  void _showDeviceDetails(BuildContext context, Device device) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              device.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text('Type: ${device.type.displayName}'),
            Text('Status: ${device.state.isOn ? "On" : "Off"}'),
            if (device.state.isOn) ...[
              if (device.state.brightness != null)
                Text('Brightness: ${device.state.brightness}%'),
              if (device.state.fanSpeed != null)
                Text('Fan Speed: ${device.state.fanSpeed}'),
              if (device.state.temperature != null)
                Text('Temperature: ${device.state.temperature}°C'),
              if (device.currentLoad != null)
                Text('Power: ${device.currentLoad!.toStringAsFixed(0)} W'),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
