import '../core/database/database_helper.dart';
import '../models/company_settings.dart';

class SettingsRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<CompanySettings> get() async {
    final db = await _dbHelper.database;
    final maps = await db.query('settings', limit: 1);
    if (maps.isEmpty) {
      return CompanySettings();
    }
    return CompanySettings.fromMap(maps.first);
  }

  Future<int> update(CompanySettings settings) async {
    final db = await _dbHelper.database;
    return await db.update(
      'settings',
      settings.toMap(),
      where: 'id = ?',
      whereArgs: [settings.id],
    );
  }
}
