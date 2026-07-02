import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/metro_db.dart';
import '../../logic/navigation_engine.dart';
import 'tracking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedLineCode = "M1";
  String? selectedStationName;
  int selectedVagon = 1;
  bool isForwardDirection = true; // True: İleri Yön, False: Geri Yön
  List<Map<String, dynamic>> currentLineStations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStations(selectedLineCode);
  }

  // Veritabanından durakları çekiyoruz
  Future<void> _loadStations(String lineCode) async {
    setState(() => isLoading = true);
    final stations = await MetroDatabase.instance.getStationsByLine(lineCode);
    setState(() {
      currentLineStations = stations;
      selectedStationName = stations.isNotEmpty ? stations.first['station_name'] : null;
      isLoading = false;
    });
  }

  // Arayüzde yöne göre dinamik başlıklar oluşturur
  String getDirectionText(bool isForward) {
    if (currentLineStations.isEmpty) return "Yön";
    String first = currentLineStations.first['station_name'];
    String last = currentLineStations.last['station_name'];
    return isForward ? "$first -> $last Yönü" : "$last -> $first Yönü";
  }

  // Hat atlama ve köprüleme lojiği
  Future<Map<String, dynamic>?> _calculateNextStation(Map<String, dynamic> current) async {
    int order = current['station_order'];
    String line = current['line_code'];
    final db = await MetroDatabase.instance.database;

    if (isForwardDirection) {
      var nextList = await db.query('stations', where: 'line_code = ? AND station_order = ?', whereArgs: [line, order + 1]);
      if (nextList.isNotEmpty) return nextList.first;

      if (line == "M2" && current['station_name'] == "Necatibey") {
        var m1 = await db.query('stations', where: 'line_code = ? AND station_order = ?', whereArgs: ["M1", 1]);
        return m1.isNotEmpty ? m1.first : null;
      }
      if (line == "M1" && current['station_name'] == "Batıkent") {
        var m3 = await db.query('stations', where: 'line_code = ? AND station_order = ?', whereArgs: ["M3", 1]);
        return m3.isNotEmpty ? m3.first : null;
      }
    } else {
      var prevList = await db.query('stations', where: 'line_code = ? AND station_order = ?', whereArgs: [line, order - 1]);
      if (prevList.isNotEmpty) return prevList.first;

      if (line == "M3" && current['station_name'] == "Batı Merkez") {
        var m1 = await db.query('stations', where: 'line_code = ? AND station_order = ?', whereArgs: ["M1", 12]);
        return m1.isNotEmpty ? m1.first : null;
      }
      if (line == "M1" && current['station_name'] == "Kızılay") {
        var m2 = await db.query('stations', where: 'line_code = ? AND station_order = ?', whereArgs: ["M2", 11]);
        return m2.isNotEmpty ? m2.first : null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ankara Metro Takip")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Hangi Hattı Kullanacaksınız?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedLineCode,
              items: ["M1", "M2", "M3", "M4", "M5", "M6", "M7", "M8", "M9", "M2A", "A1", "A2"]
                  .map((line) => DropdownMenuItem(value: line, child: Text("$line Hattı")))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => selectedLineCode = val);
                  _loadStations(val);
                }
              },
            ),
            const SizedBox(height: 15),

            const Text("Gidiş Yönünüz Nedir?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8)
              ),
              child: Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: Text(getDirectionText(true), style: const TextStyle(fontSize: 13)),
                      value: true,
                      groupValue: isForwardDirection,
                      onChanged: (val) => setState(() => isForwardDirection = val!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: Text(getDirectionText(false), style: const TextStyle(fontSize: 13)),
                      value: false,
                      groupValue: isForwardDirection,
                      onChanged: (val) => setState(() => isForwardDirection = val!),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            const Text("Hangi İstasyondasınız?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedStationName,
              hint: const Text("İstasyon Seçin"),
              items: currentLineStations
                  .map((s) => DropdownMenuItem<String>(value: s['station_name'], child: Text(s['station_name'])))
                  .toList(),
              onChanged: (val) => setState(() => selectedStationName = val),
            ),
            const SizedBox(height: 15),

            const Text("Kaçıncı Vagondasınız? (1-6)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                  6,
                      (index) => ChoiceChip(
                    label: Text("${index + 1}"),
                    selected: selectedVagon == index + 1,
                    onSelected: (selected) => setState(() => selectedVagon = index + 1),
                  )),
            ),
            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: selectedStationName == null ? null : () async {
                  final navEngine = Provider.of<NavigationEngine>(context, listen: false);

                  final currentStation = currentLineStations.firstWhere((s) => s['station_name'] == selectedStationName);
                  final nextStation = await _calculateNextStation(currentStation);

                  if (nextStation != null) {
                    // DİKKAT: isForwardDirection parametresi buraya eklendi!
                    navEngine.startTrip(currentStation, nextStation, selectedVagon, isForwardDirection);

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TrackingScreen()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Bu yön için son istasyondasınız, yolculuk başlatılamaz."))
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("YOLCULUĞU BAŞLAT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}