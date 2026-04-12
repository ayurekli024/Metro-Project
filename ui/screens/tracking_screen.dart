import 'package:flutter/material.dart';

class TrackingScreen extends StatelessWidget {
  final int userVagon; // Kullanıcının bindiği vagon (Örn: 5)

  TrackingScreen({required this.userVagon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFC0C0C0), // Tasarımdaki gri tonu
      body: SafeArea(
        child: Column(
          children: [
            // Üst Kısım: Saat, Tarih ve Başlık (M Ankara Metrosu)
            _buildTopBar(),
            
            // Orta Kısım: Hız Göstergesi ve Hat Bilgisi (M1 Kızılay-Batıkent)
            _buildInfoSection(),

            // Vagon Kısmı: İşte o paylaştığım kod buraya gelecek!
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: _buildVagonRow(userVagon), 
            ),

            // Alt Kısım: İstasyon Çizgisi ve Butonlar
            _buildStationTimeline(),
          ],
        ),
      ),
    );
  }

  // Paylaştığım vagon kodunu buraya metod olarak ekliyoruz
  Widget _buildVagonRow(int selectedVagon) {
    return Row(
      children: List.generate(6, (index) {
        int vagonNo = 6 - index; // Senin tasarımındaki gibi 6'dan 1'e ters sıralama
        bool isSelected = selectedVagon == vagonNo;

        return Expanded(
          child: Container(
            height: 50,
            margin: EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(index == 0 ? 15 : 5), // İlk vagonun burnu kavisli
                topRight: Radius.circular(index == 5 ? 5 : 5),
              ),
            ),
            child: Center(
              child: isSelected 
                ? Icon(Icons.location_on, color: Colors.red, size: 30) // Tasarımdaki pin
                : Text("$vagonNo", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        );
      }),
    );
  }
  Widget _buildSpeedometer(SensorManager sensorManager) {
    return StreamBuilder<double>(
        stream: sensorManager.speedStream,
        builder: (context, snapshot) {
        // Veri gelene kadar 0 göster
        double speed = snapshot.data ?? 0.0;

        return Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 2),
            ),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                Text(
                "${speed.toStringAsFixed(0)}", // 26
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                Text("km/h", style: TextStyle(fontSize: 12)),
            ],
            ),
        );
        },
    );
    }
    Widget _buildLineIcon(String label, Color color) {
    return Column(
        children: [
        Transform.rotate(
            angle: 0.785, // 45 derece (elmas görünümü için)
            child: Container(
            width: 30,
            height: 30,
            color: color,
            child: Center(
                child: Transform.rotate(
                angle: -0.785, // Yazıyı düzeltmek için ters döndür
                child: Text(
                    label,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                ),
            ),
            ),
        ),
        ],
    );
    }

}
