import '../models/station.model.dart';

final akmStation = MetroStation(
  id: 10,
  name: "Atatürk Kültür Merkezi",
  nextStationDurations: {"Akköprü": 130}, 
  exits: ["Emniyet Sarayı", "Ankamall"],
  vagonAdvantage: {5: "İndiğinizde sağınızdaki yürüyen merdiven Ankamall çıkışına gider."}
);

final akkopruStation = MetroStation(
  id: 11,
  name: "Akköprü",
  nextStationDurations: {"İvedik": 150},
  exits: ["Ankamall", "Emniyet"],
  vagonAdvantage: {2: "Asansöre en yakın vagon."}
);

final List<MetroStation> ankaraMetro = [
  akmStation,
  akkopruStation,
];
