import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // State yönetimi için (veya senin tercihin)
import '../../logic/navigation_engine.dart';
import '../widgets/approaching_station_widget.dart'; // Önceki adımda yazdığımız widget

class TrackingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // NavigationEngine'i dinliyoruz
    final navEngine = Provider.of<NavigationEngine>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFC0C0C0), // Tasarımdaki gri tonu
      body: OrientationBuilder(
        builder: (context, orientation) {
          return orientation == Orientation.portrait
              ? _buildPortraitLayout(context, navEngine)
              : _buildLandscapeLayout(context, navEngine);
        },
      ),
    );
  }

  // --- DİKEY TASARIM (Portre) ---
  Widget _buildPortraitLayout(BuildContext context, NavigationEngine engine) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHeader("Batıkent - Kızılay Hattı", "Kızılay Yönü"),
            const SizedBox(height: 20),
            _buildVagonVisual(engine.selectedVagon, isHorizontal: false),
            const SizedBox(height: 30),
            _buildTimeCard("Akköprü", "12:16", "Kızılay", "12:28"),
            const Spacer(),
            if (engine.isApproaching)
              ApproachingStationWidget(
                stationName: engine.nextStation?.name ?? "SIHHIYE",
                isApproaching: true,
              ),
            const SizedBox(height: 20),
            _buildVerticalTimeline(),
            const SizedBox(height: 30),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  // --- YATAY TASARIM (Landscape) ---
  Widget _buildLandscapeLayout(BuildContext context, NavigationEngine engine) {
    return SafeArea(
      child: Stack(
        children: [
          // Sol Üst: Hat Bilgisi
          Positioned(
            top: 20,
            left: 20,
            child: _buildHeader("Ankara Metrosu", "Kızılay - Batıkent"),
          ),
          
          // Sağ Üst: Saat ve Hız
          Positioned(
            top: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text("16:45", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const Text("1 Ocak Pazar", style: TextStyle(fontSize: 14)),
                const SizedBox(height: 20),
                _buildSpeedometer(engine.currentSpeed),
              ],
            ),
          ),

          // Orta: Ana Hat Çizgisi
          Center(child: _buildHorizontalMainLine()),

          // Alt: Vagon Sistemi ve Aktarma Okları
          Positioned(
            bottom: 30,
            left: 50,
            right: 150,
            child: _buildLandscapeVagonSystem(engine),
          ),
        ],
      ),
    );
  }

  // --- YARDIMCI WIDGET'LAR ---

  Widget _buildHeader(String title, String subTitle) {
    return Row(
      children: [
        Image.asset('assets/m_logo.png', width: 40), // Metro logosu
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(subTitle, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ],
    );
  }

  Widget _buildVagonVisual(int selected, {required bool isHorizontal}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        int vagonNo = 6 - index;
        bool isSelected = selected == vagonNo;
        return Container(
          width: 50,
          height: 35,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: isSelected 
              ? const Icon(Icons.location_on, color: Colors.red) 
              : Text("$vagonNo"),
          ),
        );
      }),
    );
  }

  Widget _buildSpeedometer(double speed) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Center(
        child: Text("${speed.toStringAsFixed(0)}\nkm/h", textAlign: TextAlign.center),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(onPressed: () {}, child: const Text("Harita Görünümü")),
        ElevatedButton(onPressed: () {}, child: const Text("Çıkışa Yönlendir")),
      ],
    );
  }

  // Yatay moddaki vagon ve ok sistemi
  Widget _buildLandscapeVagonSystem(NavigationEngine engine) {
    return Column(
      children: [
        _buildVagonVisual(engine.selectedVagon, isHorizontal: true),
        const SizedBox(height: 10),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(Icons.arrow_downward), // Tasarımdaki oklar
            Text("M4 aktarması için karşı platforma geçin"),
            Icon(Icons.arrow_forward),
          ],
        )
      ],
    );
  }

  // Ortadaki ana çizgi tasarımı
  Widget _buildHorizontalMainLine() {
    return Container(
      height: 4,
      width: double.infinity,
      color: Colors.black,
      margin: const EdgeInsets.symmetric(horizontal: 60),
    );
  }

  Widget _buildVerticalTimeline() {
    // Dikey tasarımındaki AKM-Ulus-Sıhhiye-Kızılay hattı
    return Container(); // İçerisi CustomPaint veya Column ile doldurulabilir
  }

  Widget _buildTimeCard(String s1, String t1, String s2, String t2) {
     return Container(); // Tasarımdaki saatli kutucuk
  }
}
