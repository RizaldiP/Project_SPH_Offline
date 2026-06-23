import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._internal();

  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);
    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        company_name TEXT,
        address TEXT,
        phone TEXT,
        email TEXT,
        website TEXT,
        logo_path TEXT,
        signature_path TEXT,
        stamp_path TEXT,
        npwp TEXT,
        default_ppn TEXT DEFAULT '11',
        sph_number_format TEXT DEFAULT 'SPH-YYYY-NNN',
        currency TEXT DEFAULT 'Rp'
      )
    ''');

    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        company_name TEXT,
        address TEXT,
        phone TEXT,
        email TEXT,
        pic TEXT,
        notes TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE materials (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT,
        unit TEXT,
        standard_price REAL DEFAULT 0,
        supplier TEXT,
        notes TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sph_templates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sph_template_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        template_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        label TEXT NOT NULL,
        parent_id INTEGER,
        sort_order INTEGER DEFAULT 0,
        default_unit TEXT,
        FOREIGN KEY (template_id) REFERENCES sph_templates(id) ON DELETE CASCADE,
        FOREIGN KEY (parent_id) REFERENCES sph_template_items(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE sph (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        number TEXT NOT NULL,
        title TEXT,
        date TEXT,
        customer_id INTEGER,
        customer_name TEXT,
        customer_company TEXT,
        customer_address TEXT,
        customer_pic TEXT,
        ship_name TEXT,
        validity_period TEXT,
        notes TEXT,
        discount REAL DEFAULT 0,
        ppn REAL DEFAULT 11,
        status TEXT DEFAULT 'draft',
        total_material REAL DEFAULT 0,
        total_jasa REAL DEFAULT 0,
        subtotal REAL DEFAULT 0,
        grand_total REAL DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (customer_id) REFERENCES customers(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE sph_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sph_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        label TEXT NOT NULL,
        parent_id INTEGER,
        sort_order INTEGER DEFAULT 0,
        qty REAL DEFAULT 0,
        unit TEXT,
        material_price REAL DEFAULT 0,
        jasa_price REAL DEFAULT 0,
        unit_price REAL DEFAULT 0,
        total_price REAL DEFAULT 0,
        FOREIGN KEY (sph_id) REFERENCES sph(id) ON DELETE CASCADE,
        FOREIGN KEY (parent_id) REFERENCES sph_items(id) ON DELETE CASCADE
      )
    ''');

    await db.insert('settings', {
      'company_name': 'Perusahaan Saya',
      'address': '',
      'phone': '',
      'email': '',
      'website': '',
      'default_ppn': '11',
    });
  }

  Future<int> getSphCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM sph');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
