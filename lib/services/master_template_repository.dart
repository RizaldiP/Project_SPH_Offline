import '../core/database/database_helper.dart';
import '../models/template.dart';

class MasterTemplateRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<MasterTemplate?> getActive() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'master_template',
      where: 'is_active = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return MasterTemplate.fromMap(maps.first);
  }

  Future<int> insert(MasterTemplate template) async {
    final db = await _dbHelper.database;
    await db.update('master_template', {'is_active': 0});
    final now = DateTime.now().toIso8601String();
    return await db.insert('master_template', {
      ...template.toMap(),
      'id': null,
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('master_template', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<CellMapping>> getAllMappings() async {
    final db = await _dbHelper.database;
    final maps = await db.query('cell_mapping', orderBy: 'id ASC');
    return maps.map((m) => CellMapping.fromMap(m)).toList();
  }

  Future<List<CellMapping>> getHeaderMappings() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'cell_mapping',
      where: 'is_table_field = ?',
      whereArgs: [0],
      orderBy: 'id ASC',
    );
    return maps.map((m) => CellMapping.fromMap(m)).toList();
  }

  Future<List<CellMapping>> getTableMappings() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'cell_mapping',
      where: 'is_table_field = ?',
      whereArgs: [1],
      orderBy: 'id ASC',
    );
    return maps.map((m) => CellMapping.fromMap(m)).toList();
  }

  Future<int> updateMapping(CellMapping mapping) async {
    final db = await _dbHelper.database;
    return await db.update(
      'cell_mapping',
      mapping.toMap(),
      where: 'id = ?',
      whereArgs: [mapping.id],
    );
  }

  Future<void> updateMappings(List<CellMapping> mappings) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (final mapping in mappings) {
      batch.update(
        'cell_mapping',
        mapping.toMap(),
        where: 'id = ?',
        whereArgs: [mapping.id],
      );
    }
    await batch.commit(noResult: true);
  }

  Future<CellMapping?> getMappingByField(String fieldName) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'cell_mapping',
      where: 'field_name = ?',
      whereArgs: [fieldName],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return CellMapping.fromMap(maps.first);
  }

  Future<bool> isMappingComplete() async {
    final mappings = await getAllMappings();
    for (final m in mappings) {
      if (m.isTableField == 0 && (m.cellAddress == null || m.cellAddress!.isEmpty)) {
        return false;
      }
      if (m.isTableField == 1 && (m.tableStartRow == null || m.tableColumn == null || m.tableColumn!.isEmpty)) {
        return false;
      }
    }
    return mappings.isNotEmpty;
  }
}
