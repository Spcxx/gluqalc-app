import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:gluqalc_app/features/stats/data/repositories/stats_repository.dart';
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

      final fromStr = from.toIso8601String().split('T')[0];
      final toStr = to.toIso8601String().split('T')[0];
      final filename = 'gluqalc_export_${fromStr}_$toStr';

      await FileSaver.instance.saveFile(
        name: filename,
        bytes: Uint8List.fromList(bytes),
        fileExtension: 'csv',
        mimeType: MimeType.csv,
      );

      state = const AsyncData(null);
    } on Object catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
