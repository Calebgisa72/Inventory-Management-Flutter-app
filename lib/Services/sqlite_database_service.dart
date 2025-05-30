import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseServiceSqlite {
  static Database? _database;
  static final DatabaseServiceSqlite instance = DatabaseServiceSqlite._constructor();

  DatabaseServiceSqlite._constructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initiateDatabase();
    return _database!;
  }

  Future<Database> initiateDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "recipe_db.db");
    final db = await openDatabase(
      databasePath,
      onCreate: (db, version) {
        db.execute('''
        CREATE TABLE products (
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          pid TEXT NOT NULL,
          distributor TEXT NOT NULL,
          category TEXT NOT NULL,
          expiredate TEXT NOT NULL,
          quantity INTEGER NOT NULL,
          price INTEGER NOT NULL,
        )
        ''');
      },
      version: 1,
    );
    return db;
  }

  Future<void> insertProduct(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('products', {
      ...data,
      'id': 1,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteProduct() async {
    final db = await database;
    await db.delete('products', where: 'id = ?', whereArgs: [1]);
  }

}

class RecipeProductProps {
  final int id, quantity,price;
  final String name, pid, distributor, category, expiredate;

  RecipeProductProps({
    required this.id,
    required this.pid,
    required this.distributor,
    required this.category,
    required this.expiredate,
    required this.name,
    required this.quantity,
    required this.price,
  });
}