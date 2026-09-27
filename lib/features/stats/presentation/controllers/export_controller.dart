import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:gluqalc_app/features/stats/data/repositories/stats_repository.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'export_controller.g.dart';

@riverpod
class ExportController extends _$ExportController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> downloadExport(DateTime from, DateTime to) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(statsRepositoryProvider);
      final bytes = await repo.exportCsv(from, to);

      final fromStr = DateFormat('yyyy-MM-dd').format(from);
      final toStr = DateFormat('yyyy-MM-dd').format(to);
      final filename = 'gluqalc_export_${fromStr}_$toStr';

      final isMobile =
          !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS);

      if (isMobile) {
        await FileSaver.instance.saveAs(
          name: filename,
          bytes: Uint8List.fromList(bytes),
          fileExtension: 'csv',
          mimeType: MimeType.csv,
        );
      } else {
        await FileSaver.instance.saveFile(
          name: filename,
          bytes: Uint8List.fromList(bytes),
          fileExtension: 'csv',
          mimeType: MimeType.csv,
        );
      }

      state = const AsyncData(null);
    } on Object catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
