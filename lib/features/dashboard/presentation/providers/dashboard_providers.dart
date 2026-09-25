import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myexpence/core/providers/core_providers.dart';
import 'package:myexpence/core/utils/date_formatters.dart';
import 'package:myexpence/features/expenses/domain/models/expense_classification.dart';

class DashboardData {
  final double todayTotal;
  final double yesterdayTotal;
  final double monthTotal;
  final Map<ExpenseClassification, double> classificationBreakdown;
  final Map<String, double> personBreakdown;
  final Map<String, double> categoryBreakdown;
  final bool isZeroSpendConfirmedToday;

  const DashboardData({
    required this.todayTotal,
    required this.yesterdayTotal,
    required this.monthTotal,
    required this.classificationBreakdown,
    required this.personBreakdown,
    required this.categoryBreakdown,
    required this.isZeroSpendConfirmedToday,
  });
}

final dashboardDataProvider = FutureProvider<DashboardData>((ref) async {
  final repo = ref.watch(expenseRepositoryProvider);

  final now = DateTime.now();
  final todayIso = DateFormatters.todayIso();
  final yesterdayIso = DateFormatters.yesterdayIso();

  final firstDayOfMonth = DateTime(now.year, now.month, 1);
  final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

  final startOfMonthIso = DateFormatters.formatDateIso(firstDayOfMonth);
  final endOfMonthIso = DateFormatters.formatDateIso(lastDayOfMonth);

  final todayTotal = await repo.getTotalSpentForPeriod(
    startDate: todayIso,
    endDate: todayIso,
  );

  final yesterdayTotal = await repo.getTotalSpentForPeriod(
    startDate: yesterdayIso,
    endDate: yesterdayIso,
  );

  final monthTotal = await repo.getTotalSpentForPeriod(
    startDate: startOfMonthIso,
    endDate: endOfMonthIso,
  );

  final classificationBreakdown = await repo.getSpendingByClassification(
    startDate: startOfMonthIso,
    endDate: endOfMonthIso,
  );

  final personBreakdown = await repo.getSpendingByPerson(
    startDate: startOfMonthIso,
    endDate: endOfMonthIso,
  );

  final categoryBreakdown = await repo.getSpendingByCategory(
    startDate: startOfMonthIso,
    endDate: endOfMonthIso,
  );

  final isZeroSpend = await repo.isZeroSpendDayConfirmed(todayIso);

  return DashboardData(
    todayTotal: todayTotal,
    yesterdayTotal: yesterdayTotal,
    monthTotal: monthTotal,
    classificationBreakdown: classificationBreakdown,
    personBreakdown: personBreakdown,
    categoryBreakdown: categoryBreakdown,
    isZeroSpendConfirmedToday: isZeroSpend,
  );
});
