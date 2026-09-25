import 'package:flutter_test/flutter_test.dart';
import 'package:myexpence/core/database/app_database.dart';
import 'package:myexpence/features/budgets/data/repositories/budget_repository_impl.dart';
import 'package:myexpence/features/budgets/domain/models/budget.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database testDb;
  late SqliteBudgetRepository repository;

  setUp(() async {
    testDb = await openDatabase(
      inMemoryDatabasePath,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE budgets (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            uuid TEXT UNIQUE NOT NULL,
            period TEXT NOT NULL,
            categoryId TEXT,
            personId TEXT,
            amount REAL NOT NULL,
            warningThreshold REAL NOT NULL DEFAULT 0.90,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL
          );
        ''');
      },
    );

    final mockAppDb = TestAppDatabase(testDb);
    repository = SqliteBudgetRepository(mockAppDb);
  });

  tearDown(() async {
    await testDb.close();
  });

  test('Set and retrieve monthly and category budgets', () async {
    const uuidGen = Uuid();
    final nowStr = DateTime.now().toIso8601String();

    final totalBudget = Budget(
      uuid: uuidGen.v4(),
      period: '2026-09',
      amount: 200000.0,
      createdAt: nowStr,
      updatedAt: nowStr,
    );

    final catBudget = Budget(
      uuid: uuidGen.v4(),
      period: '2026-09',
      categoryId: 'cat_groceries',
      amount: 40000.0,
      createdAt: nowStr,
      updatedAt: nowStr,
    );

    await repository.setBudget(totalBudget);
    await repository.setBudget(catBudget);

    final periodBudgets = await repository.getBudgetsForPeriod('2026-09');
    expect(periodBudgets.length, equals(2));

    final retrievedTotal = await repository.getBudgetForCategory('2026-09', null);
    expect(retrievedTotal?.amount, equals(200000.0));

    final retrievedCat = await repository.getBudgetForCategory('2026-09', 'cat_groceries');
    expect(retrievedCat?.amount, equals(40000.0));
  });

  test('Updating an existing budget upserts correctly without duplicate entries', () async {
    const uuidGen = Uuid();
    final nowStr = DateTime.now().toIso8601String();

    final initial = Budget(
      uuid: uuidGen.v4(),
      period: '2026-09',
      categoryId: 'cat_car',
      amount: 15000.0,
      createdAt: nowStr,
      updatedAt: nowStr,
    );

    await repository.setBudget(initial);

    final updated = initial.copyWith(amount: 25000.0);
    await repository.setBudget(updated);

    final periodBudgets = await repository.getBudgetsForPeriod('2026-09');
    expect(periodBudgets.length, equals(1));

    final result = await repository.getBudgetForCategory('2026-09', 'cat_car');
    expect(result?.amount, equals(25000.0));
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
