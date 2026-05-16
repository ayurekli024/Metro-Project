class MetroStation {
  final int id;
  final String name;
  final Map<String, int> nextStationDurations; // "Ulus": 120 (saniye)
  final List<String> exits; // ["Milli Müdafaa", "Güvenpark"]
  final Map<int, String> vagonAdvantage; // {1: "Yürüyen merdivene en yakın"}

  MetroStation({
    required this.id, 
    required this.name, 
    required this.nextStationDurations,
    required this.exits,
    required this.vagonAdvantage,
  });
}
