import 'package:myexpence/features/budgets/domain/models/budget.dart';

abstract class IBudgetRepository {
  Future<List<Budget>> getBudgetsForPeriod(String period);
  Future<Budget?> getBudgetForCategory(String period, String? categoryId);
  Future<Budget> setBudget(Budget budget);
  Future<void> deleteBudget(String uuid);
}
