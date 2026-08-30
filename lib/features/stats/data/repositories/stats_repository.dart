import 'package:dio/dio.dart';
import 'package:gluqalc_app/core/networking/dio_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stats_repository.g.dart';

@riverpod
StatsRepository statsRepository(Ref ref) {
  return StatsRepository(ref.watch(dioProvider));
}

class StatsRepository {
  StatsRepository(this._dio);

  final Dio _dio;

  Future<List<int>> exportCsv(DateTime from, DateTime to) async {
    final fromStr = from.toIso8601String().split('T')[0];
    final toStr = to.toIso8601String().split('T')[0];

    final response = await _dio.get<List<int>>(
      '/api/v1/stats/export',
      queryParameters: {'from': fromStr, 'to': toStr},
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );

    return response.data ?? <int>[];
  }
}
