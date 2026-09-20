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
  final ScrollController _scrollController = ScrollController();
  late DateTime _baseDate;
  late DateTime _today;

  static const double _itemWidth = 68;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _baseDate = _today.subtract(const Duration(days: 60));

    final initialDate = ref.read(homeSelectedDateProvider);
    final initialIndex = initialDate.difference(_baseDate).inDays;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToIndex(initialIndex, animated: false);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToIndex(int index, {bool animated = true}) {
    if (!_scrollController.hasClients) return;

    final targetOffset = index * _itemWidth;
    final clampedOffset = targetOffset.clamp(
      _scrollController.position.minScrollExtent,
      _scrollController.position.maxScrollExtent,
    );

    if (animated) {
      _scrollController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scrollController.jumpTo(clampedOffset);
    }
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final selectedDate = ref.watch(homeSelectedDateProvider);

    ref.listen(homeSelectedDateProvider, (prev, next) {
      if (prev == next) return;
      final nextIndex = next.difference(_baseDate).inDays;
      _scrollToIndex(nextIndex);
    });

    final isTodayVisible = selectedDate.difference(_today).inDays.abs() <= 2;
    final formattedDate = DateFormat.MMMMd(l10n.localeName)
        .format(selectedDate);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final containerWidth = constraints.maxWidth;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 4),
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
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              size: 14,
                            ),
                            label: Text(
                              l10n.backToToday,
                              style: textTheme.labelMedium,
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: 121,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: (containerWidth / 2) - (_itemWidth / 2),
                    ),
                    itemBuilder: (context, index) {
                      final date = _baseDate.add(Duration(days: index));
                      final isSelected = date == selectedDate;
                      final isToday = date == _today;

                      return Container(
                        width: _itemWidth,
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () {
                            ref
                                .read(homeSelectedDateProvider.notifier)
                                .updateDate(date);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.15),
                              border: isToday && !isSelected
                                  ? Border.all(
                                      color: colorScheme.primary.withValues(
                                        alpha: 0.5,
                                      ),
                                      width: 1.5,
                                    )
                                  : Border.all(
                                      color: Colors.transparent,
                                      width: 1.5,
                                    ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${date.day}',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
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
                                  style: textTheme.bodySmall?.copyWith(
                                    fontSize: 10,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurface.withValues(
                                            alpha: 0.6,
                                          ),
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
          },
        ),
      ),
    );
  }
}
