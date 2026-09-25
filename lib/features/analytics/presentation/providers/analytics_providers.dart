import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myexpence/core/providers/core_providers.dart';
import 'package:myexpence/core/utils/date_formatters.dart';
import 'package:myexpence/features/expenses/domain/models/expense.dart';
import 'package:myexpence/features/expenses/domain/models/expense_classification.dart';

enum ReportPeriod {
  today('Today'),
  yesterday('Yesterday'),
  thisWeek('This Week'),
  lastWeek('Last Week'),
  thisMonth('This Month'),
  lastMonth('Last Month'),
  last3Months('Last 3 Months'),
  last6Months('Last 6 Months'),
  thisYear('This Year'),
  lastYear('Last Year'),
  custom('Custom Range');

  final String label;
  const ReportPeriod(this.label);
}

class CustomDateRange {
  final DateTime startDate;
  final DateTime endDate;

  const CustomDateRange({required this.startDate, required this.endDate});
}

final selectedReportPeriodProvider = StateProvider<ReportPeriod>((ref) => ReportPeriod.thisMonth);
final customDateRangeProvider = StateProvider<CustomDateRange>((ref) {
  final now = DateTime.now();
  return CustomDateRange(
    startDate: DateTime(now.year, now.month, 1),
    endDate: DateTime(now.year, now.month + 1, 0),
  );
});

class AnalyticsReportData {
  final String startDateIso;
  final String endDateIso;
  final String periodLabel;
  final double totalSpent;
  final Map<ExpenseClassification, double> classificationBreakdown;
  final Map<String, double> categoryBreakdown;
  final Map<String, double> personBreakdown;
  final List<Expense> expenses;

  const AnalyticsReportData({
    required this.startDateIso,
    required this.endDateIso,
    required this.periodLabel,
    required this.totalSpent,
    required this.classificationBreakdown,
    required this.categoryBreakdown,
    required this.personBreakdown,
    required this.expenses,
  });
}

final analyticsReportDataProvider = FutureProvider<AnalyticsReportData>((ref) async {
  final period = ref.watch(selectedReportPeriodProvider);
  final customRange = ref.watch(customDateRangeProvider);
  final repo = ref.watch(expenseRepositoryProvider);

  final now = DateTime.now();
  DateTime startDate;
  DateTime endDate;
  String label = period.label;

  switch (period) {
    case ReportPeriod.today:
      startDate = now;
      endDate = now;
      break;
    case ReportPeriod.yesterday:
      startDate = now.subtract(const Duration(days: 1));
      endDate = startDate;
      break;
    case ReportPeriod.thisWeek:
      startDate = now.subtract(Duration(days: now.weekday - 1));
      endDate = startDate.add(const Duration(days: 6));
      break;
    case ReportPeriod.lastWeek:
      final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
      startDate = thisWeekStart.subtract(const Duration(days: 7));
      endDate = startDate.add(const Duration(days: 6));
      break;
    case ReportPeriod.thisMonth:
      startDate = DateTime(now.year, now.month, 1);
      endDate = DateTime(now.year, now.month + 1, 0);
      break;
    case ReportPeriod.lastMonth:
      startDate = DateTime(now.year, now.month - 1, 1);
      endDate = DateTime(now.year, now.month, 0);
      break;
    case ReportPeriod.last3Months:
      startDate = DateTime(now.year, now.month - 2, 1);
      endDate = DateTime(now.year, now.month + 1, 0);
      break;
    case ReportPeriod.last6Months:
      startDate = DateTime(now.year, now.month - 5, 1);
      endDate = DateTime(now.year, now.month + 1, 0);
      break;
    case ReportPeriod.thisYear:
      startDate = DateTime(now.year, 1, 1);
      endDate = DateTime(now.year, 12, 31);
      break;
    case ReportPeriod.lastYear:
      startDate = DateTime(now.year - 1, 1, 1);
      endDate = DateTime(now.year - 1, 12, 31);
      break;
    case ReportPeriod.custom:
      startDate = customRange.startDate;
      endDate = customRange.endDate;
      label = '${DateFormatters.formatDateShort(startDate)} - ${DateFormatters.formatDateShort(endDate)}';
      break;
  }

  final startIso = DateFormatters.formatDateIso(startDate);
  final endIso = DateFormatters.formatDateIso(endDate);

  final totalSpent = await repo.getTotalSpentForPeriod(startDate: startIso, endDate: endIso);
  final classificationBreakdown = await repo.getSpendingByClassification(startDate: startIso, endDate: endIso);
  final categoryBreakdown = await repo.getSpendingByCategory(startDate: startIso, endDate: endIso);
  final personBreakdown = await repo.getSpendingByPerson(startDate: startIso, endDate: endIso);
  final expenses = await repo.getExpensesForPeriod(startDate: startIso, endDate: endIso);

  return AnalyticsReportData(
    startDateIso: startIso,
    endDateIso: endIso,
    periodLabel: label,
    totalSpent: totalSpent,
    classificationBreakdown: classificationBreakdown,
    categoryBreakdown: categoryBreakdown,
    personBreakdown: personBreakdown,
    expenses: expenses,
  );
});
