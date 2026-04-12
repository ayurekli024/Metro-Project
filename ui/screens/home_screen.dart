import 'package:flutter/material.dart';
import '../../data/station_data.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedStation;
  int selectedVagon = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ankara Metro Takip")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hangi İstasyondasınız?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedStation,
              items: ankaraMetro.map((s) => DropdownMenuItem(value: s.name, child: Text(s.name))).toList(),
              onChanged: (val) => setState(() => selectedStation = val),
            ),
            SizedBox(height: 20),
            Text("Kaçıncı Vagona Bindiniz? (1-6)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) => ChoiceChip(
                label: Text("${index + 1}"),
                selected: selectedVagon == index + 1,
                onSelected: (selected) => setState(() => selectedVagon = index + 1),
              )),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // TrackingScreen'e yönlendirme ve takip başlatma
                },
                child: Text("YOLCULUĞU BAŞLAT"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
