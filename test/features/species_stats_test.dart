import 'package:bada_sanai/features/catch_log/domain/catch_log_models.dart';
import 'package:bada_sanai/features/species/domain/species_stats.dart';
import 'package:test/test.dart';

CatchLogView log(DateTime at, List<CatchItemInput> items, {String id = 'l'}) =>
    CatchLogView(
      id: id,
      genre: Genre.lure,
      fishedAt: at,
      genreDetail: const {},
      items: items,
    );

CatchItemInput item(String code, {int count = 1, double? len}) =>
    CatchItemInput(speciesCode: code, count: count, lengthCm: len);

void main() {
  group('isWithinMonths', () {
    test('같은 달과 앞뒤 달', () {
      expect(isWithinMonths(11, 11, 1), isTrue);
      expect(isWithinMonths(10, 11, 1), isTrue);
      expect(isWithinMonths(12, 11, 1), isTrue);
      expect(isWithinMonths(9, 11, 1), isFalse);
      expect(isWithinMonths(5, 11, 1), isFalse);
    });

    test('12월과 1월은 이어진다', () {
      expect(isWithinMonths(1, 12, 1), isTrue);
      expect(isWithinMonths(12, 1, 1), isTrue);
      expect(isWithinMonths(2, 12, 1), isFalse);
      expect(isWithinMonths(2, 12, 2), isTrue);
    });

    test('window 0은 같은 달만', () {
      expect(isWithinMonths(11, 11, 0), isTrue);
      expect(isWithinMonths(10, 11, 0), isFalse);
    });
  });

  group('speciesRanking', () {
    final now = DateTime(2026, 11, 27);

    test('이 시기 일지만 모으고 마릿수 많은 순으로 정렬한다', () {
      final logs = [
        log(DateTime(2025, 11, 3), [item('seabass', count: 2, len: 55), item('flatfish')]),
        log(DateTime(2024, 10, 20), [item('seabass', len: 70)]), // 연도 무관, 10월 포함
        log(DateTime(2026, 6, 1), [item('mackerel', count: 30)]), // 6월: 제외
      ];
      final r = speciesRanking(logs, now: now);
      expect(r.map((e) => e.speciesCode), ['seabass', 'flatfish']);
      expect(r.first.totalCount, 3);
      expect(r.first.logCount, 2);
      expect(r.first.maxLengthCm, 70);
      expect(r.last.maxLengthCm, isNull);
    });

    test('같은 일지의 같은 어종 여러 줄은 출조 한 번으로 센다', () {
      final r = speciesRanking([
        log(DateTime(2026, 11, 1), [item('seabass', count: 2), item('seabass', count: 3)]),
      ], now: now);
      expect(r.single.totalCount, 5);
      expect(r.single.logCount, 1);
    });

    test('마릿수가 같으면 출조 횟수, 그다음 코드 순', () {
      final r = speciesRanking([
        log(DateTime(2026, 11, 1), [item('b', count: 2), item('a', count: 1)]),
        log(DateTime(2026, 11, 2), [item('a', count: 1)]),
        log(DateTime(2026, 11, 3), [item('c', count: 2)]),
      ], now: now);
      // a: 2마리/2회, b: 2마리/1회, c: 2마리/1회
      expect(r.map((e) => e.speciesCode), ['a', 'b', 'c']);
    });

    test('기록이 없거나 조과가 없으면 빈 목록', () {
      expect(speciesRanking([], now: now), isEmpty);
      expect(speciesRanking([log(DateTime(2026, 11, 1), [])], now: now), isEmpty);
    });

    test('window를 넓히면 더 많은 달을 포함한다', () {
      final logs = [log(DateTime(2026, 8, 1), [item('squid')])];
      expect(speciesRanking(logs, now: now), isEmpty);
      expect(speciesRanking(logs, now: now, window: 3).single.speciesCode, 'squid');
    });
  });
}
