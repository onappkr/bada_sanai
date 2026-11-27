import 'dart:io';
import 'dart:math';

import 'package:bada_sanai/features/team/domain/settlement.dart';
import 'package:bada_sanai/features/team/domain/split_calculator.dart';
import 'package:test/test.dart';

Expense exp(String id, int amount, String payer, List<String> targets) =>
    Expense(id: id, amount: amount, payerId: payer, targets: targets);

/// 송금을 적용했을 때 모든 사람의 순액이 0이 되는지(계획서 시나리오 10).
void expectTransfersClear(Map<String, int> net, List<Transfer> transfers) {
  final after = Map.of(net);
  for (final t in transfers) {
    after[t.from] = after[t.from]! + t.amount;
    after[t.to] = after[t.to]! - t.amount;
  }
  expect(after.values.every((v) => v == 0), isTrue, reason: '$net -> $transfers');
}

void main() {
  group('공유 테스트 벡터(CSV): 서버의 compute_splits와 같은 입력으로 같은 결과', () {
    final lines = File('test/fixtures/split_vectors.csv')
        .readAsLinesSync()
        .where((l) => l.trim().isNotEmpty && !l.startsWith('#'));
    for (final line in lines) {
      final cols = line.split(',');
      final amount = int.parse(cols[0]);
      final targets = cols[1].split(' ');
      final bearer = cols[2];
      final expected = {
        for (final kv in cols[3].split(' '))
          kv.split('=')[0]: int.parse(kv.split('=')[1]),
      };
      test('$amount원 / ${targets.length}명 / 끝전 $bearer', () {
        expect(computeSplits(amount, targets, bearer), expected);
      });
    }
  });

  group('분담 계산', () {
    test('대상자 입력 순서와 무관하게 같은 결과', () {
      final a = computeSplits(100000, ['c', 'a', 'b'], 'b');
      final b = computeSplits(100000, ['a', 'b', 'c'], 'b');
      expect(a, b);
    });

    test('무작위 입력(금액 1~1,000,000 × 인원 1~12): 합계가 항상 금액과 같다', () {
      final rnd = Random(20261127);
      for (var i = 0; i < 2000; i++) {
        final amount = 1 + rnd.nextInt(1000000);
        final n = 1 + rnd.nextInt(12);
        final ids = [for (var k = 0; k < n; k++) 'u${k.toString().padLeft(2, '0')}'];
        final bearer = ids[rnd.nextInt(n)];
        final r = computeSplits(amount, ids, bearer);

        expect(r.values.fold<int>(0, (a, b) => a + b), amount, reason: '$amount / $n');
        final base = amount ~/ n;
        final remainder = amount - base * n;
        for (final e in r.entries) {
          expect(e.value, e.key == bearer ? base + remainder : base);
        }
      }
    });
  });

  group('끝전 부담자', () {
    test('결제자 규칙: 결제자가 대상자면 결제자', () {
      expect(
          remainderBearer(RemainderRule.payer,
              payerId: 'b', treasurerId: 'a', targets: ['c', 'b', 'a']),
          'b');
    });

    test('총무 규칙: 총무가 대상자면 총무', () {
      expect(
          remainderBearer(RemainderRule.treasurer,
              payerId: 'b', treasurerId: 'c', targets: ['a', 'b', 'c']),
          'c');
    });

    test('규칙이 가리키는 사람이 대상자가 아니면 id 순 첫 번째', () {
      expect(
          remainderBearer(RemainderRule.payer,
              payerId: 'z', treasurerId: 'a', targets: ['c', 'b']),
          'b');
      expect(
          remainderBearer(RemainderRule.treasurer,
              payerId: 'a', treasurerId: null, targets: ['c', 'b']),
          'b');
    });
  });

  group('송금 계산', () {
    test('순서에 무관하게 같은 결과(동액은 id 순)', () {
      final t1 = buildTransfers({'a': 100, 'b': -50, 'c': -50});
      final t2 = buildTransfers({'c': -50, 'b': -50, 'a': 100});
      expect(t1, t2);
      expect(t1, [
        const Transfer(from: 'b', to: 'a', amount: 50),
        const Transfer(from: 'c', to: 'a', amount: 50),
      ]);
    });

    test('남은 금액이 가장 큰 사람을 매번 다시 골라 건수를 줄인다', () {
      // 한 번만 정렬하면 a가 d에게 받고 남은 40을 e보다 먼저 갚게 되는 경우가 있다.
      final net = {'a': 60, 'b': 40, 'c': -70, 'd': -30};
      final t = buildTransfers(net);
      expectTransfersClear(net, t);
      expect(t.length, lessThanOrEqualTo(3));
      expect(t.first, const Transfer(from: 'c', to: 'a', amount: 60));
    });

    test('무작위 순액: 송금 후 모두 0이고 건수는 인원−1 이하', () {
      final rnd = Random(7);
      for (var i = 0; i < 1000; i++) {
        final n = 2 + rnd.nextInt(11);
        final net = <String, int>{};
        var sum = 0;
        for (var k = 0; k < n - 1; k++) {
          final v = rnd.nextInt(200001) - 100000;
          net['u${k.toString().padLeft(2, '0')}'] = v;
          sum += v;
        }
        net['u${(n - 1).toString().padLeft(2, '0')}'] = -sum;

        final t = buildTransfers(net);
        expectTransfersClear(net, t);
        expect(t.length, lessThanOrEqualTo(n - 1), reason: '$net');
        expect(t.every((x) => x.amount > 0 && x.from != x.to), isTrue);
      }
    });

    test('순액이 모두 0이면 송금 없음', () {
      expect(buildTransfers({'a': 0, 'b': 0}), isEmpty);
    });
  });

  group('settle', () {
    const members = ['a', 'b', 'c'];

    test('한 사람이 모두를 위해 결제: 나머지가 그 사람에게 송금', () {
      final r = settle(
        expenses: [exp('e1', 90000, 'a', ['a', 'b', 'c'])],
        memberIds: members,
      );
      expect(r.total, 90000);
      final byId = {for (final i in r.items) i.userId: i};
      expect(byId['a']!.shareTotal, 30000);
      expect(byId['a']!.paidTotal, 90000);
      expect(byId['a']!.net, 60000);
      expect(byId['b']!.net, -30000);
      expect(r.transfers, [
        const Transfer(from: 'b', to: 'a', amount: 30000),
        const Transfer(from: 'c', to: 'a', amount: 30000),
      ]);
    });

    test('특정 인원만 나누는 비용과 전원 비용을 섞는다', () {
      final r = settle(
        expenses: [
          exp('boat', 120000, 'a', ['a', 'b', 'c']), // 40000씩
          exp('bait', 10000, 'b', ['a', 'b']), // 5000씩
        ],
        memberIds: members,
      );
      final byId = {for (final i in r.items) i.userId: i};
      expect(byId['a']!.shareTotal, 45000);
      expect(byId['b']!.shareTotal, 45000);
      expect(byId['c']!.shareTotal, 40000);
      expect(byId['a']!.net, 75000); // 120000 결제 − 45000
      expect(byId['b']!.net, -35000); // 10000 결제 − 45000
      expect(byId['c']!.net, -40000);
      expect(r.items.fold<int>(0, (s, i) => s + i.net), 0);
    });

    test('끝전은 규칙에 따라 결제자 또는 총무가 부담한다', () {
      final e = [exp('e', 100000, 'b', ['a', 'b', 'c'])];
      final payer = settle(expenses: e, memberIds: members);
      expect({for (final i in payer.items) i.userId: i.shareTotal},
          {'a': 33333, 'b': 33334, 'c': 33333});

      final treasurer = settle(
          expenses: e,
          memberIds: members,
          rule: RemainderRule.treasurer,
          treasurerId: 'c');
      expect({for (final i in treasurer.items) i.userId: i.shareTotal},
          {'a': 33333, 'b': 33333, 'c': 33334});
    });

    test('아무도 돈을 내지 않은 참여자는 부담 0으로 항목에 들어간다', () {
      final r = settle(
        expenses: [exp('e', 1000, 'a', ['a', 'b'])],
        memberIds: members,
      );
      final c = r.items.firstWhere((i) => i.userId == 'c');
      expect((c.shareTotal, c.paidTotal, c.net), (0, 0, 0));
    });

    test('무작위 정산: 부담 합계 = 총액, 순액 합계 = 0, 송금 후 모두 0, 건수 ≤ 인원−1', () {
      final rnd = Random(99);
      for (var i = 0; i < 500; i++) {
        final n = 2 + rnd.nextInt(10);
        final ids = [for (var k = 0; k < n; k++) 'u${k.toString().padLeft(2, '0')}'];
        final expenses = [
          for (var k = 0; k < 1 + rnd.nextInt(8); k++)
            exp(
              'e$k',
              1 + rnd.nextInt(500000),
              ids[rnd.nextInt(n)],
              (([...ids]..shuffle(rnd)).take(1 + rnd.nextInt(n))).toList(),
            ),
        ];
        final r = settle(
          expenses: expenses,
          memberIds: ids,
          rule: rnd.nextBool() ? RemainderRule.payer : RemainderRule.treasurer,
          treasurerId: ids[rnd.nextInt(n)],
        );
        expect(r.total, expenses.fold<int>(0, (s, e) => s + e.amount));
        expect(r.items.fold<int>(0, (s, x) => s + x.shareTotal), r.total);
        expect(r.items.fold<int>(0, (s, x) => s + x.net), 0);
        expectTransfersClear({for (final x in r.items) x.userId: x.net}, r.transfers);
        expect(r.transfers.length, lessThanOrEqualTo(n - 1));
      }
    });

    group('오류 코드', () {
      void expectCode(void Function() f, String code) {
        expect(
          f,
          throwsA(isA<SettlementError>().having((e) => e.code, 'code', code)),
        );
      }

      test('비용이 없으면 NO_EXPENSES', () {
        expectCode(() => settle(expenses: [], memberIds: members), 'NO_EXPENSES');
      });

      test('금액이 1 미만이면 INVALID_AMOUNT', () {
        expectCode(
            () => settle(expenses: [exp('e', 0, 'a', ['a'])], memberIds: members),
            'INVALID_AMOUNT');
        expectCode(
            () => settle(expenses: [exp('e', -5, 'a', ['a'])], memberIds: members),
            'INVALID_AMOUNT');
      });

      test('대상자가 없으면 NO_TARGETS', () {
        expectCode(
            () => settle(expenses: [exp('e', 100, 'a', [])], memberIds: members),
            'NO_TARGETS');
      });

      test('결제자나 대상자가 참여자가 아니면 NOT_PARTICIPANT', () {
        expectCode(
            () => settle(expenses: [exp('e', 100, 'z', ['a'])], memberIds: members),
            'NOT_PARTICIPANT');
        expectCode(
            () => settle(expenses: [exp('e', 100, 'a', ['a', 'z'])], memberIds: members),
            'NOT_PARTICIPANT');
      });

      test('대상자가 중복되면 NOT_PARTICIPANT', () {
        expectCode(
            () => settle(expenses: [exp('e', 100, 'a', ['a', 'a'])], memberIds: members),
            'NOT_PARTICIPANT');
      });
    });
  });
}
