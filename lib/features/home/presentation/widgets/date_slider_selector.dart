import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/home_selected_date_controller.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class DateSliderSelector extends ConsumerStatefulWidget {
  const DateSliderSelector({super.key});

  @override
  ConsumerState<DateSliderSelector> createState() => _DateSliderSelectorState();
}

class _DateSliderSelectorState extends ConsumerState<DateSliderSelector> {
  late PageController _pageController;
  late DateTime _baseDate;
  late DateTime _today;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _baseDate = _today.subtract(const Duration(days: 60));

    final initialDate = ref.read(homeSelectedDateProvider);
    final initialIndex = initialDate.difference(_baseDate).inDays;

    _pageController = PageController(
      initialPage: initialIndex,
      viewportFraction: 0.2,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getShortDayName(DateTime date, AppLocalizations l10n) {
    switch (date.weekday) {
      case 1:
        return l10n.shortMon;
      case 2:
        return l10n.shortTue;
      case 3:
        return l10n.shortWed;
      case 4:
        return l10n.shortThu;
      case 5:
        return l10n.shortFri;
      case 6:
        return l10n.shortSat;
      case 7:
        return l10n.shortSun;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final selectedDate = ref.watch(homeSelectedDateProvider);

    ref.listen(homeSelectedDateProvider, (prev, next) {
      if (prev == next) return;
      final nextIndex = next.difference(_baseDate).inDays;
      if (_pageController.hasClients &&
          _pageController.page?.round() != nextIndex) {
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });

    final isTodayVisible = selectedDate.difference(_today).inDays.abs() <= 2;
    final formattedDate = DateFormat.MMMMd(l10n.localeName)
        .format(selectedDate);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: SizedBox(
            height: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: isTodayVisible ? 0.0 : 1.0,
                  child: TextButton.icon(
                    onPressed: isTodayVisible
                        ? null
                        : () => ref
                              .read(homeSelectedDateProvider.notifier)
                              .updateDate(_today),
                    icon: const Icon(Icons.arrow_back_rounded, size: 14),
                    label: Text(
                      l10n.backToToday,
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                    ),
                  ),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 70,
          child: PageView.builder(
            controller: _pageController,
            itemCount: 121,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              final newDate = _baseDate.add(Duration(days: index));
              if (ref.read(homeSelectedDateProvider) != newDate) {
                ref.read(homeSelectedDateProvider.notifier).updateDate(newDate);
              }
            },
            itemBuilder: (context, index) {
              final date = _baseDate.add(Duration(days: index));
              final isSelected = date == selectedDate;
              final isToday = date == _today;

              return GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                  );
                },
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? colorScheme.primary
                          : Colors.transparent,
                      border: isToday && !isSelected
                          ? Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.5),
                              width: 1.5,
                            )
                          : Border.all(color: Colors.transparent, width: 1.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 18,
                            fontFeatures: const [FontFeature.tabularFigures()],
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getShortDayName(date, l10n),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? colorScheme.onPrimary.withValues(alpha: 0.8)
                                : colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
