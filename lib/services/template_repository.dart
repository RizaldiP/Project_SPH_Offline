import '../core/database/database_helper.dart';
import '../models/template.dart';

class TemplateRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<SphTemplate>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('sph_templates', orderBy: 'name ASC');
    return maps.map((m) => SphTemplate.fromMap(m)).toList();
  }

  Future<SphTemplate?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('sph_templates', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return SphTemplate.fromMap(maps.first);
  }

  Future<int> insert(SphTemplate template) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    return await db.insert('sph_templates', {
      ...template.toMap(),
      'id': null,
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<int> update(SphTemplate template) async {
    final db = await _dbHelper.database;
    return await db.update(
      'sph_templates',
      {...template.toMap(), 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [template.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('sph_templates', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TemplateItem>> getItems(int templateId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'sph_template_items',
      where: 'template_id = ?',
      whereArgs: [templateId],
      orderBy: 'sort_order ASC',
    );
    return maps.map((m) => TemplateItem.fromMap(m)).toList();
  }

  Future<int> insertItem(TemplateItem item) async {
    final db = await _dbHelper.database;
    return await db.insert('sph_template_items', {
      ...item.toMap(),
      'id': null,
    });
  }

  Future<void> insertItems(List<TemplateItem> items) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (final item in items) {
      batch.insert('sph_template_items', {...item.toMap(), 'id': null});
    }
    await batch.commit(noResult: true);
  }

  Future<int> updateItem(TemplateItem item) async {
    final db = await _dbHelper.database;
    return await db.update(
      'sph_template_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('sph_template_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteItemsByTemplateId(int templateId) async {
    final db = await _dbHelper.database;
    await db.delete('sph_template_items', where: 'template_id = ?', whereArgs: [templateId]);
  }
}
