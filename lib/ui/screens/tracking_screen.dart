import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/navigation_engine.dart';
import '../widgets/approaching_station.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navEngine = Provider.of<NavigationEngine>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5), // Arka planı hafif açtım ki okunabilirlik artsın
      body: OrientationBuilder(
        builder: (context, orientation) {
          return orientation == Orientation.portrait
              ? _buildPortraitLayout(context, navEngine)
              : _buildLandscapeLayout(context, navEngine);
        },
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context, NavigationEngine engine) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHeader("${engine.currentStation?['line_name'] ?? 'Metro'} Hattı", "Yolculuk Devam Ediyor"),
            const SizedBox(height: 20),
            _buildVagonVisual(engine.selectedVagon, isHorizontal: false),
            const SizedBox(height: 30),
            _buildTimeCard(
                engine.currentStation?['station_name'] ?? "Mevcut",
                "Başladı",
                engine.nextStation?['station_name'] ?? "Sıradaki",
                "Varış"),
            const Spacer(),
            if (engine.isApproaching)
              ApproachingStationWidget(
                stationName: engine.nextStation?['station_name'] ?? "İstasyon",
                isApproaching: true,
              ),
            const SizedBox(height: 10),
            Text(
              engine.isMoving ? "Tren Hareket Halinde" : "Tren Durdu / Bekliyor",
              style: TextStyle(fontWeight: FontWeight.bold, color: engine.isMoving ? Colors.green : Colors.red),
            ),
            const SizedBox(height: 20),

            // GELİŞTİRİCİ PANeli BURAYA EKLENDİ
            _buildDebugCard(engine),

            const SizedBox(height: 20),
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  // Özel Geliştirici Kutusu
  // Özel Geliştirici Kutusu
  Widget _buildDebugCard(NavigationEngine engine) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.yellow, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("🛠 GELİŞTİRİCİ VERİLERİ (RAW)", style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 12)),
              // SIFIRLA BUTONU BURADA
              InkWell(
                onTap: () => engine.resetCalibration(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text("KALİBRE ET", style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("X: ${engine.rawX.toStringAsFixed(3)}", style: const TextStyle(color: Colors.white, fontFamily: 'monospace')),
              Text("Y: ${engine.rawY.toStringAsFixed(3)}", style: const TextStyle(color: Colors.cyanAccent, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
              Text("Z: ${engine.rawZ.toStringAsFixed(3)}", style: const TextStyle(color: Colors.white, fontFamily: 'monospace')),
            ],
          ),
          const SizedBox(height: 5),
          Text("Hesaplanan Hız: ${engine.currentSpeed.toStringAsFixed(2)} km/h", style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace')),
          Text("Geçen Süre: ${engine.secondsElapsed} sn (Hedef: ${engine.currentStation?['time_to_next_sec'] ?? 0} sn)", style: const TextStyle(color: Colors.orangeAccent, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  // Landscape, Header ve diğer _build fonksiyonların aynı kalacak...
  Widget _buildLandscapeLayout(BuildContext context, NavigationEngine engine) {
    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: 20,
            child: _buildHeader("${engine.currentStation?['line_name'] ?? 'Metro'} Hattı", "Ankara"),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text("Canlı Takip", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildSpeedometer(engine.currentSpeed),
              ],
            ),
          ),
          Center(child: _buildHorizontalMainLine()),
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

  Widget _buildHeader(String title, String subTitle) {
    return Row(
      children: [
        const Icon(Icons.train, size: 40, color: Colors.red),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(subTitle, style: const TextStyle(fontSize: 14)),
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
            color: isSelected ? Colors.red.withOpacity(0.2) : Colors.white,
            border: Border.all(color: isSelected ? Colors.red : Colors.black, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: isSelected
                ? const Icon(Icons.person, color: Colors.red, size: 20)
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
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Center(
        child: Text("${speed.toStringAsFixed(1)}\nkm/h", textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            onPressed: () => Navigator.pop(context),
            child: const Text("Yolculuğu Bitir", style: TextStyle(color: Colors.black))
        ),
        ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {},
            child: const Text("Çıkış Bilgisi", style: TextStyle(color: Colors.white))
        ),
      ],
    );
  }

  Widget _buildLandscapeVagonSystem(NavigationEngine engine) {
    return Column(
      children: [
        _buildVagonVisual(engine.selectedVagon, isHorizontal: true),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                engine.getVagonGuidance(),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildHorizontalMainLine() {
    return Container(
      height: 6,
      width: double.infinity,
      color: Colors.black87,
      margin: const EdgeInsets.symmetric(horizontal: 60),
    );
  }

  Widget _buildTimeCard(String s1, String t1, String s2, String t2) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(children: [Text(s1, style: const TextStyle(fontSize: 16)), Text(t1, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))]),
            const Icon(Icons.fast_forward, color: Colors.grey),
            Column(children: [Text(s2, style: const TextStyle(fontSize: 16)), Text(t2, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))]),
          ],
        ),
      ),
    );
  }
}