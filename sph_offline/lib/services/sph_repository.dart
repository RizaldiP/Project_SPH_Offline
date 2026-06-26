import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../models/sph.dart';
import '../models/sph_item.dart';

class SphRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Sph>> getAll({String? status, String? search}) async {
    final db = await _dbHelper.database;
    String? where;
    List<dynamic>? whereArgs;
    if (status != null && search != null && search.isNotEmpty) {
      where = 'status = ? AND (number LIKE ? OR customer_name LIKE ?)';
      whereArgs = [status, '%$search%', '%$search%'];
    } else if (status != null) {
      where = 'status = ?';
      whereArgs = [status];
    } else if (search != null && search.isNotEmpty) {
      where = 'number LIKE ? OR customer_name LIKE ?';
      whereArgs = ['%$search%', '%$search%'];
    }
    final maps = await db.query(
      'sph',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => Sph.fromMap(m)).toList();
  }

  Future<Sph?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('sph', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Sph.fromMap(maps.first);
  }

  Future<int> insert(Sph sph) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    return await db.insert('sph', {
      ...sph.toMap(),
      'id': null,
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<int> update(Sph sph) async {
    final db = await _dbHelper.database;
    return await db.update(
      'sph',
      {...sph.toMap(), 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [sph.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('sph', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as c FROM sph');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<SphItem>> getItems(int sphId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'sph_items',
      where: 'sph_id = ?',
      whereArgs: [sphId],
      orderBy: 'sort_order ASC',
    );
    return maps.map((m) => SphItem.fromMap(m)).toList();
  }

  Future<int> insertItem(SphItem item) async {
    final db = await _dbHelper.database;
    return await db.insert('sph_items', {
      ...item.toMap(),
      'id': null,
    });
  }

  Future<void> insertItems(List<SphItem> items) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (final item in items) {
      batch.insert('sph_items', {...item.toMap(), 'id': null});
    }
    await batch.commit(noResult: true);
  }

  Future<int> updateItem(SphItem item) async {
    final db = await _dbHelper.database;
    return await db.update(
      'sph_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('sph_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteItemsBySphId(int sphId) async {
    final db = await _dbHelper.database;
    await db.delete('sph_items', where: 'sph_id = ?', whereArgs: [sphId]);
  }

  Future<Sph> duplicate(int sphId) async {
    final original = await getById(sphId);
    if (original == null) throw Exception('SPH not found');
    final count = await getCount();
    final newNumber = 'SPH-${DateTime.now().year}-${(count + 1).toString().padLeft(3, '0')}';
    final now = DateTime.now().toIso8601String();
    final newId = await insert(original.copyWith(
      id: null,
      number: newNumber,
      date: DateTime.now().toIso8601String().substring(0, 10),
      status: 'draft',
      createdAt: now,
      updatedAt: now,
    ));
    final items = await getItems(sphId);
    for (final item in items) {
      await insertItem(item.copyWith(
        id: null,
        sphId: newId,
      ));
    }
    final sph = await getById(newId);
    return sph!;
  }
}
