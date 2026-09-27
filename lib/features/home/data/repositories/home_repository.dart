import 'package:dio/dio.dart';
import 'package:gluqalc_app/core/networking/dio_provider.dart';
import 'package:gluqalc_app/features/home/data/models/day_summary_model.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_repository.g.dart';

@riverpod
HomeRepository homeRepository(Ref ref) {
  return HomeRepository(ref.watch(dioProvider));
}

class HomeRepository {
  HomeRepository(this._dio);

  final Dio _dio;

  Future<DaySummaryResponse> getDaySummary(DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/log/summary',
      queryParameters: {'date': dateStr},
    );

    return DaySummaryResponse.fromJson(response.data ?? {});
  }
}
