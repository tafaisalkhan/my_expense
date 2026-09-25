import 'package:sqflite/sqflite.dart';
import 'package:myexpence/core/database/app_database.dart';
import 'package:myexpence/features/budgets/domain/models/budget.dart';
import 'package:myexpence/features/budgets/domain/repositories/budget_repository.dart';
import 'package:uuid/uuid.dart';

class SqliteBudgetRepository implements IBudgetRepository {
  final AppDatabase appDatabase;
  final Uuid _uuidGen = const Uuid();

  SqliteBudgetRepository(this.appDatabase);

  @override
  Future<List<Budget>> getBudgetsForPeriod(String period) async {
    final db = await appDatabase.database;
    final maps = await db.query(
      'budgets',
      where: 'period = ?',
      whereArgs: [period],
    );
    return maps.map((map) => Budget.fromMap(map)).toList();
  }

  @override
  Future<Budget?> getBudgetForCategory(String period, String? categoryId) async {
    final db = await appDatabase.database;
    String where = 'period = ?';
    List<dynamic> args = [period];

    if (categoryId == null) {
      where += ' AND categoryId IS NULL';
    } else {
      where += ' AND categoryId = ?';
      args.add(categoryId);
    }

    final maps = await db.query(
      'budgets',
      where: where,
      whereArgs: args,
    );
    if (maps.isEmpty) return null;
    return Budget.fromMap(maps.first);
  }

  @override
  Future<Budget> setBudget(Budget budget) async {
    final db = await appDatabase.database;
    final now = DateTime.now().toIso8601String();
    final newUuid = budget.uuid.isNotEmpty ? budget.uuid : _uuidGen.v4();

    final toInsert = budget.copyWith(
      uuid: newUuid,
      createdAt: now,
      updatedAt: now,
    );

    // Upsert budget for period and category combination
    String where = 'period = ?';
    List<dynamic> args = [budget.period];
    if (budget.categoryId == null) {
      where += ' AND categoryId IS NULL';
    } else {
      where += ' AND categoryId = ?';
      args.add(budget.categoryId);
    }

    final existing = await db.query('budgets', where: where, whereArgs: args);
    if (existing.isNotEmpty) {
      await db.update('budgets', toInsert.toMap(), where: where, whereArgs: args);
      return toInsert;
    } else {
      final id = await db.insert('budgets', toInsert.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      return toInsert.copyWith(id: id);
    }
  }

  @override
  Future<void> deleteBudget(String uuid) async {
    final db = await appDatabase.database;
    await db.delete(
      'budgets',
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
  }
}
