import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gluqalc_app/core/presentation/widgets/app_drawer.dart';
import 'package:gluqalc_app/features/stats/presentation/controllers/export_controller.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: now.subtract(const Duration(days: 7)),
      end: now,
    );
  }

  Future<void> _pickDateRange() async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: _dateRange,
      helpText: l10n.exportSelectDates,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            appBarTheme: const AppBarTheme(centerTitle: true),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  String _mapExportError(Object error, AppLocalizations l10n) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      switch (statusCode) {
        case 429:
          return l10n.errorRateLimit;
        case 404:
          return l10n.errorNoProfile;
        case 400:
          return l10n.errorValidationError;
        case 401:
          return l10n.errorUnauthorized;
        case 500:
        case 502:
        case 503:
          return l10n.errorServerError;
      }
    }
    return l10n.errorUnknown(error.toString());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final exportState = ref.watch(exportControllerProvider);

    ref.listen(exportControllerProvider, (prev, next) {
      next.whenOrNull(
        error: (err, st) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_mapExportError(err, l10n)),
              backgroundColor: colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        data: (_) {
          if (prev is AsyncLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.exportSuccess),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      );
    });

    final isExporting = exportState is AsyncLoading;

    String formatDate(DateTime d) => d.toIso8601String().split('T')[0];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const BackButton(),
        title: Text(
          l10n.exportTitle,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        actions: [
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
      endDrawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.analytics_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.exportDescription,
              style: TextStyle(
                fontSize: 15,
                color: colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isExporting ? null : _pickDateRange,
                borderRadius: BorderRadius.circular(16),
                child: Ink(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                    ),
                    borderRadius: BorderRadius.circular(16),
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.calendar_month,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.exportSelectDates,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _dateRange != null
                                  ? '${formatDate(_dateRange!.start)}  —  ${formatDate(_dateRange!.end)}'
                                  : l10n.notSet,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.edit_calendar,
                        color: colorScheme.primary,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
            if (isExporting) ...[
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 16),
              Text(
                l10n.exportLoading,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else
              FilledButton.icon(
                onPressed: _dateRange == null
                    ? null
                    : () async {
                        await ref
                            .read(exportControllerProvider.notifier)
                            .downloadExport(
                              _dateRange!.start,
                              _dateRange!.end,
                            );
                      },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.download),
                label: Text(
                  l10n.exportButton,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
