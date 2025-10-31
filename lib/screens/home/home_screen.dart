import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../providers/room_provider.dart';
import '../../models/room.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedFilter; // null = all, 'favorites' = favorites only

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Home Control'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload Rooms',
            onPressed: () {
              Provider.of<RoomProvider>(context, listen: false)
                  .loadDefaultRooms();
            },
          ),
          IconButton(
            icon: const Icon(Icons.energy_savings_leaf_outlined),
            tooltip: 'Energy',
            onPressed: () {
              Navigator.pushNamed(context, '/energy');
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: Consumer<RoomProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadRooms(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Stats Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.devices,
                        value: provider.rooms
                            .fold<int>(
                              0,
                              (sum, room) => sum + room.totalDevices,
                            )
                            .toString(),
                        label: 'Total Devices',
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.power,
                        value: provider.rooms
                            .fold<int>(
                              0,
                              (sum, room) => sum + room.activeDevices,
                            )
                            .toString(),
                        label: 'Active Devices',
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              // Debug info to show room count
              if (kDebugMode)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '📊 Total rooms loaded: ${provider.rooms.length}',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 8),

              // Filter Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'all',
                            label: Text('All Rooms'),
                            icon: Icon(Icons.home_outlined),
                          ),
                          ButtonSegment(
                            value: 'favorites',
                            label: Text('Favorites'),
                            icon: Icon(Icons.star_outline),
                          ),
                        ],
                        selected: {_selectedFilter ?? 'all'},
                        onSelectionChanged: (Set<String> selection) {
                          setState(() {
                            _selectedFilter = selection.first == 'all'
                                ? null
                                : selection.first;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Rooms List
              Expanded(
                child: Builder(
                  builder: (context) {
                    final roomsToShow = _selectedFilter == 'favorites'
                        ? provider.favoriteRooms
                        : provider.rooms;

                    if (roomsToShow.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _selectedFilter == 'favorites'
                                  ? Icons.star_border
                                  : Icons.home_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _selectedFilter == 'favorites'
                                  ? 'No favorite rooms'
                                  : 'No rooms available',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: roomsToShow.length,
                      itemBuilder: (context, index) {
                        final room = roomsToShow[index];
                        return _RoomCard(room: room);
                      },
                    );
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final Room room;

  const _RoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          // Navigate to room detail screen
          Navigator.pushNamed(context, '/room/${room.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    room.type.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                  IconButton(
                    icon: Icon(
                      room.isFavorite ? Icons.star : Icons.star_border,
                      color: room.isFavorite ? Colors.amber : null,
                    ),
                    onPressed: () {
                      Provider.of<RoomProvider>(context, listen: false)
                          .toggleRoomFavorite(room.id);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                room.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                room.description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.devices, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${room.totalDevices} devices',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.power,
                    size: 16,
                    color: room.activeDevices > 0 ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${room.activeDevices} active',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: room.activeDevices > 0
                              ? Colors.green
                              : Colors.grey,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
