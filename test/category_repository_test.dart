import 'package:flutter_test/flutter_test.dart';
import 'package:myexpence/core/database/app_database.dart';
import 'package:myexpence/features/categories/data/repositories/category_repository_impl.dart';
import 'package:myexpence/features/categories/domain/models/category.dart';
import 'package:myexpence/features/expenses/domain/models/expense_classification.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database testDb;
  late SqliteCategoryRepository repository;

  setUp(() async {
    testDb = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE categories (
            id TEXT PRIMARY KEY,
            uuid TEXT NOT NULL,
            name TEXT NOT NULL,
            icon TEXT NOT NULL,
            defaultClassification TEXT NOT NULL,
            isSystem INTEGER NOT NULL DEFAULT 1,
            isActive INTEGER NOT NULL DEFAULT 1,
            sortOrder INTEGER NOT NULL
          );
        ''');
        await db.execute('''
          CREATE TABLE subcategories (
            id TEXT PRIMARY KEY,
            uuid TEXT NOT NULL,
            categoryId TEXT NOT NULL,
            name TEXT NOT NULL,
            defaultClassification TEXT NOT NULL,
            isActive INTEGER NOT NULL DEFAULT 1,
            sortOrder INTEGER NOT NULL
          );
        ''');
      },
    );

    final mockAppDb = TestAppDatabase(testDb);
    repository = SqliteCategoryRepository(mockAppDb);
  });

  tearDown(() async {
    await testDb.close();
  });

  test('Add custom category and custom subcategory', () async {
    const uuidGen = Uuid();
    final customCat = Category(
      id: 'cat_investments',
      uuid: uuidGen.v4(),
      name: 'Investments',
      icon: 'category',
      defaultClassification: ExpenseClassification.optional,
      isSystem: false,
      sortOrder: 99,
    );

    await repository.addCategory(customCat);

    final customSub = Subcategory(
      id: 'sub_investments_stocks',
      uuid: uuidGen.v4(),
      categoryId: 'cat_investments',
      name: 'Stocks',
      defaultClassification: ExpenseClassification.optional,
      sortOrder: 1,
    );

    await repository.addSubcategory(customSub);

    final cat = await repository.getCategoryById('cat_investments');
    expect(cat, isNotNull);
    expect(cat?.name, equals('Investments'));
    expect(cat?.subcategories.length, equals(1));
    expect(cat?.subcategories.first.name, equals('Stocks'));
  });
}

class TestAppDatabase implements AppDatabase {
  final Database db;
  TestAppDatabase(this.db);

  @override
  Future<Database> get database async => db;

  @override
  Future<void> clearAllData() async {}

  @override
  Future<void> close() async {}
}
