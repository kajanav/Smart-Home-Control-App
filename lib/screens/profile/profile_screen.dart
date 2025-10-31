import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/room_provider.dart';
import '../../models/user_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile & Customization'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Profile'),
              Tab(text: 'Rooms'),
              Tab(text: 'History'),
              Tab(text: 'Customize'),
              Tab(text: 'Security'),
              Tab(text: 'Automation'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ProfileTab(),
            _RoomsTab(),
            _HistoryTab(),
            _CustomizeTab(),
            _SecurityTab(),
            _AutomationTab(),
          ],
        ),
      ),
    );
  }
}

class _ProfileTab extends StatefulWidget {
  const _ProfileTab();

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  String _selectedUnit = 'kWh';
  bool _hasChanges = false;
  bool _updatingControllers =
      false; // Flag to prevent listener from firing during updates
  String?
      _lastKnownName; // Track last known values to avoid unnecessary updates
  String? _lastKnownAddress;

  @override
  void initState() {
    super.initState();
    final s = Provider.of<SettingsProvider>(context, listen: false);
    _nameController = TextEditingController(text: s.profile.name);
    _addressController = TextEditingController(text: s.profile.address);
    _selectedUnit = s.profile.preferredUnit;
    _lastKnownName = s.profile.name;
    _lastKnownAddress = s.profile.address;

    // Listen to controller changes
    _nameController.addListener(_onFieldChanged);
    _addressController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    // Don't trigger setState if we're programmatically updating controllers
    if (!_updatingControllers && !_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final s = Provider.of<SettingsProvider>(context, listen: false);

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Saving profile...'),
          ],
        ),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      await s.updateProfile(
        s.profile.copyWith(
          name: _nameController.text.trim().isEmpty
              ? 'Guest User'
              : _nameController.text.trim(),
          address: _addressController.text.trim().isEmpty
              ? '—'
              : _addressController.text.trim(),
          preferredUnit: _selectedUnit,
        ),
      );

      setState(() {
        _hasChanges = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Profile saved to MongoDB successfully!'),
            ],
          ),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Still saved locally, show warning
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child:
                    Text('Saved locally. MongoDB sync failed: ${e.toString()}'),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        // Update controllers when profile changes from external source
        // Use post-frame callback to avoid setState during build
        if (_lastKnownName != settings.profile.name ||
            _lastKnownAddress != settings.profile.address ||
            _selectedUnit != settings.profile.preferredUnit) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _updatingControllers = true;
              if (_nameController.text != settings.profile.name) {
                _nameController.text = settings.profile.name;
                _lastKnownName = settings.profile.name;
              }
              if (_addressController.text != settings.profile.address) {
                _addressController.text = settings.profile.address;
                _lastKnownAddress = settings.profile.address;
              }
              if (_selectedUnit != settings.profile.preferredUnit) {
                setState(() {
                  _selectedUnit = settings.profile.preferredUnit;
                });
              }
              _updatingControllers = false;
            }
          });
        }

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            // Profile Header with Avatar
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      // Avatar
                      Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                            child: Icon(
                              Icons.person_rounded,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.secondary,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        settings.profile.name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      if (settings.profile.address != '—' &&
                          settings.profile.address.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                settings.profile.address,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // Profile Details Card
            Transform.translate(
              offset: const Offset(0, -20),
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Profile Details',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _ProfileInfoRow(
                        icon: Icons.badge_outlined,
                        label: 'Name',
                        value: settings.profile.name,
                      ),
                      const Divider(height: 32),
                      _ProfileInfoRow(
                        icon: Icons.home_outlined,
                        label: 'Address',
                        value: settings.profile.address == '—' ||
                                settings.profile.address.isEmpty
                            ? 'Not set'
                            : settings.profile.address,
                      ),
                      const Divider(height: 32),
                      _ProfileInfoRow(
                        icon: Icons.speed_outlined,
                        label: 'Preferred Unit',
                        value: settings.profile.preferredUnit,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Edit Profile Card
            Card(
              margin: const EdgeInsets.all(16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.edit_outlined,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Edit Profile',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _nameController,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(
                          Icons.person_outline_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _addressController,
                      style: Theme.of(context).textTheme.bodyLarge,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        prefixIcon: Icon(
                          Icons.home_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      style: Theme.of(context).textTheme.bodyLarge,
                      items: const [
                        DropdownMenuItem(
                          value: 'kWh',
                          child: Row(
                            children: [
                              Icon(Icons.bolt, size: 20),
                              SizedBox(width: 8),
                              Text('kWh'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Rs',
                          child: Row(
                            children: [
                              Icon(Icons.currency_rupee, size: 20),
                              SizedBox(width: 8),
                              Text('Rs'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() {
                          _selectedUnit = v;
                          _hasChanges = true;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Preferred Unit',
                        prefixIcon: Icon(
                          Icons.speed_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _hasChanges ? _saveProfile : null,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    if (!_hasChanges)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'No changes to save',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

// Helper widget to display profile information in a row
class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color:
              Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer
                          .withOpacity(0.7),
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoomsTab extends StatelessWidget {
  const _RoomsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomProvider>(
      builder: (context, roomProvider, _) {
        if (roomProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (roomProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${roomProvider.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => roomProvider.loadRooms(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${roomProvider.rooms.length}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                        ),
                        const Text('Total Rooms'),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '${roomProvider.rooms.fold<int>(0, (sum, room) => sum + room.totalDevices)}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                        ),
                        const Text('Total Devices'),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '${roomProvider.favoriteRooms.length}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                        ),
                        const Text('Favorites'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Rooms List
            ...roomProvider.rooms.map((room) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/room/${room.id}');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              room.type.icon,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          room.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          room.isFavorite
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: room.isFavorite
                                              ? Colors.amber
                                              : null,
                                        ),
                                        onPressed: () {
                                          roomProvider
                                              .toggleRoomFavorite(room.id);
                                        },
                                      ),
                                    ],
                                  ),
                                  Text(
                                    room.description,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.devices,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${room.totalDevices} devices',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.power,
                                size: 16,
                                color: room.activeDevices > 0
                                    ? Colors.green
                                    : Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${room.activeDevices} active',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, '/room/${room.id}');
                              },
                              icon:
                                  const Icon(Icons.arrow_forward_ios, size: 16),
                              label: const Text('View'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            // Refresh Button
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => roomProvider.loadRooms(),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Rooms'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();
  @override
  Widget build(BuildContext context) {
    final s = Provider.of<SettingsProvider>(context);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: s.logs.length,
      itemBuilder: (context, i) {
        final e = s.logs[s.logs.length - 1 - i];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.history),
            title: Text(e.action),
            subtitle: Text('${e.deviceId} • ${e.timestamp}'),
          ),
        );
      },
    );
  }
}

class _CustomizeTab extends StatelessWidget {
  const _CustomizeTab();
  @override
  Widget build(BuildContext context) {
    final s = Provider.of<SettingsProvider>(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Column(
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('System Theme'),
                value: ThemeMode.system,
                groupValue: s.themeMode,
                onChanged: (v) {
                  if (v != null) s.setThemeMode(v);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Light Theme'),
                value: ThemeMode.light,
                groupValue: s.themeMode,
                onChanged: (v) {
                  if (v != null) s.setThemeMode(v);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark Theme'),
                value: ThemeMode.dark,
                groupValue: s.themeMode,
                onChanged: (v) {
                  if (v != null) s.setThemeMode(v);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(title: const Text('Language')),
              RadioListTile<AppLanguage>(
                  title: const Text('සිංහල (Sinhala)'),
                  value: AppLanguage.si,
                  groupValue: s.language,
                  onChanged: (v) {
                    if (v != null) s.setLanguage(v);
                  }),
              RadioListTile<AppLanguage>(
                  title: const Text('தமிழ் (Tamil)'),
                  value: AppLanguage.ta,
                  groupValue: s.language,
                  onChanged: (v) {
                    if (v != null) s.setLanguage(v);
                  }),
              RadioListTile<AppLanguage>(
                  title: const Text('English'),
                  value: AppLanguage.en,
                  groupValue: s.language,
                  onChanged: (v) {
                    if (v != null) s.setLanguage(v);
                  }),
              RadioListTile<AppLanguage>(
                  title: const Text('हिन्दी (Hindi)'),
                  value: AppLanguage.hi,
                  groupValue: s.language,
                  onChanged: (v) {
                    if (v != null) s.setLanguage(v);
                  }),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                  title: const Text('Power usage alerts'),
                  value: s.notificationsPower,
                  onChanged: s.setNotificationsPower),
              SwitchListTile(
                  title: const Text('Automation alerts'),
                  value: s.notificationsAutomation,
                  onChanged: s.setNotificationsAutomation),
              SwitchListTile(
                  title: const Text('App updates and news'),
                  value: s.notificationsUpdates,
                  onChanged: s.setNotificationsUpdates),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: SwitchListTile(
            title: const Text('Accessibility Mode'),
            subtitle: const Text('Simplified interface for better readability'),
            value: s.accessibilitySimpleMode,
            onChanged: s.setAccessibilitySimpleMode,
          ),
        ),
      ],
    );
  }
}

class _SecurityTab extends StatelessWidget {
  const _SecurityTab();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Security',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                const ListTile(
                  leading: Icon(Icons.lock_outline),
                  title: Text('Password Protection'),
                  subtitle: Text('Set or change your password (coming soon).'),
                ),
                const ListTile(
                  leading: Icon(Icons.fingerprint),
                  title: Text('Biometric Login'),
                  subtitle: Text(
                      'Use fingerprint/face ID to unlock the app (coming soon).'),
                ),
                const ListTile(
                  leading: Icon(Icons.bluetooth_searching),
                  title: Text('Secure Pairing'),
                  subtitle: Text(
                      'Pair devices with a secure handshake (coming soon).'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AutomationTab extends StatefulWidget {
  const _AutomationTab();

  @override
  State<_AutomationTab> createState() => _AutomationTabState();
}

class _AutomationTabState extends State<_AutomationTab> {
  bool leaveHomeEnabled = false;
  bool arriveHomeEnabled = true;

  bool scheduleEnabled = false;
  TimeOfDay? scheduleTimeAc;
  TimeOfDay? scheduleTimeLights;

  bool energySaveEnabled = false;
  TimeOfDay? peakStart;
  TimeOfDay? peakEnd;

  bool voiceControlEnabled = false; // Placeholder toggle

  bool motionSensorEnabled = false;
  bool temperatureSensorEnabled = false;

  Future<void> pickTime(BuildContext context, void Function(TimeOfDay) setFn,
      {TimeOfDay? initial}) async {
    final TimeOfDay now = TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial ?? now,
    );
    if (picked != null && mounted) {
      setFn(picked);
    }
  }

  String timeLabel(TimeOfDay? t) {
    if (t == null) return 'Not set';
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final mm = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$mm $period';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [cs.primary, cs.primary.withOpacity(0.75)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_mode, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Automation & Smart Functions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Automate routines, save energy, and control your home intelligently.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white.withOpacity(0.9)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: cs.primary,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Leave Home sequence triggered')),
                          );
                        },
                        icon: const Icon(Icons.rocket_launch_outlined),
                        label: const Text('Leave Home'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Arrive Home sequence triggered')),
                          );
                        },
                        icon: const Icon(Icons.home_outlined),
                        label: const Text('Arrive Home'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        leading: CircleAvatar(
                          backgroundColor: cs.primaryContainer,
                          child: Icon(Icons.rocket_launch_outlined,
                              color: cs.onPrimaryContainer),
                        ),
                        title: const Text('“Leave Home” Mode'),
                        subtitle: const Text(
                            'Turns off all lights, fans, ACs, and appliances.'),
                        trailing: Switch.adaptive(
                          value: leaveHomeEnabled,
                          onChanged: (v) =>
                              setState(() => leaveHomeEnabled = v),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8.0, bottom: 8.0),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: -8,
                          children: const [
                            Chip(label: Text('Lights')),
                            Chip(label: Text('Fans')),
                            Chip(label: Text('ACs')),
                            Chip(label: Text('Appliances')),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        leading: CircleAvatar(
                          backgroundColor: cs.secondaryContainer,
                          child: Icon(Icons.home_work_outlined,
                              color: cs.onSecondaryContainer),
                        ),
                        title: const Text('“Arrive Home” Mode'),
                        subtitle: const Text(
                            'Automatically activates preselected devices.'),
                        trailing: Switch.adaptive(
                          value: arriveHomeEnabled,
                          onChanged: (v) =>
                              setState(() => arriveHomeEnabled = v),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: -8,
                          children: const [
                            Chip(label: Text('Entry Lights')),
                            Chip(label: Text('Living AC')),
                            Chip(label: Text('Water Heater')),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                        child: Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Leave Home sequence triggered')),
                                );
                              },
                              icon: const Icon(Icons.power_settings_new),
                              label: const Text('Run Leave Home'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Arrive Home sequence triggered')),
                                );
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Run Arrive Home'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SwitchListTile.adaptive(
                        title: const Text('Scheduling System'),
                        subtitle:
                            const Text('Automate daily routines at set times.'),
                        value: scheduleEnabled,
                        onChanged: (v) => setState(() => scheduleEnabled = v),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                leading: const Icon(Icons.ac_unit_outlined),
                                title: const Text('AC time'),
                                subtitle: Text(timeLabel(scheduleTimeAc)),
                                trailing: TextButton(
                                  onPressed: scheduleEnabled
                                      ? () => pickTime(
                                            context,
                                            (t) => setState(
                                                () => scheduleTimeAc = t),
                                            initial: scheduleTimeAc,
                                          )
                                      : null,
                                  child: const Text('Set'),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                leading: const Icon(Icons.light_mode_outlined),
                                title: const Text('Lights time'),
                                subtitle: Text(timeLabel(scheduleTimeLights)),
                                trailing: TextButton(
                                  onPressed: scheduleEnabled
                                      ? () => pickTime(
                                            context,
                                            (t) => setState(
                                                () => scheduleTimeLights = t),
                                            initial: scheduleTimeLights,
                                          )
                                      : null,
                                  child: const Text('Set'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SwitchListTile.adaptive(
                        title: const Text('Energy Save Mode'),
                        subtitle: Text(
                          peakStart != null && peakEnd != null
                              ? 'Peak hours ${timeLabel(peakStart)} – ${timeLabel(peakEnd)}'
                              : 'Reduces usage during peak hours',
                        ),
                        value: energySaveEnabled,
                        onChanged: (v) => setState(() => energySaveEnabled = v),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              leading: const Icon(Icons.schedule_outlined),
                              title: const Text('Start'),
                              subtitle: Text(timeLabel(peakStart)),
                              trailing: TextButton(
                                onPressed: energySaveEnabled
                                    ? () => pickTime(
                                          context,
                                          (t) => setState(() => peakStart = t),
                                          initial: peakStart,
                                        )
                                    : null,
                                child: const Text('Set'),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              leading: const Icon(Icons.schedule),
                              title: const Text('End'),
                              subtitle: Text(timeLabel(peakEnd)),
                              trailing: TextButton(
                                onPressed: energySaveEnabled
                                    ? () => pickTime(
                                          context,
                                          (t) => setState(() => peakEnd = t),
                                          initial: peakEnd,
                                        )
                                    : null,
                                child: const Text('Set'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile.adaptive(
                        title: const Text('Voice Control (Optional)'),
                        subtitle: const Text(
                            'Integrate with Google Assistant or Alexa'),
                        value: voiceControlEnabled,
                        onChanged: (v) =>
                            setState(() => voiceControlEnabled = v),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: Wrap(
                          spacing: 8,
                          children: [
                            ActionChip(
                              avatar: const Icon(Icons.mic_none, size: 18),
                              label: const Text('Google Assistant'),
                              onPressed: voiceControlEnabled
                                  ? () => ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Google Assistant linking coming soon')),
                                      )
                                  : null,
                            ),
                            ActionChip(
                              avatar:
                                  const Icon(Icons.speaker_outlined, size: 18),
                              label: const Text('Amazon Alexa'),
                              onPressed: voiceControlEnabled
                                  ? () => ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Alexa linking coming soon')),
                                      )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    SwitchListTile.adaptive(
                      title: const Text('Motion Sensor'),
                      subtitle: const Text('Trigger actions based on movement'),
                      value: motionSensorEnabled,
                      onChanged: (v) => setState(() => motionSensorEnabled = v),
                    ),
                    const Divider(height: 1),
                    SwitchListTile.adaptive(
                      title: const Text('Temperature Sensor'),
                      subtitle: const Text('Trigger actions based on heat'),
                      value: temperatureSensorEnabled,
                      onChanged: (v) =>
                          setState(() => temperatureSensorEnabled = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                color: cs.surfaceVariant,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: Icon(Icons.auto_awesome, color: cs.onSurfaceVariant),
                  title: const Text('AI Learning'),
                  subtitle: const Text(
                      'Learns behavior for predictive actions (future upgrade).'),
                  trailing: Icon(Icons.lock_clock, color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
