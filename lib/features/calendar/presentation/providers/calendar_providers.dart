import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myexpence/core/providers/core_providers.dart';
import 'package:myexpence/core/utils/date_formatters.dart';
import 'package:myexpence/features/expenses/presentation/providers/expense_providers.dart';

enum DayStatus {
  recorded,
  zeroSpend,
  missing,
  future,
}

class DayDetail {
  final DateTime? date;
  final String dateIso;
  final DayStatus status;
  final double totalAmount;
  final bool isPlaceholder;

  const DayDetail({
    this.date,
    required this.dateIso,
    required this.status,
    required this.totalAmount,
    this.isPlaceholder = false,
  });
}

final calendarMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

final calendarMonthDataProvider = FutureProvider<List<DayDetail>>((ref) async {
  // Watch expenseNotifierProvider so calendar automatically refreshes whenever any expense is added, edited, or deleted
  ref.watch(expenseNotifierProvider);
  final monthDate = ref.watch(calendarMonthProvider);
  final repo = ref.watch(expenseRepositoryProvider);

  final firstDay = DateTime(monthDate.year, monthDate.month, 1);
  final lastDay = DateTime(monthDate.year, monthDate.month + 1, 0);

  final todayIso = DateFormatters.todayIso();
  final List<DayDetail> dayDetails = [];

  // Add leading placeholder cells for weekday alignment (Monday = 1)
  final leadingPadding = firstDay.weekday - 1;
  for (int i = 0; i < leadingPadding; i++) {
    dayDetails.add(const DayDetail(
      dateIso: '',
      status: DayStatus.future,
      totalAmount: 0.0,
      isPlaceholder: true,
    ));
  }

  // Generate actual calendar days
  for (int day = 1; day <= lastDay.day; day++) {
    final curDate = DateTime(monthDate.year, monthDate.month, day);
    final curIso = DateFormatters.formatDateIso(curDate);

    final totalSpent = await repo.getTotalSpentForPeriod(startDate: curIso, endDate: curIso);
    final isZeroSpend = await repo.isZeroSpendDayConfirmed(curIso);

    DayStatus status;
    if (curIso.compareTo(todayIso) > 0) {
      status = DayStatus.future;
    } else if (totalSpent > 0) {
      status = DayStatus.recorded;
    } else if (isZeroSpend) {
      status = DayStatus.zeroSpend;
    } else {
      status = DayStatus.missing;
    }

    dayDetails.add(DayDetail(
      date: curDate,
      dateIso: curIso,
      status: status,
      totalAmount: totalSpent,
      isPlaceholder: false,
    ));
  }

  return dayDetails;
});
