import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myexpence/core/providers/core_providers.dart';
import 'package:myexpence/features/budgets/domain/models/budget.dart';

final currentPeriodProvider = StateProvider<String>((ref) {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}';
});

final periodBudgetsProvider = FutureProvider<List<Budget>>((ref) async {
  final period = ref.watch(currentPeriodProvider);
  final repo = ref.watch(budgetRepositoryProvider);
  return await repo.getBudgetsForPeriod(period);
});

class BudgetNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  BudgetNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> setBudget(Budget budget) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(budgetRepositoryProvider);
      await repo.setBudget(budget);
      ref.invalidate(periodBudgetsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteBudget(String uuid) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(budgetRepositoryProvider);
      await repo.deleteBudget(uuid);
      ref.invalidate(periodBudgetsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final budgetNotifierProvider = StateNotifierProvider<BudgetNotifier, AsyncValue<void>>((ref) {
  return BudgetNotifier(ref);
});
