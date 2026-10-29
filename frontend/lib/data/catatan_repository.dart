import 'package:sqflite/sqflite.dart';

import '../models/catatan.dart';
import 'database_helper.dart';

class CatatanRepository {
  final DatabaseHelper _helper;

  CatatanRepository({
    DatabaseHelper? helper,
  }) : _helper = helper ?? DatabaseHelper.instance;

  Future<List<Catatan>> semua() async {
    final db = await _helper.database;

    final hasil = await db.query(
      'catatan',
      orderBy: 'tanggal DESC, id DESC',
    );

    return hasil.map(Catatan.fromMap).toList();
  }

  Future<Catatan?> berdasarkanId(int id) async {
    final db = await _helper.database;

    final hasil = await db.query(
      'catatan',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (hasil.isEmpty) {
      return null;
    }

    return Catatan.fromMap(hasil.first);
  }

  Future<int> tambah(Catatan catatan) async {
    final db = await _helper.database;

    return db.insert(
      'catatan',
      catatan.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<int> ubah(Catatan catatan) async {
    if (catatan.id == null) {
      throw ArgumentError(
        'ID catatan wajib ada ketika mengubah data.',
      );
    }

    final db = await _helper.database;

    return db.update(
      'catatan',
      catatan.toMap(),
      where: 'id = ?',
      whereArgs: [catatan.id],
    );
  }

  Future<int> hapus(int id) async {
    final db = await _helper.database;

    return db.delete(
      'catatan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}