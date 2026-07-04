import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:path_provider/path_provider.dart';

class DataLoggerScreen extends StatefulWidget {
  const DataLoggerScreen({super.key});

  @override
  _DataLoggerScreenState createState() => _DataLoggerScreenState();
}

class _DataLoggerScreenState extends State<DataLoggerScreen> {
  double magX = 0, magY = 0, magZ = 0, magTotal = 0;
  bool isRecording = false;
  List<String> logData = [];
  List<WiFiAccessPoint> wifiResults = [];
  StreamSubscription? _magSubscription;

  @override
  void initState() {
    super.initState();
    _magSubscription = magnetometerEvents.listen((event) {
      setState(() {
        magX = event.x;
        magY = event.y;
        magZ = event.z;
        // Manyetik alanın toplam şiddet vektörünü hesaplıyoruz
        magTotal = sqrt(pow(magX, 2) + pow(magY, 2) + pow(magZ, 2));
      });

      if (isRecording) {
        _logCurrentData("TUNNEL_RECORD");
      }
    });
  }

  // Ortamdaki Wi-Fi ağlarını (Örn: ABB Wi-Fi) MAC adresleriyle tarar
  Future<void> _scanWiFi(String stationName) async {
    final canScan = await WiFiScan.instance.canStartScan();
    if (canScan == CanStartScan.yes) {
      await WiFiScan.instance.startScan();
      final results = await WiFiScan.instance.getScannedResults();
      setState(() {
        wifiResults = results;
      });

      for (var wifi in results) {
        logData.add("${DateTime.now().toIso8601String()},$stationName,WIFI,${wifi.ssid},${wifi.bssid},${wifi.level}");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$stationName için ${results.length} Wi-Fi ağı kaydedildi!")),
      );
    }
  }

  // Manyetik verileri kronolojik olarak listeye yazar
  void _logCurrentData(String tag) {
    String timestamp = DateTime.now().toIso8601String();
    logData.add("$timestamp,$tag,MAGNETIC,$magX,$magY,$magZ,$magTotal");
  }

  // Toplanan tüm verileri telefonun belgeler klasörüne CSV olarak kaydeder
  Future<void> _saveDataToFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/metro_field_data.csv');

    String header = "Timestamp,Tag,Type,Value1,Value2,Value3,ValueTotal\n";
    String content = logData.join("\n");

    await file.writeAsString(header + content);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Veriler ${file.path} adresine kaydedildi!")),
    );

    setState(() => logData.clear());
  }

  @override
  void dispose() {
    _magSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sahadan Veri Toplama"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Manyetik Alan Şiddeti (μT)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("X: ${magX.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16)),
            Text("Y: ${magY.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16)),
            Text("Z: ${magZ.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16)),
            const Divider(),
            Text("TOPLAM ŞİDDET: ${magTotal.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
            const Spacer(),

            ElevatedButton.icon(
              icon: const Icon(Icons.wifi),
              label: const Text("İstasyondayım: Wi-Fi MAC Tara & Kaydet"),
              onPressed: () => _scanWiFi("ISTASYON_MANUEL"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            ),
            const SizedBox(height: 15),

            ElevatedButton.icon(
              icon: Icon(isRecording ? Icons.stop : Icons.fiber_manual_record),
              label: Text(isRecording ? "Tünel Kaydını Durdur" : "Tünel Manyetik Kaydını Başlat"),
              onPressed: () {
                setState(() => isRecording = !isRecording);
                if (!isRecording) {
                  _saveDataToFile();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isRecording ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}