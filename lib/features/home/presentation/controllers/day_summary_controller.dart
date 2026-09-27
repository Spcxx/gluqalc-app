import 'package:gluqalc_app/features/home/data/models/day_summary_model.dart';
import 'package:gluqalc_app/features/home/data/repositories/home_repository.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/home_selected_date_controller.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'day_summary_controller.g.dart';

@riverpod
class DaySummaryController extends _$DaySummaryController {
  final Map<String, DaySummaryResponse> _cache = {};

  DaySummaryResponse? getCachedSummary(DateTime date) {
    final key = DateFormat('yyyy-MM-dd').format(date);
    return _cache[key];
  }

  @override
  Future<DaySummaryResponse> build() async {
    final date = ref.watch(homeSelectedDateProvider);
    final repository = ref.watch(homeRepositoryProvider);

    final summary = await repository.getDaySummary(date);

    final key = DateFormat('yyyy-MM-dd').format(date);
    _cache[key] = summary;

    return summary;
  }
}
