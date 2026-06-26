import '../core/database/database_helper.dart';
import '../models/customer.dart';

class CustomerRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Customer>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('customers', orderBy: 'name ASC');
    return maps.map((m) => Customer.fromMap(m)).toList();
  }

  Future<Customer?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('customers', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Customer.fromMap(maps.first);
  }

  Future<int> insert(Customer customer) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    return await db.insert('customers', {
      ...customer.toMap(),
      'id': null,
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<int> update(Customer customer) async {
    final db = await _dbHelper.database;
    return await db.update(
      'customers',
      {...customer.toMap(), 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Customer>> search(String query) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'customers',
      where: 'name LIKE ? OR company_name LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return maps.map((m) => Customer.fromMap(m)).toList();
  }
}
