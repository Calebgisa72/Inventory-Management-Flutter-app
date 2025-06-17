import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/review.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('inventory.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Increment version to trigger upgrade
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        usageCount INTEGER NOT NULL,
        lastUsed TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        comment TEXT NOT NULL,
        dateAdded TEXT NOT NULL
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Create reviews table if upgrading from version 1
      await db.execute('''
        CREATE TABLE IF NOT EXISTS reviews (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          comment TEXT NOT NULL,
          dateAdded TEXT NOT NULL
        )
      ''');
    }
  }

  Future<Product> createProduct(Product product) async {
    final db = await instance.database;
    final id = await db.insert('products', product.toMap());
    return product;
  }

  Future<List<Product>> getAllProducts() async {
    final db = await instance.database;
    final result = await db.query('products', orderBy: 'usageCount DESC');
    return result.map((json) => Product.fromMap(json)).toList();
  }

  Future<Review> createReview(Review review) async {
    final db = await instance.database;
    final id = await db.insert('reviews', review.toMap());
    return review;
  }

  Future<List<Review>> getAllReviews() async {
    final db = await instance.database;
    final result = await db.query('reviews', orderBy: 'dateAdded DESC');
    return result.map((json) => Review.fromMap(json)).toList();
  }

  // Get a single review by ID
  Future<Review?> getReview(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'reviews',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Review.fromMap(maps.first);
    }
    return null;
  }

  // Update an existing review
  Future<int> updateReview(Review review) async {
    final db = await instance.database;
    if (review.id == null) {
      throw Exception('Cannot update review without id');
    }
    return await db.update(
      'reviews',
      review.toMap(),
      where: 'id = ?',
      whereArgs: [review.id],
    );
  }

  // Delete a review
  Future<int> deleteReview(int id) async {
    final db = await instance.database;
    return await db.delete(
      'reviews',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all reviews
  Future<int> deleteAllReviews() async {
    final db = await instance.database;
    return await db.delete('reviews');
  }
}
