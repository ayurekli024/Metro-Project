import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MetroDatabase {
  static final MetroDatabase instance = MetroDatabase._init();
  static Database? _database;

  MetroDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('metro_project.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    try {
      final sqlScript = await rootBundle.loadString('assets/ankararailwaysystem.sql');

      // SQL komutlarını noktalı virgüle göre ayırıyoruz
      final statements = sqlScript.split(';');
      final batch = db.batch();

      for (var statement in statements) {
        final trimmedStatement = statement.trim();
        // Sadece çalıştırılabilir komutları batch içine alıyoruz
        if (trimmedStatement.isNotEmpty) {
          batch.execute(trimmedStatement);
        }
      }

      await batch.commit(noResult: true);

      // SQL dosyasından sonra istasyon içi aramaları hızlandırmak için indeksleri ekliyoruz
      await db.execute('CREATE INDEX IF NOT EXISTS idx_line_order ON stations (line_code, station_order)');

      print("Veritabanı başarıyla orijinal verilere uygun dolduruldu!");
    } catch (e) {
      print("SQL dosyası yüklenirken hata oluştu: $e");
    }
  }

  // Tünel içi takip sisteminde (Dead Reckoning) istasyon listesini
  // sırayla çekmek için kullanacağın yardımcı fonksiyon
  Future<List<Map<String, dynamic>>> getStationsByLine(String lineCode) async {
    final db = await instance.database;
    return await db.query(
      'stations',
      where: 'line_code = ?',
      whereArgs: [lineCode],
      orderBy: 'station_order ASC',
    );
  }

  Future close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}