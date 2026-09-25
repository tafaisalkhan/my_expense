import 'package:myexpence/core/database/app_database.dart';
import 'package:myexpence/features/categories/domain/models/category.dart';
import 'package:myexpence/features/categories/domain/repositories/category_repository.dart';

class SqliteCategoryRepository implements ICategoryRepository {
  final AppDatabase appDatabase;

  SqliteCategoryRepository(this.appDatabase);

  @override
  Future<List<Category>> getCategories({bool activeOnly = true}) async {
    final db = await appDatabase.database;
    final catMaps = await db.query(
      'categories',
      where: activeOnly ? 'isActive = 1' : null,
      orderBy: 'sortOrder ASC',
    );

    final List<Category> categories = [];
    for (final map in catMaps) {
      final catId = map['id'] as String;
      final subMaps = await db.query(
        'subcategories',
        where: activeOnly ? 'categoryId = ? AND isActive = 1' : 'categoryId = ?',
        whereArgs: [catId],
        orderBy: 'sortOrder ASC',
      );

      final subs = subMaps.map((s) => Subcategory.fromMap(s)).toList();
      categories.add(Category.fromMap(map, subcategories: subs));
    }
    return categories;
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    final db = await appDatabase.database;
    final maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;

    final subMaps = await db.query(
      'subcategories',
      where: 'categoryId = ? AND isActive = 1',
      whereArgs: [id],
      orderBy: 'sortOrder ASC',
    );
    final subs = subMaps.map((s) => Subcategory.fromMap(s)).toList();
    return Category.fromMap(maps.first, subcategories: subs);
  }

  @override
  Future<List<Subcategory>> getSubcategories(String categoryId, {bool activeOnly = true}) async {
    final db = await appDatabase.database;
    final subMaps = await db.query(
      'subcategories',
      where: activeOnly ? 'categoryId = ? AND isActive = 1' : 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'sortOrder ASC',
    );
    return subMaps.map((s) => Subcategory.fromMap(s)).toList();
  }

  @override
  Future<void> addCategory(Category category) async {
    final db = await appDatabase.database;
    await db.insert('categories', category.toMap());
  }

  @override
  Future<void> addSubcategory(Subcategory subcategory) async {
    final db = await appDatabase.database;
    await db.insert('subcategories', subcategory.toMap());
  }
}
