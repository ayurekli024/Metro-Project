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
      backgroundColor: const Color(0xFFC0C0C0),
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
            _buildHeader("Batıkent - Kızılay Hattı", "Kızılay Yönü"),
            const SizedBox(height: 20),
            _buildVagonVisual(engine.selectedVagon, isHorizontal: false),
            const SizedBox(height: 30),
            _buildTimeCard(
                engine.currentStation?.name ?? "Mevcut", 
                "Başladı", 
                engine.nextStation?.name ?? "Sıradaki", 
                "Varış"),
            const Spacer(),
            if (engine.isApproaching)
              ApproachingStationWidget(
                stationName: engine.nextStation?.name ?? "İstasyon",
                isApproaching: true,
              ),
            const SizedBox(height: 20),
            Text(
              engine.isMoving ? "Tren Hareket Halinde" : "Tren Durdu / Bekliyor",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, NavigationEngine engine) {
    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: 20,
            child: _buildHeader("Ankara Metrosu", "Kızılay - Batıkent"),
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
            color: isSelected ? Colors.red.withValues(alpha: 0.2) : Colors.white,
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
