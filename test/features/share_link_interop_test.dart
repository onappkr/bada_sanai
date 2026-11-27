import 'dart:convert';
import 'dart:io';

import 'package:bada_sanai/features/share/data/share_link_codec.dart';
import 'package:test/test.dart';

/// 순수 Dart 압축(archive)과 표준 raw deflate(dart:io zlib)가 서로 읽히는지 확인한다.
/// 웹 뷰어(브라우저 DecompressionStream)가 같은 표준을 쓰므로 호환의 근거가 된다.
void main() {
  final payload = {'n': '영도 방파제 끝', 'la': 35.0779, 'ln': 129.0868, 'm': '메모 ' * 40};

  test('archive로 만든 링크를 표준 zlib이 푼다', () {
    final d = Uri.splitQueryString(ShareLinkCodec.encodeFragment(payload))['d']!;
    final bytes = base64Url.decode(d.padRight((d.length + 3) ~/ 4 * 4, '='));
    final json = utf8.decode(ZLibCodec(raw: true).decode(bytes));
    expect(jsonDecode(json), payload);
  });

  test('표준 zlib으로 만든 링크를 읽는다', () {
    final raw = ZLibCodec(raw: true, level: 9).encode(utf8.encode(jsonEncode(payload)));
    final d = base64Url.encode(raw).replaceAll('=', '');
    expect(ShareLinkCodec.decodeFragment('v=1&d=$d'), payload);
  });

  test('깨진 데이터는 FormatException', () {
    expect(() => ShareLinkCodec.decodeFragment('v=1&d=AAAA'), throwsFormatException);
    expect(() => ShareLinkCodec.decodeFragment('v=1&d=!!!'), throwsFormatException);
  });
}
