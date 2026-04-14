import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'logic/navigation_engine.dart';
import 'logic/sensor_manager.dart';
import 'ui/screens/home_screen.dart';

void main() {
  // Flutter bağlamını başlat
  WidgetsFlutterBinding.ensureInitialized();

  // Ekran yönlendirme kısıtlamalarını esnetiyoruz (Tasarımların çalışması için)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    // Provider kullanarak NavigationEngine'i tüm uygulamaya enjekte ediyoruz
    MultiProvider(
      providers: [
        Provider<SensorManager>(
          create: (_) => SensorManager(),
        ),
        ChangeNotifierProxyProvider<SensorManager, NavigationEngine>(
          create: (context) => NavigationEngine(
            sensorManager: context.read<SensorManager>(),
            selectedVagon: 1, // Varsayılan değer
            direction: "Kızılay",
          ),
          update: (context, sensorManager, previous) => previous ?? 
              NavigationEngine(
                sensorManager: sensorManager,
                selectedVagon: 1,
                direction: "Kızılay",
              ),
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
        primarySwatch: Colors.red, // Metro kırmızı tonu
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto', // Tasarımdaki dijital/modern hava için
      ),
      // Başlangıç ekranı olarak HomeScreen'i belirliyoruz
      home: HomeScreen(),
    );
  }
}
