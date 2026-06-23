import '../core/database/database_helper.dart';
import '../models/material.dart';

class MaterialRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<MaterialModel>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('materials', orderBy: 'name ASC');
    return maps.map((m) => MaterialModel.fromMap(m)).toList();
  }

  Future<MaterialModel?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('materials', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return MaterialModel.fromMap(maps.first);
  }

  Future<int> insert(MaterialModel material) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    return await db.insert('materials', {
      ...material.toMap(),
      'id': null,
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<int> update(MaterialModel material) async {
    final db = await _dbHelper.database;
    return await db.update(
      'materials',
      {...material.toMap(), 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [material.id],
    );
  }

  Future<MaterialModel?> getByName(String name) async {
    final db = await _dbHelper.database;
    final maps = await db.query('materials', where: 'name = ?', whereArgs: [name], limit: 1);
    if (maps.isEmpty) return null;
    return MaterialModel.fromMap(maps.first);
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('materials', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<MaterialModel>> search(String query) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'materials',
      where: 'name LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return maps.map((m) => MaterialModel.fromMap(m)).toList();
  }
}
