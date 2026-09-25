import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myexpence/core/providers/core_providers.dart';
import 'package:myexpence/core/utils/currency_formatters.dart';
import 'package:myexpence/core/utils/date_formatters.dart';

enum ComparisonPeriod {
  todayVsYesterday,
  thisWeekVsLastWeek,
  thisMonthVsLastMonth,
}

class PeriodComparisonData {
  final double periodAAmount;
  final double periodBAmount;
  final String periodALabel;
  final String periodBLabel;

  const PeriodComparisonData({
    required this.periodAAmount,
    required this.periodBAmount,
    required this.periodALabel,
    required this.periodBLabel,
  });

  double get difference => periodAAmount - periodBAmount;
  double get percentageChange => periodBAmount > 0 ? ((periodAAmount - periodBAmount) / periodBAmount) * 100 : 0.0;
}

final selectedComparisonPeriodProvider = StateProvider<ComparisonPeriod>((ref) => ComparisonPeriod.thisMonthVsLastMonth);

final periodComparisonDataProvider = FutureProvider<PeriodComparisonData>((ref) async {
  final comparison = ref.watch(selectedComparisonPeriodProvider);
  final repo = ref.watch(expenseRepositoryProvider);
  final now = DateTime.now();

  switch (comparison) {
    case ComparisonPeriod.todayVsYesterday:
      final todayIso = DateFormatters.todayIso();
      final yesterdayIso = DateFormatters.yesterdayIso();
      final todayTotal = await repo.getTotalSpentForPeriod(startDate: todayIso, endDate: todayIso);
      final yesterdayTotal = await repo.getTotalSpentForPeriod(startDate: yesterdayIso, endDate: yesterdayIso);
      return PeriodComparisonData(
        periodAAmount: todayTotal,
        periodBAmount: yesterdayTotal,
        periodALabel: 'Today',
        periodBLabel: 'Yesterday',
      );

    case ComparisonPeriod.thisWeekVsLastWeek:
      final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
      final thisWeekEnd = thisWeekStart.add(const Duration(days: 6));
      final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
      final lastWeekEnd = lastWeekStart.add(const Duration(days: 6));

      final thisWeekTotal = await repo.getTotalSpentForPeriod(
        startDate: DateFormatters.formatDateIso(thisWeekStart),
        endDate: DateFormatters.formatDateIso(thisWeekEnd),
      );
      final lastWeekTotal = await repo.getTotalSpentForPeriod(
        startDate: DateFormatters.formatDateIso(lastWeekStart),
        endDate: DateFormatters.formatDateIso(lastWeekEnd),
      );
      return PeriodComparisonData(
        periodAAmount: thisWeekTotal,
        periodBAmount: lastWeekTotal,
        periodALabel: 'This Week',
        periodBLabel: 'Last Week',
      );

    case ComparisonPeriod.thisMonthVsLastMonth:
      final thisMonthStart = DateTime(now.year, now.month, 1);
      final thisMonthEnd = DateTime(now.year, now.month + 1, 0);
      final lastMonthStart = DateTime(now.year, now.month - 1, 1);
      final lastMonthEnd = DateTime(now.year, now.month, 0);

      final thisMonthTotal = await repo.getTotalSpentForPeriod(
        startDate: DateFormatters.formatDateIso(thisMonthStart),
        endDate: DateFormatters.formatDateIso(thisMonthEnd),
      );
      final lastMonthTotal = await repo.getTotalSpentForPeriod(
        startDate: DateFormatters.formatDateIso(lastMonthStart),
        endDate: DateFormatters.formatDateIso(lastMonthEnd),
      );
      return PeriodComparisonData(
        periodAAmount: thisMonthTotal,
        periodBAmount: lastMonthTotal,
        periodALabel: 'This Month',
        periodBLabel: 'Last Month',
      );
  }
});

class PeriodComparisonWidget extends ConsumerWidget {
  const PeriodComparisonWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPeriod = ref.watch(selectedComparisonPeriodProvider);
    final comparisonAsync = ref.watch(periodComparisonDataProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Period Comparison',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<ComparisonPeriod>(
                  value: selectedPeriod,
                  underline: const SizedBox.shrink(),
                  isDense: true,
                  items: const [
                    DropdownMenuItem(value: ComparisonPeriod.todayVsYesterday, child: Text('Today vs Yesterday', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: ComparisonPeriod.thisWeekVsLastWeek, child: Text('This Week vs Last Week', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: ComparisonPeriod.thisMonthVsLastMonth, child: Text('This Month vs Last Month', style: TextStyle(fontSize: 12))),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(selectedComparisonPeriodProvider.notifier).state = val;
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            comparisonAsync.when(
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(12.0), child: CircularProgressIndicator())),
              error: (err, _) => Text('Error loading comparison: $err'),
              data: (data) {
                final diff = data.difference;
                final isIncrease = diff > 0;
                final pctStr = '${data.percentageChange.abs().toStringAsFixed(1)}%';

                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data.periodALabel, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              CurrencyFormatters.format(data.periodAAmount),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data.periodBLabel, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              CurrencyFormatters.format(data.periodBAmount),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: (isIncrease ? Colors.red : Colors.green).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isIncrease ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 13,
                            color: isIncrease ? Colors.red : Colors.green,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            pctStr,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: isIncrease ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
