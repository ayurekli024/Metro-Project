import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/station_data.dart';
import '../../logic/navigation_engine.dart';
import 'tracking_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedStationName;
  int selectedVagon = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ankara Metro Takip")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Hangi İstasyondasınız?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedStationName,
              hint: const Text("İstasyon Seçin"),
              items: ankaraMetro.map((s) => DropdownMenuItem(value: s.name, child: Text(s.name))).toList(),
              onChanged: (val) => setState(() => selectedStationName = val),
            ),
            const SizedBox(height: 20),
            const Text("Kaçıncı Vagona Bindiniz? (1-6)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) => ChoiceChip(
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
                onPressed: selectedStationName == null ? null : () {
                  final navEngine = Provider.of<NavigationEngine>(context, listen: false);
                  
                  // Mevcut istasyonu ve bir sonraki istasyonu belirle (Basit mantık: listedeki bir sonraki)
                  final currentStation = ankaraMetro.firstWhere((s) => s.name == selectedStationName);
                  final currentIndex = ankaraMetro.indexOf(currentStation);
                  
                  if (currentIndex < ankaraMetro.length - 1) {
                    final nextStation = ankaraMetro[currentIndex + 1];
                    navEngine.startTrip(currentStation, nextStation, selectedVagon);
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TrackingScreen()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Bu son istasyondur, yolculuk başlatılamaz."))
                    );
                  }
                },
                child: const Text("YOLCULUĞU BAŞLAT"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
