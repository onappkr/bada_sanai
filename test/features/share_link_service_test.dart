import 'package:bada_sanai/features/share/data/share_link_codec.dart';
import 'package:bada_sanai/features/share/domain/share_link_service.dart';
import 'package:bada_sanai/features/share/domain/shared_point.dart';
import 'package:bada_sanai/core/db/app_database.dart' show Genre;
import 'package:test/test.dart';

void main() {
  const service = ShareLinkService('https://example.test/p');
  const point = SharedPoint(
    name: '영도 방파제 끝',
    lat: 35.0779,
    lng: 129.0868,
    genre: Genre.lure,
    memo: '새벽 만조 전후로 농어가 붙는다.',
  );

  test('링크를 만들고 다시 읽으면 같은 포인트', () {
    final link = service.buildLink(point);
    expect(link.toString().startsWith('https://example.test/p#v=1&d='), isTrue);
    final back = service.parse(link.toString());
    expect(back.name, point.name);
    expect(back.lat, point.lat);
    expect(back.lng, point.lng);
    expect(back.genre, Genre.lure);
    expect(back.memo, point.memo);
  });

  test('메모·장르가 없으면 키를 싣지 않는다', () {
    const bare = SharedPoint(name: 'a', lat: 1, lng: 2);
    expect(bare.toJson().keys, containsAll(['n', 'la', 'ln']));
    expect(bare.toJson().containsKey('m'), isFalse);
    expect(bare.toJson().containsKey('g'), isFalse);
  });

  test('문자 메시지에 섞인 링크에서도 읽는다', () {
    final link = service.buildLink(point);
    final message = service.messageFor(point, link);
    expect(service.parse(message).name, point.name);
    expect(service.parse('  $link 입니다.\n감사합니다').name, point.name);
  });

  test('# 뒤 조각만 붙여 넣어도 읽는다', () {
    final fragment = service.buildLink(point).fragment;
    expect(service.parse(fragment).name, point.name);
    expect(service.parse('#$fragment').name, point.name);
  });

  test('링크가 아니면 FormatException', () {
    expect(() => service.parse('안녕하세요'), throwsFormatException);
    expect(() => service.parse('https://example.test/p'), throwsFormatException);
    expect(() => service.parse('https://example.test/p#v=1&d='), throwsFormatException);
    expect(() => service.parse('https://example.test/p#v=2&d=abc'),
        throwsFormatException);
  });

  group('받은 데이터 검증', () {
    Map<String, dynamic> j([Map<String, dynamic>? over]) =>
        {'n': '곳', 'la': 35.0, 'ln': 129.0, ...?over};

    test('범위를 벗어난 좌표·빈 이름은 거부', () {
      expect(() => SharedPoint.fromJson(j({'la': 91})), throwsFormatException);
      expect(() => SharedPoint.fromJson(j({'ln': -181})), throwsFormatException);
      expect(() => SharedPoint.fromJson(j({'n': '  '})), throwsFormatException);
      expect(() => SharedPoint.fromJson(j({'la': '35'})), throwsFormatException);
      expect(() => SharedPoint.fromJson(j({'n': 'x' * 101})), throwsFormatException);
    });

    test('모르는 장르는 무시하고 정수 좌표도 받는다', () {
      final p = SharedPoint.fromJson(j({'g': 'jetski', 'la': 35}));
      expect(p.genre, isNull);
      expect(p.lat, 35.0);
    });
  });

  group('지문(중복 방지)', () {
    test('같은 링크는 같은 지문, 다른 링크는 다른 지문', () {
      final a = service.buildLink(point).fragment;
      final b = service.buildLink(
          const SharedPoint(name: '다른 곳', lat: 35, lng: 129)).fragment;
      expect(ShareLinkService.fingerprint(a), ShareLinkService.fingerprint(a));
      expect(ShareLinkService.fingerprint(a), isNot(ShareLinkService.fingerprint(b)));
    });

    test('공유 도메인이 달라도 데이터가 같으면 같은 지문', () {
      final a = const ShareLinkService('https://a.test/p').buildLink(point).fragment;
      final b = const ShareLinkService('https://b.test/p').buildLink(point).fragment;
      expect(ShareLinkService.fingerprint(a), ShareLinkService.fingerprint(b));
    });
  });

  test('링크 길이는 문자 메시지로 보내기에 무리가 없다', () {
    final link = service.buildLink(point).toString();
    expect(link.length, lessThan(300));
    // 코덱 자체의 왕복도 확인
    expect(ShareLinkCodec.decodeFragment(Uri.parse(link).fragment)['n'], point.name);
  });
}
