import 'package:bada_sanai/features/share/data/share_link_codec.dart';
import 'package:bada_sanai/features/team/domain/split_calculator.dart';
import 'package:test/test.dart';

void main() {
  group('computeEqualSplit', () {
    test('나머지는 지정한 사람이 부담', () {
      final r = computeEqualSplit(
          total: 100000, participants: ['a', 'b', 'c'], remainderBearer: 'b');
      expect(r, {'a': 33333, 'b': 33334, 'c': 33333});
      expect(r.values.reduce((x, y) => x + y), 100000);
    });

    test('나누어떨어지면 동일', () {
      final r = computeEqualSplit(
          total: 90000, participants: ['a', 'b', 'c'], remainderBearer: 'a');
      expect(r.values.toSet(), {30000});
    });

    test('잘못된 입력은 예외', () {
      expect(
          () => computeEqualSplit(
              total: 1, participants: [], remainderBearer: 'a'),
          throwsArgumentError);
      expect(
          () => computeEqualSplit(
              total: 1, participants: ['a'], remainderBearer: 'x'),
          throwsArgumentError);
      expect(
          () => computeEqualSplit(
              total: -1, participants: ['a'], remainderBearer: 'a'),
          throwsArgumentError);
    });
  });

  group('buildTransfers', () {
    test('송금 후 모든 잔액이 0', () {
      final balances = {'a': 50000, 'b': -20000, 'c': -30000, 'd': 0};
      final transfers = buildTransfers(balances);
      final after = Map.of(balances);
      for (final t in transfers) {
        after[t.from] = after[t.from]! + t.amount;
        after[t.to] = after[t.to]! - t.amount;
      }
      expect(after.values.every((v) => v == 0), isTrue);
      expect(transfers.length, 2);
    });

    test('합계가 0이 아니면 예외', () {
      expect(() => buildTransfers({'a': 10, 'b': -5}), throwsArgumentError);
    });
  });

  group('ShareLinkCodec', () {
    test('왕복 변환', () {
      final payload = {
        'name': '부산 앞바다 포인트',
        'pts': [
          {'lat': 35.1, 'lng': 129.0}
        ],
      };
      final fragment = ShareLinkCodec.encodeFragment(payload);
      expect(fragment.split('&d=').last.contains('='), isFalse);
      expect(ShareLinkCodec.decodeFragment('#$fragment'), payload);
    });

    test('버전 불일치·데이터 없음은 예외', () {
      expect(() => ShareLinkCodec.decodeFragment('v=9&d=xx'),
          throwsFormatException);
      expect(() => ShareLinkCodec.decodeFragment('v=1'), throwsFormatException);
    });
  });
}
