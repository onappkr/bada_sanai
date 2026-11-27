import 'package:bada_sanai/features/catch_log/domain/catch_log_models.dart';
import 'package:bada_sanai/features/catch_log/domain/log_period.dart';
import 'package:test/test.dart';

CatchLogView log(String id, DateTime at) => CatchLogView(
      id: id,
      genre: Genre.lure,
      fishedAt: at,
      genreDetail: const {},
      items: const [],
    );

void main() {
  // 로컬 시각 기준. 2026-11-27(금)
  final now = DateTime(2026, 11, 27, 15);

  group('LogPeriod.contains', () {
    test('전체 기간은 항상 true', () {
      expect(LogPeriod.all.contains(DateTime(1999), now), isTrue);
      expect(LogPeriod.all.contains(DateTime(2030), now), isTrue);
    });

    test('이번 달: 같은 해·같은 달만', () {
      expect(LogPeriod.thisMonth.contains(DateTime(2026, 11, 1), now), isTrue);
      expect(LogPeriod.thisMonth.contains(DateTime(2026, 11, 30, 23, 59), now), isTrue);
      expect(LogPeriod.thisMonth.contains(DateTime(2026, 10, 31, 23, 59), now), isFalse);
      expect(LogPeriod.thisMonth.contains(DateTime(2025, 11, 15), now), isFalse); // 작년 같은 달
    });

    test('최근 3개월: 이번 달 포함 세 달(9월 1일부터)', () {
      expect(LogPeriod.last3Months.contains(DateTime(2026, 9, 1), now), isTrue);
      expect(LogPeriod.last3Months.contains(DateTime(2026, 8, 31, 23, 59), now), isFalse);
      expect(LogPeriod.last3Months.contains(DateTime(2026, 10, 15), now), isTrue);
    });

    test('최근 3개월: 해가 바뀌어도 맞다(1월 기준이면 11월 1일부터)', () {
      final jan = DateTime(2027, 1, 10);
      expect(LogPeriod.last3Months.contains(DateTime(2026, 11, 1), jan), isTrue);
      expect(LogPeriod.last3Months.contains(DateTime(2026, 10, 31), jan), isFalse);
    });

    test('올해: 1월 1일부터 12월 31일까지', () {
      expect(LogPeriod.thisYear.contains(DateTime(2026, 1, 1), now), isTrue);
      expect(LogPeriod.thisYear.contains(DateTime(2026, 12, 31), now), isTrue);
      expect(LogPeriod.thisYear.contains(DateTime(2025, 12, 31, 23, 59), now), isFalse);
    });

    test('UTC로 저장된 시각도 로컬 기준으로 판단한다', () {
      final utc = DateTime.utc(2026, 11, 10, 3);
      expect(LogPeriod.thisMonth.contains(utc, now), isTrue);
    });
  });

  test('filterByPeriod는 순서를 유지하고 기간 밖은 뺀다', () {
    final logs = [
      log('a', DateTime(2026, 11, 20)),
      log('b', DateTime(2026, 6, 1)),
      log('c', DateTime(2026, 10, 5)),
    ];
    expect(filterByPeriod(logs, LogPeriod.last3Months, now).map((e) => e.id), ['a', 'c']);
    expect(filterByPeriod(logs, LogPeriod.thisYear, now).map((e) => e.id), ['a', 'b', 'c']);
    expect(filterByPeriod(logs, LogPeriod.thisMonth, now).map((e) => e.id), ['a']);
    expect(filterByPeriod(const [], LogPeriod.thisMonth, now), isEmpty);
  });
}
