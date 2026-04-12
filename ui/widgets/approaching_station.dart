import 'package:flutter/material.dart';

class ApproachingStationWidget extends StatefulWidget {
  final String stationName;
  final bool isApproaching; // Süre %90'a ulaştığında true olacak

  ApproachingStationWidget({required this.stationName, required this.isApproaching});

  @override
  _ApproachingStationWidgetState createState() => _ApproachingStationWidgetState();
}

class _ApproachingStationWidgetState extends State<ApproachingStationWidget> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    )..repeat(reverse: true); // Sürekli gidip gelen opaklık
    _opacity = Tween<double>(begin: 1.0, end: 0.2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isApproaching) return SizedBox.shrink();

    return FadeTransition(
      opacity: _opacity,
      child: Text(
        "Yaklaşılan İstasyon: ${widget.stationName}",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.red,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
