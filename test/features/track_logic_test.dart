import 'package:bada_sanai/core/geo/polyline_codec.dart';
import 'package:bada_sanai/features/tracking/domain/track_logic.dart';
import 'package:test/test.dart';

final t0 = DateTime.utc(2026, 11, 27, 6);

/// 위도 1e-5도 ≈ 1.11m. 북쪽으로 [meters] 떨어진 점.
LocationSample at(int seconds, {double northM = 0, double? acc, double? speed}) =>
    LocationSample(
      lat: 35.0 + northM / 111195,
      lng: 129.0,
      time: t0.add(Duration(seconds: seconds)),
      accuracyM: acc,
      speedMps: speed,
    );

void main() {
  group('samplingInterval', () {
    test('속도가 빠를수록 촘촘하다', () {
      expect(samplingInterval(null), const Duration(seconds: 30));
      expect(samplingInterval(0.2), const Duration(seconds: 30));
      expect(samplingInterval(1.2), const Duration(seconds: 10));
      expect(samplingInterval(5), const Duration(seconds: 5));
    });
  });

  group('acceptSample', () {
    test('첫 점은 받는다. 오차가 50m를 넘으면 버린다', () {
      expect(acceptSample(null, at(0)), isTrue);
      expect(acceptSample(null, at(0, acc: 50)), isTrue);
      expect(acceptSample(null, at(0, acc: 50.1)), isFalse);
    });

    test('수집 주기보다 일찍 온 점은 버린다', () {
      final prev = at(0, speed: 0); // 정지 → 30초 주기
      expect(acceptSample(prev, at(20, northM: 3)), isFalse);
      expect(acceptSample(prev, at(30, northM: 3)), isTrue);
    });

    test('시간이 같거나 거꾸로 가면 버린다', () {
      final prev = at(100);
      expect(acceptSample(prev, at(100, northM: 5)), isFalse);
      expect(acceptSample(prev, at(50, northM: 5)), isFalse);
    });

    test('불가능한 속도로 튄 점(GPS 오류)은 버린다', () {
      final prev = at(0, speed: 5); // 5초 주기
      // 10초에 1km → 100 m/s
      expect(acceptSample(prev, at(10, northM: 1000)), isFalse);
      // 10초에 100m → 10 m/s (배·차 속도) 는 받는다
      expect(acceptSample(prev, at(10, northM: 100)), isTrue);
    });
  });

  group('detectCandidates', () {
    test('30m 안에서 10분 이상 머물면 중심이 후보가 된다', () {
      final samples = [
        for (var i = 0; i <= 12; i++) at(i * 60, northM: (i % 3).toDouble()),
      ];
      final c = detectCandidates(samples);
      expect(c.length, 1);
      expect(c.single.dwell, const Duration(minutes: 12));
      expect(c.single.lat, closeTo(35.0 + 1 / 111195, 1e-5));
    });

    test('10분 미만이면 후보가 아니다', () {
      final samples = [for (var i = 0; i <= 9; i++) at(i * 60)];
      expect(detectCandidates(samples), isEmpty);
    });

    test('30m 밖으로 벗어나면 머문 시간이 끊긴다', () {
      final samples = [
        for (var i = 0; i <= 5; i++) at(i * 60),
        for (var i = 6; i <= 11; i++) at(i * 60, northM: 200),
      ];
      expect(detectCandidates(samples), isEmpty);
    });

    test('서로 다른 두 자리에서 각각 후보가 나온다', () {
      final samples = [
        for (var i = 0; i <= 10; i++) at(i * 60),
        at(11 * 60, northM: 500), // 이동
        for (var i = 12; i <= 23; i++) at(i * 60, northM: 1000),
      ];
      final c = detectCandidates(samples);
      expect(c.length, 2);
      expect(c.first.lat, lessThan(c.last.lat));
    });

    test('점이 없거나 한 개면 빈 목록', () {
      expect(detectCandidates([]), isEmpty);
      expect(detectCandidates([at(0)]), isEmpty);
    });
  });

  group('TrackSession', () {
    test('걸러진 점은 쌓이지 않고 거리·경과 시간이 계산된다', () {
      final s = TrackSession(startedAt: t0);
      expect(s.add(at(0, speed: 0)), isTrue);
      expect(s.add(at(10, northM: 5)), isFalse); // 주기 전
      expect(s.add(at(30, northM: 100, acc: 80)), isFalse); // 오차 큼
      expect(s.add(at(40, northM: 100)), isTrue);
      expect(s.samples.length, 2);
      expect(s.distanceM, closeTo(100, 1));
      expect(s.elapsed, const Duration(seconds: 40));
    });

    test('일시정지 중에는 점을 받지 않는다', () {
      final s = TrackSession(startedAt: t0)..add(at(0));
      s.paused = true;
      expect(s.add(at(60, northM: 50)), isFalse);
      s.paused = false;
      expect(s.add(at(120, northM: 50)), isTrue);
    });

    test('종료하면 단순화한 경로와 후보가 나온다', () {
      final s = TrackSession(startedAt: t0);
      // 일직선으로 북쪽으로 걷다가(1분마다 80m), 한 자리에서 11분 머문다
      for (var i = 0; i < 5; i++) {
        s.add(at(i * 60, northM: i * 80.0, speed: 1.3));
      }
      for (var i = 5; i <= 16; i++) {
        s.add(at(i * 60, northM: 320, speed: 0));
      }
      final r = s.finish();
      expect(r.candidates.length, 1);
      expect(r.candidates.single.dwell, greaterThanOrEqualTo(const Duration(minutes: 10)));
      final line = PolylineCodec.decode(r.encodedPolyline);
      // 일직선 경로라 중간 점이 빠지고 양 끝만 남는다
      expect(line.length, lessThan(s.samples.length));
      expect(line.first.lat, closeTo(35.0, 1e-4));
      expect(r.distanceM, closeTo(320, 3));
      expect(r.endedAt, s.last!.time);
    });

    test('점이 하나도 없어도 종료할 수 있다', () {
      final r = TrackSession(startedAt: t0).finish();
      expect(r.distanceM, 0);
      expect(r.encodedPolyline, '');
      expect(r.candidates, isEmpty);
      expect(r.endedAt, t0);
    });
  });
}
