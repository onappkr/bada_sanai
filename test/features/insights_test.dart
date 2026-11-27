import 'package:bada_sanai/features/catch_log/domain/catch_log_models.dart';
import 'package:bada_sanai/features/catch_log/domain/log_environment.dart';
import 'package:bada_sanai/features/forecast/domain/forecast_models.dart';
import 'package:bada_sanai/features/insights/domain/insights.dart';
import 'package:test/test.dart';

int _seq = 0;

/// [at]은 로컬 시각으로 만든다(시간대 구분이 로컬 기준이라서).
CatchLogView log(
  DateTime at, {
  String? point,
  int fish = 0,
  String species = 'seabass',
  Genre genre = Genre.lure,
  double? wind,
}) =>
    CatchLogView(
      id: 'l${++_seq}',
      genre: genre,
      fishedAt: at,
      pointId: point,
      genreDetail: const {},
      items: fish == 0 ? const [] : [CatchItemInput(speciesCode: species, count: fish)],
      environment: wind == null
          ? null
          : LogEnvironment(
              forecast: ForecastBundle(
                regionCode: 'r',
                date: '2026-11-01',
                fetchedAt: DateTime.utc(2026, 11, 1),
                stale: false,
                weather: WeatherInfo(windMps: wind),
              ),
            ),
    );

void main() {
  group('시간대·묶음 통계', () {
    test('시간대 경계', () {
      expect(timeBandOf(DateTime(2026, 11, 1, 3, 59)), TimeBand.night);
      expect(timeBandOf(DateTime(2026, 11, 1, 4)), TimeBand.dawn);
      expect(timeBandOf(DateTime(2026, 11, 1, 8)), TimeBand.morning);
      expect(timeBandOf(DateTime(2026, 11, 1, 12)), TimeBand.afternoon);
      expect(timeBandOf(DateTime(2026, 11, 1, 17)), TimeBand.evening);
      expect(timeBandOf(DateTime(2026, 11, 1, 21)), TimeBand.night);
      expect(timeBandOf(DateTime(2026, 11, 1, 0)), TimeBand.night);
    });

    test('시간대별 출조당 마릿수와 꽝 수', () {
      final s = timeBandStats([
        log(DateTime(2026, 11, 1, 5), fish: 4),
        log(DateTime(2026, 11, 2, 6), fish: 0),
        log(DateTime(2026, 11, 3, 19), fish: 1),
      ]);
      expect(s.first.key, TimeBand.dawn == s.first.key ? TimeBand.dawn : s.first.key);
      final dawn = s.firstWhere((e) => e.key == TimeBand.dawn);
      expect((dawn.trips, dawn.fish, dawn.zeroTrips, dawn.perTrip), (2, 4, 1, 2.0));
      expect(s.first.key, TimeBand.dawn); // 2.0 > 1.0
    });

    test('표본 수가 3 미만이면 믿을 만하지 않다', () {
      final s = monthStats([log(DateTime(2026, 11, 1), fish: 9), log(DateTime(2025, 11, 1), fish: 9)]);
      expect(s.single.key, 11); // 해가 달라도 같은 달로 합친다
      expect(s.single.trips, 2);
      expect(s.single.reliable, isFalse);
    });

    test('포인트가 없는 일지는 포인트 통계에서 빠진다', () {
      final s = pointStats([log(DateTime(2026, 11, 1), fish: 3), log(DateTime(2026, 11, 2), point: 'a', fish: 1)]);
      expect(s.map((e) => e.key), ['a']);
    });

    test('같은 출조당 마릿수면 출조가 많은 쪽이 앞', () {
      final s = pointStats([
        log(DateTime(2026, 11, 1), point: 'a', fish: 2),
        log(DateTime(2026, 11, 2), point: 'b', fish: 2),
        log(DateTime(2026, 11, 3), point: 'b', fish: 2),
      ]);
      expect(s.map((e) => e.key), ['b', 'a']);
    });
  });

  group('풍속 구간', () {
    test('경계값', () {
      expect(windBandOf(2.9), WindBand.calm);
      expect(windBandOf(3), WindBand.moderate);
      expect(windBandOf(6.9), WindBand.moderate);
      expect(windBandOf(7), WindBand.strong);
    });

    test('환경이 붙지 않은 일지는 뺀다', () {
      final s = windStats([
        log(DateTime(2026, 11, 1), fish: 5, wind: 1),
        log(DateTime(2026, 11, 2), fish: 1, wind: 9),
        log(DateTime(2026, 11, 3), fish: 7), // 환경 없음
      ]);
      expect(s.map((e) => e.key).toSet(), {WindBand.calm, WindBand.strong});
      expect(s.first.key, WindBand.calm);
    });
  });

  test('요약: 총계, 꽝 비율, 기간', () {
    final s = summarize([
      log(DateTime(2026, 1, 5), fish: 3),
      log(DateTime(2026, 3, 5), fish: 0),
      log(DateTime(2026, 2, 5), fish: 1),
      log(DateTime(2026, 4, 5), fish: 0),
    ]);
    expect((s.trips, s.fish, s.zeroTrips), (4, 4, 2));
    expect(s.zeroRate, 0.5);
    expect(s.perTrip, 1.0);
    expect(s.firstAt, DateTime(2026, 1, 5));
    expect(s.lastAt, DateTime(2026, 4, 5));
    expect(summarize(const []).perTrip, 0);
  });

  group('지금 가기 좋은 포인트 추천', () {
    final now = DateTime(2026, 11, 15, 6); // 11월, 새벽

    List<CatchLogView> base() => [
          // a: 11월 새벽에 잘 잡힘
          log(DateTime(2025, 11, 10, 5), point: 'a', fish: 6),
          log(DateTime(2026, 10, 30, 6), point: 'a', fish: 5),
          // b: 한여름 낮에만 갔고 못 잡음
          log(DateTime(2026, 7, 10, 14), point: 'b', fish: 0),
          log(DateTime(2026, 8, 10, 13), point: 'b', fish: 1),
          log(DateTime(2026, 7, 20, 15), point: 'b', fish: 0),
        ];

    test('기록이 5개 미만이면 추천하지 않는다', () {
      expect(recommendSpots(base().take(4), now: now), isEmpty);
    });

    test('같은 시기·시간대에 잘 잡힌 곳이 먼저 나온다', () {
      final r = recommendSpots(base(), now: now);
      expect(r.map((e) => e.pointId), ['a', 'b']);
      expect(r.first.score, greaterThan(r.last.score));
      expect(r.first.similarTrips, 2);
      expect(r.first.topSpecies, 'seabass');
    });

    test('평균이 같으면 표본이 많은 곳이 앞서고, 한 번의 대박은 평균 쪽으로 당겨진다', () {
      final logs = [
        log(DateTime(2026, 11, 1, 6), point: 'once', fish: 6),
        for (var i = 0; i < 4; i++) log(DateTime(2026, 11, 2 + i, 6), point: 'steady', fish: 6),
        log(DateTime(2026, 11, 8, 6), point: 'other', fish: 1),
      ];
      final r = recommendSpots(logs, now: now);
      expect(r.first.pointId, 'steady');

      final big = recommendSpots([
        log(DateTime(2026, 11, 1, 6), point: 'once', fish: 12),
        for (var i = 0; i < 5; i++) log(DateTime(2026, 11, 2 + i, 6), point: 'x', fish: 2),
      ], now: now).firstWhere((e) => e.pointId == 'once');
      expect(big.score, lessThan(12)); // 12마리 그대로가 아니다
      expect(big.score, greaterThan(2)); // 그래도 평균보다는 높다
    });

    test('limit과 장르 필터', () {
      final logs = [
        for (var i = 0; i < 10; i++) log(DateTime(2026, 11, 1 + i, 6), point: 'p$i', fish: i, genre: i < 6 ? Genre.lure : Genre.cast),
      ];
      expect(recommendSpots(logs, now: now, limit: 2), hasLength(2));
      final lureOnly = recommendSpots(logs, now: now, genre: Genre.lure, limit: 10);
      expect(lureOnly.map((e) => e.pointId).toSet(), {for (var i = 0; i < 6; i++) 'p$i'});
      // 해당 장르 기록이 5개 미만이면 추천하지 않는다.
      expect(recommendSpots(logs, now: now, genre: Genre.cast), isEmpty);
    });

    test('입력 순서가 달라도 결과가 같다', () {
      final a = recommendSpots(base(), now: now).map((e) => e.pointId).toList();
      final b = recommendSpots(base().reversed, now: now).map((e) => e.pointId).toList();
      expect(a, b);
    });

    test('12월과 1월은 이어진 시기로 본다', () {
      final jan = DateTime(2027, 1, 5, 6);
      final logs = [
        for (var i = 0; i < 5; i++) log(DateTime(2026, 12, 1 + i, 6), point: 'dec', fish: 3),
      ];
      expect(recommendSpots(logs, now: jan).single.similarTrips, 5);
    });
  });
}
