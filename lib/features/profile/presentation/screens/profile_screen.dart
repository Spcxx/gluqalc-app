import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gluqalc_app/core/presentation/widgets/app_drawer.dart';
import 'package:gluqalc_app/features/auth/data/local/auth_local_storage.dart';
import 'package:gluqalc_app/features/auth/data/repositories/auth_repository.dart';
import 'package:gluqalc_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:gluqalc_app/features/auth/presentation/widgets/password_rules_widget.dart';
import 'package:gluqalc_app/features/profile/presentation/controllers/biometrics_history_controller.dart';
import 'package:gluqalc_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:gluqalc_app/features/profile/presentation/controllers/sessions_controller.dart';
import 'package:gluqalc_app/features/profile/presentation/widgets/update_weight_dialog.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

String _mapDioError(
  DioException e,
  AppLocalizations l10n, {
  bool isSecondStep = false,
}) {
  final data = e.response?.data;
  final statusCode = e.response?.statusCode;
  String? rawServerMessage;

  if (data is Map<String, dynamic>) {
    final message = data['message'] ?? data['error'];
    if (message is String) {
      rawServerMessage = message;
    } else if (message is Map) {
      rawServerMessage = message.values.join(' ');
    } else if (data.containsKey('errors')) {
      rawServerMessage = data['errors'].toString();
    }
  }

  if (rawServerMessage != null) {
    final msg = rawServerMessage.toLowerCase();
    if (msg.contains('invalid current password') ||
        msg.contains('invalid email or password')) {
      return l10n.errorInvalidPassword;
    }
    if (msg.contains('email is already taken')) {
      return l10n.errorEmailAlreadyTaken;
    }
    if (msg.contains('external providers')) {
      return l10n.errorExternalProvider;
    }
    if (msg.contains('invalid token') ||
        msg.contains('invalid code') ||
        msg.contains('does not match') ||
        msg.contains('mismatch')) {
      return l10n.errorInvalidVerificationCode;
    }
    if (msg.contains('too common')) return l10n.errorPasswordTooCommon;
    if (msg.contains('repeating characters')) {
      return l10n.errorPasswordRepeatingChars;
    }
    if (msg.contains('breach')) return l10n.errorPasswordPwned;
  }

  switch (statusCode) {
    case 400:
      return rawServerMessage != null && rawServerMessage.isNotEmpty
          ? '${l10n.errorValidationError}\n$rawServerMessage'
          : l10n.errorValidationError;
    case 401:
      return isSecondStep
          ? l10n.errorInvalidVerificationCode
          : l10n.errorInvalidPassword;
    case 404:
      return l10n.errorUserNotFound;
    case 409:
      return l10n.errorConflict;
    case 429:
      return l10n.errorTooManyRequests;
    case 500:
    case 502:
    case 503:
      return l10n.errorServerError;
    default:
      return l10n.errorUnknown(statusCode?.toString() ?? 'no connection');
  }
}

({IconData icon, String name}) _parseDeviceInfo(
  String deviceId,
  String userAgent,
  AppLocalizations l10n,
) {
  final ua = userAgent.toLowerCase();
  final devId = deviceId.toLowerCase();

  if (devId.startsWith('web') ||
      ua.contains('mozilla') ||
      ua.contains('chrome') ||
      ua.contains('safari')) {
    return (
      icon: Icons.language,
      name:
          '${l10n.deviceWeb} (${ua.contains("chrome") ? "Chrome" : "Browser"})',
    );
  } else if (devId.startsWith('android') || ua.contains('android')) {
    return (icon: Icons.phone_android, name: l10n.deviceAndroid);
  } else if (devId.startsWith('ios') ||
      ua.contains('iphone') ||
      ua.contains('ipad')) {
    return (icon: Icons.phone_iphone, name: l10n.deviceIos);
  } else if (devId.startsWith('windows') || ua.contains('windows')) {
    return (icon: Icons.laptop_windows, name: l10n.deviceWindows);
  } else if (devId.startsWith('linux') || ua.contains('linux')) {
    return (icon: Icons.computer, name: l10n.deviceLinux);
  } else if (devId.startsWith('macos') || ua.contains('mac')) {
    return (icon: Icons.laptop_mac, name: l10n.deviceMac);
  }
  return (icon: Icons.computer, name: l10n.deviceUnknown);
}

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _formatGender(String? g, AppLocalizations l10n) {
    if (g == 'FEMALE') return l10n.genderFemale;
    if (g == 'MALE') return l10n.genderMale;
    if (g == 'OTHER') return l10n.genderOther;
    return l10n.notSet;
  }

  String _formatBmr(String? m, AppLocalizations l10n) {
    if (m == 'HARRIS_BENEDICT') return l10n.bmrHarrisTitle;
    if (m == 'MIFFLIN_ST_JEOR') return l10n.bmrMifflinTitle;
    if (m == 'KATCH_MCARDLE') return l10n.bmrKatchTitle;
    if (m == 'OWEN') return l10n.bmrOwenTitle;
    return l10n.notSet;
  }

  String _formatGoal(int? diff, AppLocalizations l10n) {
    if (diff == null) return l10n.notSet;
    if (diff < 0) return l10n.summaryGoalLose(diff.abs());
    if (diff > 0) return l10n.summaryGoalGain(diff);
    return l10n.summaryGoalMaintain;
  }

  String _formatDeliveryMethod(String? method, AppLocalizations l10n) {
    if (method == 'PUMP') return l10n.insulinPump;
    if (method == 'PEN') return l10n.insulinPen;
    return l10n.notSet;
  }

  String _formatCombinedInsulin(String? method, AppLocalizations l10n) {
    if (method == 'PANKOWSKA') return l10n.pankowskaTitle;
    if (method == 'SIERADZKI') return l10n.sieradzkiTitle;
    return l10n.notSet;
  }

  String _formatMacros(Map<String, double>? macros, AppLocalizations l10n) {
    if (macros == null || macros.isEmpty) return l10n.notSet;
    final p = ((macros['PROTEIN'] ?? 0) * 100).toInt();
    final f = ((macros['FAT'] ?? 0) * 100).toInt();
    final c = ((macros['CARBOHYDRATE'] ?? 0) * 100).toInt();
    return 'P: $p%, F: $f%, C: $c%';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    final profileState = ref.watch(profileControllerProvider);
    final profile = profileState.value;
    final emailAsync = ref.watch(currentUserEmailProvider);
    final currentEmail = emailAsync.asData?.value ?? '';

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;

    ref.listen(profileControllerProvider, (prev, next) {
      if (next is AsyncData &&
          prev is AsyncData &&
          prev?.value?.weightInKg != next.value?.weightInKg) {
        ref.invalidate(biometricsHistoryControllerProvider);
      }
    });

    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final contentWidget = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.currentWeightLabel,
                                style: textTheme.labelLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '${profile.weightInKg ?? '-'}',
                                    style: textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'kg',
                                    style: textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: profile.weightInKg != null
                                ? () => showDialog<void>(
                                    context: context,
                                    builder: (ctx) => UpdateWeightDialog(
                                      currentWeight: profile.weightInKg!,
                                    ),
                                  )
                                : null,
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.edit, size: 18),
                            label: Text(l10n.updateButton),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 160,
                        child: ref
                            .watch(biometricsHistoryControllerProvider)
                            .when(
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (e, _) => Center(
                                child: Text(l10n.historyError),
                              ),
                              data: (history) {
                                final dailyMap = <String, _ChartPoint>{};

                                for (final h in history.reversed) {
                                  if (h.weightInKg != null) {
                                    final dayKey = _formatDate(h.createdAt);
                                    dailyMap[dayKey] = _ChartPoint(
                                      weight: h.weightInKg!,
                                      date: h.createdAt,
                                    );
                                  }
                                }

                                if (profile.weightInKg != null) {
                                  final todayKey = _formatDate(DateTime.now());
                                  dailyMap[todayKey] = _ChartPoint(
                                    weight: profile.weightInKg!,
                                    date: DateTime.now(),
                                  );
                                }

                                var combinedList = dailyMap.values.toList()
                                  ..sort((a, b) => a.date.compareTo(b.date));

                                if (combinedList.isEmpty) {
                                  return Center(
                                    child: Text(
                                      l10n.historyEmpty,
                                      style: textTheme.bodySmall,
                                    ),
                                  );
                                }

                                if (combinedList.length > 14) {
                                  combinedList = combinedList.sublist(
                                    combinedList.length - 14,
                                  );
                                }

                                if (combinedList.length > 2) {
                                  final newestDate = combinedList.last.date;
                                  final cutoffDate = newestDate.subtract(
                                    const Duration(days: 180),
                                  );

                                  final filtered = combinedList
                                      .where(
                                        (pt) => pt.date.isAfter(cutoffDate),
                                      )
                                      .toList();

                                  if (filtered.length >= 2) {
                                    combinedList = filtered;
                                  } else if (combinedList.length > 3) {
                                    combinedList = combinedList.sublist(
                                      combinedList.length - 3,
                                    );
                                  }
                                }

                                final startDate = DateTime(
                                  combinedList.first.date.year,
                                  combinedList.first.date.month,
                                  combinedList.first.date.day,
                                );

                                final spots = combinedList.map((pt) {
                                  final daysDiff = pt.date
                                      .difference(startDate)
                                      .inDays;
                                  return FlSpot(
                                    daysDiff.toDouble(),
                                    pt.weight,
                                  );
                                }).toList();

                                var minX = spots.first.x;
                                var maxX = spots.last.x;
                                if (minX == maxX) {
                                  minX -= 1;
                                  maxX += 1;
                                }

                                var minW = combinedList.first.weight;
                                var maxW = minW;
                                for (final pt in combinedList) {
                                  if (pt.weight < minW) minW = pt.weight;
                                  if (pt.weight > maxW) maxW = pt.weight;
                                }

                                final range = (maxW - minW).abs();
                                if (range < 0.5) {
                                  minW -= 2.0;
                                  maxW += 2.0;
                                } else {
                                  final pad = range * 0.25;
                                  minW -= pad;
                                  maxW += pad;
                                }

                                return LineChart(
                                  LineChartData(
                                    minX: minX,
                                    maxX: maxX,
                                    minY: minW,
                                    maxY: maxW,
                                    lineTouchData: LineTouchData(
                                      touchTooltipData: LineTouchTooltipData(
                                        getTooltipColor: (_) =>
                                            colorScheme.inverseSurface,
                                        getTooltipItems: (touchedSpots) {
                                          return touchedSpots.map((spot) {
                                            final idx = spots.indexWhere(
                                              (s) => s.x == spot.x,
                                            );
                                            if (idx == -1) return null;

                                            final pt = combinedList[idx];
                                            return LineTooltipItem(
                                              '${pt.weight.toStringAsFixed(1)} kg\n',
                                              textTheme.bodyMedium!.copyWith(
                                                color: colorScheme
                                                    .onInverseSurface,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: _formatDate(pt.date),
                                                  style: textTheme.labelSmall
                                                      ?.copyWith(
                                                        color: colorScheme
                                                            .onInverseSurface
                                                            .withValues(
                                                              alpha: 0.7,
                                                            ),
                                                      ),
                                                ),
                                              ],
                                            );
                                          }).toList();
                                        },
                                      ),
                                    ),
                                    gridData: FlGridData(
                                      drawVerticalLine: false,
                                      getDrawingHorizontalLine: (value) =>
                                          FlLine(
                                            color: colorScheme.outlineVariant
                                                .withValues(alpha: 0.3),
                                            strokeWidth: 1,
                                          ),
                                    ),
                                    titlesData: FlTitlesData(
                                      rightTitles: const AxisTitles(),
                                      topTitles: const AxisTitles(),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 28,
                                          getTitlesWidget: (val, meta) {
                                            final matchIdx = spots.indexWhere(
                                              (s) => s.x == val,
                                            );
                                            if (matchIdx == -1) {
                                              return const SizedBox.shrink();
                                            }

                                            final total = spots.length;
                                            final step = total > 5
                                                ? (total ~/ 3)
                                                : 1;

                                            if (matchIdx == 0 ||
                                                matchIdx == total - 1 ||
                                                matchIdx % step == 0) {
                                              final dt =
                                                  combinedList[matchIdx].date;
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 6,
                                                ),
                                                child: Text(
                                                  '${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}',
                                                  style: textTheme.labelSmall
                                                      ?.copyWith(
                                                        color: colorScheme
                                                            .onSurfaceVariant,
                                                        fontSize: 10,
                                                      ),
                                                ),
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          },
                                        ),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 34,
                                          getTitlesWidget: (val, meta) {
                                            return Text(
                                              val.toInt().toString(),
                                              style: textTheme.labelSmall
                                                  ?.copyWith(
                                                    color: colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: spots,
                                        color: colorScheme.primary,
                                        barWidth: 2.5,
                                        isStrokeCapRound: true,
                                        dotData: FlDotData(
                                          getDotPainter:
                                              (
                                                spot,
                                                percent,
                                                barData,
                                                index,
                                              ) => FlDotCirclePainter(
                                                radius: 3.5,
                                                color: colorScheme.surface,
                                                strokeWidth: 2,
                                                strokeColor:
                                                    colorScheme.primary,
                                              ),
                                        ),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          color: colorScheme.primary.withValues(
                                            alpha: 0.1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.summaryTitle,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                context.push('/profile-setup?edit=true'),
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.edit, size: 18),
                            label: Text(l10n.profileEditButton),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      _buildDataRow(
                        context,
                        l10n.summaryGender,
                        _formatGender(profile.gender, l10n),
                      ),
                      _buildDataRow(
                        context,
                        l10n.summaryBirthDate,
                        profile.birthDate ?? l10n.notSet,
                      ),
                      _buildDataRow(
                        context,
                        l10n.summaryBodyFat,
                        profile.bodyFatPercentage != null
                            ? '${profile.bodyFatPercentage}%'
                            : l10n.notProvided,
                      ),
                      _buildDataRow(
                        context,
                        l10n.summaryBmrMethod,
                        _formatBmr(profile.bmrMethod, l10n),
                      ),
                      _buildDataRow(
                        context,
                        l10n.summaryPal,
                        profile.physicalActivityLevel?.toStringAsFixed(2) ??
                            l10n.notSet,
                      ),
                      _buildDataRow(
                        context,
                        l10n.summaryGoal,
                        _formatGoal(profile.kcalGoalDifference, l10n),
                      ),
                      _buildDataRow(
                        context,
                        l10n.summaryWeekly,
                        (profile.weeklyKcalDistribution?.isNotEmpty ?? false)
                            ? l10n.summaryWeeklyCustom
                            : l10n.summaryWeeklyUniform,
                      ),
                      _buildDataRow(
                        context,
                        l10n.summaryMacros,
                        _formatMacros(profile.macroStrategy, l10n),
                      ),
                      _buildDataRow(
                        context,
                        l10n.summaryInsulinParams,
                        '${profile.insulinSensitivityFactor ?? '-'} mg/dL/U | ${profile.insulinFatProteinRatio ?? '-'} U/FPU',
                      ),
                      _buildDataRow(
                        context,
                        l10n.summaryTddAndBasal,
                        '${profile.tddMultiplier ?? '-'} U/kg | ${profile.dailyBasalInsulin ?? '-'} U',
                      ),
                      _buildDataRow(
                        context,
                        l10n.summaryInsulinDelivery,
                        _formatDeliveryMethod(
                          profile.insulinDeliveryMethod,
                          l10n,
                        ),
                      ),
                      _buildDataRow(
                        context,
                        l10n.summaryIcrHours,
                        l10n.summaryIntervals(
                          profile.hourlyCarbRatio?.length ?? 0,
                        ),
                      ),
                      _buildDataRow(
                        context,
                        l10n.summaryFpuMethod,
                        _formatCombinedInsulin(
                          profile.combinedInsulinCalculationMethod,
                          l10n,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.profileAccountSettingsTitle,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    ListTile(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      leading: const Icon(Icons.email_outlined),
                      title: Text(l10n.profileChangeEmailButton),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await showDialog<void>(
                          context: context,
                          builder: (ctx) =>
                              _ChangeVerifiedEmailDialog(l10n: l10n),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                      ),
                      leading: const Icon(Icons.lock_outline),
                      title: Text(l10n.profileChangePasswordButton),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await showDialog<void>(
                          context: context,
                          builder: (ctx) => _ChangePasswordDialog(
                            l10n: l10n,
                            currentEmail: currentEmail,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.profileActiveSessionsTitle,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildActiveSessionsCard(context, ref, l10n),
              const SizedBox(height: 32),
              Center(
                child: TextButton.icon(
                  onPressed: () async {
                    await showDialog<void>(
                      context: context,
                      builder: (ctx) => _DeleteAccountDialog(l10n: l10n),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  icon: Icon(Icons.delete_forever, color: colorScheme.error),
                  label: Text(
                    l10n.profileDeleteAccountButton,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          l10n.profileScreenTitle,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        actions: isDesktop
            ? []
            : [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Builder(
                    builder: (ctx) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                    ),
                  ),
                ),
              ],
      ),
      endDrawer: isDesktop ? null : const AppDrawer(),
      body: Row(
        children: [
          Expanded(child: contentWidget),
          if (isDesktop)
            SizedBox(
              width: 320,
              child: Material(
                color: colorScheme.surface,
                child: const AppDrawerBody(isDrawer: false),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDataRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSessionsCard(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final sessionsState = ref.watch(sessionsControllerProvider);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: sessionsState.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (err, stack) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.errorUnknown(err.toString()),
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
          ),
        ),
        data: (sessions) {
          return FutureBuilder<String>(
            future: ref
                .read(sessionsControllerProvider.notifier)
                .getCurrentDeviceId(),
            builder: (context, snapshot) {
              final currentDeviceId = snapshot.data ?? '';

              return Column(
                children: sessions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final session = entry.value;
                  final isCurrent = session.deviceId == currentDeviceId;

                  final deviceInfo = _parseDeviceInfo(
                    session.deviceId,
                    session.userAgent,
                    l10n,
                  );
                  final dateStr = session.lastAccessedAt.toString().substring(
                    0,
                    16,
                  );

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              deviceInfo.icon,
                              size: 32,
                              color: isCurrent
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          deviceInfo.name,
                                          style: textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (isCurrent)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                colorScheme.tertiaryContainer,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            l10n.profileSessionCurrent,
                                            style: textTheme.bodySmall
                                                ?.copyWith(
                                                  fontSize: 12,
                                                  color: colorScheme
                                                      .onTertiaryContainer,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        )
                                      else
                                        TextButton(
                                          onPressed: () async {
                                            try {
                                              await ref
                                                  .read(
                                                    sessionsControllerProvider
                                                        .notifier,
                                                  )
                                                  .revokeSession(
                                                    session.deviceId,
                                                  );
                                            } on Object catch (_) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      l10n.errorSessionRevoke,
                                                    ),
                                                    backgroundColor:
                                                        colorScheme.error,
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: colorScheme.error,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: Text(
                                            l10n.profileSessionRevoke,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'IP: ${session.ipAddress}  •  ${l10n.lastActive}: $dateStr',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (index < sessions.length - 1) const Divider(height: 1),
                    ],
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}

class _ChangeVerifiedEmailDialog extends ConsumerStatefulWidget {
  const _ChangeVerifiedEmailDialog({required this.l10n});
  final AppLocalizations l10n;

  @override
  ConsumerState<_ChangeVerifiedEmailDialog> createState() =>
      _ChangeVerifiedEmailDialogState();
}

class _ChangeVerifiedEmailDialogState
    extends ConsumerState<_ChangeVerifiedEmailDialog> {
  final _passwordController = TextEditingController();
  final _newEmailController = TextEditingController();
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  static final _emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  bool _isCodeSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _newEmailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final colorScheme = Theme.of(context).colorScheme;

    setState(() => _isLoading = true);
    final repo = ref.read(authRepositoryProvider);

    try {
      if (!_isCodeSent) {
        await repo.requestVerifiedEmailChange(
          newEmail: _newEmailController.text.trim(),
          password: _passwordController.text,
        );
        if (mounted) setState(() => _isCodeSent = true);
      } else {
        final newEmail = _newEmailController.text.trim();
        await repo.confirmVerifiedEmailChange(
          newEmail: newEmail,
          code: _codeController.text.trim(),
        );

        await ref.read(authLocalStorageProvider).saveEmail(newEmail);
        ref.invalidate(currentUserEmailProvider);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.l10n.emailChangedSuccessfully),
              backgroundColor: colorScheme.tertiary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _mapDioError(e, widget.l10n, isSecondStep: _isCodeSent),
            ),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isCodeValid = _codeController.text.trim().length == 6;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.l10n.profileChangeEmailButton,
        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isCodeSent
                    ? widget.l10n.profileChangeEmailCodeSubtitle
                    : widget.l10n.profileChangeEmailDialogSubtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              if (!_isCodeSent) ...[
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: textTheme.bodyMedium,
                  decoration: InputDecoration(
                    labelText: widget.l10n.currentPasswordLabel,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return widget.l10n.errorPasswordRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _newEmailController,
                  keyboardType: TextInputType.emailAddress,
                  style: textTheme.bodyMedium,
                  decoration: InputDecoration(
                    labelText: widget.l10n.newEmailLabel,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return widget.l10n.errorEmailRequired;
                    }
                    if (!_emailRegex.hasMatch(v.trim())) {
                      return widget.l10n.errorInvalidEmail;
                    }
                    return null;
                  },
                ),
              ] else ...[
                TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  style: textTheme.headlineMedium?.copyWith(
                    letterSpacing: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: InputDecoration(
                    hintText: '123456',
                    hintStyle: textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                      letterSpacing: 12,
                      fontWeight: FontWeight.normal,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    counterText: '',
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    if (v == null || v.trim().length != 6) {
                      return widget.l10n.errorInvalidVerificationCode;
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) async {
                    if (isCodeValid && !_isLoading) await _submit();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: (_isLoading || (_isCodeSent && !isCodeValid))
              ? null
              : _submit,
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
              : Text(
                  _isCodeSent
                      ? widget.l10n.verifyButton
                      : widget.l10n.sendCodeButton,
                ),
        ),
      ],
    );
  }
}

class _ChangePasswordDialog extends ConsumerStatefulWidget {
  const _ChangePasswordDialog({required this.l10n, required this.currentEmail});
  final AppLocalizations l10n;
  final String currentEmail;

  @override
  ConsumerState<_ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<_ChangePasswordDialog> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isCodeSent = false;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final colorScheme = Theme.of(context).colorScheme;

    final passwordRules = PasswordRulesWidget(
      password: _newPasswordController.text,
    );
    if (!_isCodeSent && !passwordRules.isValid) return;

    setState(() => _isLoading = true);
    final repo = ref.read(authRepositoryProvider);

    try {
      if (!_isCodeSent) {
        await repo.requestPasswordReset(email: widget.currentEmail);
        if (mounted) setState(() => _isCodeSent = true);
      } else {
        await repo.confirmPasswordReset(
          email: widget.currentEmail,
          code: _codeController.text.trim(),
          newPassword: _newPasswordController.text,
        );

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.l10n.passwordChangedSuccessfully),
              backgroundColor: colorScheme.tertiary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

          await ref.read(authStateControllerProvider.notifier).logout();
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _mapDioError(e, widget.l10n, isSecondStep: _isCodeSent),
            ),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final rulesWidget = PasswordRulesWidget(
      password: _newPasswordController.text,
    );
    final isCodeValid = _codeController.text.trim().length == 6;
    final passwordsMatch =
        _newPasswordController.text == _confirmPasswordController.text;

    final canSubmitStep1 =
        rulesWidget.isValid &&
        passwordsMatch &&
        _newPasswordController.text.isNotEmpty;
    final canSubmitStep2 = isCodeValid;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.l10n.profileChangePasswordButton,
        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isCodeSent
                    ? widget.l10n.profileChangePasswordCodeSubtitle
                    : widget.l10n.profileChangePasswordDialogSubtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              if (!_isCodeSent) ...[
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: !_isPasswordVisible,
                  style: textTheme.bodyMedium,
                  decoration: InputDecoration(
                    labelText: widget.l10n.newPasswordLabel,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible,
                      ),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (v) => v == null || v.isEmpty
                      ? widget.l10n.errorFieldRequired
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  style: textTheme.bodyMedium,
                  decoration: InputDecoration(
                    labelText: widget.l10n.confirmNewPasswordLabel,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => setState(
                        () => _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible,
                      ),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return widget.l10n.errorFieldRequired;
                    }
                    if (v != _newPasswordController.text) {
                      return widget.l10n.errorPasswordsDoNotMatch;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                rulesWidget,
              ] else ...[
                TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  style: textTheme.headlineMedium?.copyWith(
                    letterSpacing: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: InputDecoration(
                    hintText: '123456',
                    hintStyle: textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                      letterSpacing: 12,
                      fontWeight: FontWeight.normal,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    counterText: '',
                  ),
                  onChanged: (_) => setState(() {}),
                  onFieldSubmitted: (_) async {
                    if (canSubmitStep2 && !_isLoading) await _submit();
                  },
                  validator: (v) {
                    if (v == null || v.trim().length != 6) {
                      return widget.l10n.errorInvalidVerificationCode;
                    }
                    return null;
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          onPressed:
              _isLoading ||
                  (!_isCodeSent && !canSubmitStep1) ||
                  (_isCodeSent && !canSubmitStep2)
              ? null
              : _submit,
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
              : Text(
                  _isCodeSent
                      ? widget.l10n.verifyButton
                      : widget.l10n.sendCodeButton,
                ),
        ),
      ],
    );
  }
}

class _DeleteAccountDialog extends ConsumerStatefulWidget {
  const _DeleteAccountDialog({required this.l10n});
  final AppLocalizations l10n;

  @override
  ConsumerState<_DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<_DeleteAccountDialog> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isCodeSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isCodeSent && !_formKey.currentState!.validate()) return;
    final colorScheme = Theme.of(context).colorScheme;

    setState(() => _isLoading = true);
    final repo = ref.read(authRepositoryProvider);

    try {
      if (!_isCodeSent) {
        await repo.requestAccountDeletion();
        if (mounted) setState(() => _isCodeSent = true);
      } else {
        await repo.confirmAccountDeletion(code: _codeController.text.trim());

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.l10n.accountDeletedSuccessfully),
              backgroundColor: colorScheme.tertiary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

          await ref.read(authStateControllerProvider.notifier).logout();
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _mapDioError(e, widget.l10n, isSecondStep: _isCodeSent),
            ),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isCodeValid = _codeController.text.trim().length == 6;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.l10n.profileDeleteAccountDialogTitle,
        style: textTheme.titleMedium?.copyWith(
          color: colorScheme.error,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isCodeSent
                    ? widget.l10n.profileDeleteAccountCodeSubtitle
                    : widget.l10n.profileDeleteAccountWarning,
                style: textTheme.bodyMedium,
              ),
              if (_isCodeSent) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  style: textTheme.headlineMedium?.copyWith(
                    letterSpacing: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: InputDecoration(
                    hintText: '123456',
                    hintStyle: textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                      letterSpacing: 12,
                      fontWeight: FontWeight.normal,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    counterText: '',
                  ),
                  onChanged: (_) => setState(() {}),
                  onFieldSubmitted: (_) async {
                    if (isCodeValid && !_isLoading) await _submit();
                  },
                  validator: (v) {
                    if (v == null || v.trim().length != 6) {
                      return widget.l10n.errorInvalidVerificationCode;
                    }
                    return null;
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _isLoading || (_isCodeSent && !isCodeValid)
              ? null
              : _submit,
          child: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onError,
                  ),
                )
              : Text(
                  _isCodeSent
                      ? widget.l10n.confirmDeleteButton
                      : widget.l10n.requestDeleteButton,
                ),
        ),
      ],
    );
  }
}

class _ChartPoint {
  _ChartPoint({required this.weight, required this.date});
  final double weight;
  final DateTime date;
}
