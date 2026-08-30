import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_selected_date_controller.g.dart';

@riverpod
class HomeSelectedDate extends _$HomeSelectedDate {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void updateDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final diff = date.difference(today).inDays;
    if (diff >= -60 && diff <= 60) {
      state = date;
    }
  }
}
