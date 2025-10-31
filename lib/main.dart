import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home/home_screen.dart';
import 'providers/device_provider.dart';
import 'providers/room_provider.dart';
import 'providers/energy_provider.dart';
import 'screens/energy/energy_screen.dart';
import 'providers/settings_provider.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/room/room_detail_screen.dart';
import 'models/user_profile.dart';
import 'services/api_service.dart';
import 'services/mqtt_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize shared services
    final apiService = ApiService();
    final mqttService = MqttService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => RoomProvider(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => DeviceProvider(
            apiService: apiService,
            mqttService: mqttService,
          ),
        ),
        ChangeNotifierProxyProvider<RoomProvider, EnergyProvider>(
          create: (context) => EnergyProvider(
            roomProvider: Provider.of<RoomProvider>(context, listen: false),
            apiService: apiService,
          ),
          update: (context, room, previous) =>
              previous ??
              EnergyProvider(
                roomProvider: room,
                apiService: apiService,
              ),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) => MaterialApp(
          title: 'Smart Home Control',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            cardTheme: CardTheme(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            cardTheme: CardTheme(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          themeMode: settings.themeMode,
          locale: _mapLang(settings.language),
          supportedLocales: const [
            Locale('si'),
            Locale('ta'),
            Locale('en'),
            Locale('hi'),
          ],
          routes: {
            '/': (context) => const HomeScreen(),
            '/energy': (context) => const EnergyScreen(),
            '/profile': (context) => const ProfileScreen(),
          },
          onGenerateRoute: (settings) {
            // Handle dynamic routes like /room/:roomId
            final routeName = settings.name;
            if (routeName != null && routeName.startsWith('/room/')) {
              final roomId = routeName.replaceFirst('/room/', '');
              return MaterialPageRoute(
                builder: (context) => RoomDetailScreen(roomId: roomId),
                settings: settings,
              );
            }
            // Return null if route not found
            return null;
          },
          onUnknownRoute: (settings) {
            // Fallback for unknown routes
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('Not Found')),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Route not found: ${settings.name}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          initialRoute: '/',
        ),
      ),
    );
  }
}

Locale _mapLang(AppLanguage lang) {
  switch (lang) {
    case AppLanguage.si:
      return const Locale('si');
    case AppLanguage.ta:
      return const Locale('ta');
    case AppLanguage.en:
      return const Locale('en');
    case AppLanguage.hi:
      return const Locale('hi');
  }
  return const Locale('en');
}
