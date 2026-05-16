import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'logic/navigation_engine.dart';
import 'logic/sensor_manager.dart';
import 'ui/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    MultiProvider(
      providers: [
        Provider<SensorManager>(
          create: (_) => SensorManager(),
        ),
        ChangeNotifierProxyProvider<SensorManager, NavigationEngine>(
          create: (context) => NavigationEngine(
            sensorManager: context.read<SensorManager>(),
          ),
          update: (context, sensorManager, previous) =>
          previous ?? NavigationEngine(sensorManager: sensorManager),
        ),
      ],
      child: const AnkaraMetroApp(),
    ),
  );
}

class AnkaraMetroApp extends StatelessWidget {
  const AnkaraMetroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ankara Metro Takip',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: HomeScreen(),
    );
  }
}
