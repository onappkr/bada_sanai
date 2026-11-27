import 'dart:convert';
import 'package:archive/archive.dart';

/// 공유 링크 v1: `https://{domain}/p#v=1&d={base64url(deflate(json))}`
/// 데이터는 URL fragment에 담겨 서버로 전송되지 않는다.
/// 압축은 순수 Dart 구현(archive)이라 웹에서도 동작하고, 형식은 raw deflate(RFC 1951)라
/// 웹 뷰어의 브라우저 `DecompressionStream('deflate-raw')`로도 풀 수 있다.
class ShareLinkCodec {
  const ShareLinkCodec._();

  static const int version = 1;

  static String encodeFragment(Map<String, dynamic> payload) {
    final raw = utf8.encode(jsonEncode(payload));
    final deflated =
        Deflate(raw, level: DeflateLevel.bestCompression).getBytes();
    final d = base64Url.encode(deflated).replaceAll('=', '');
    return 'v=$version&d=$d';
  }

  static Map<String, dynamic> decodeFragment(String fragment) {
    final f = fragment.startsWith('#') ? fragment.substring(1) : fragment;
    final params = Uri.splitQueryString(f);
    final v = int.tryParse(params['v'] ?? '');
    if (v != version) {
      throw FormatException('지원하지 않는 공유 링크 버전: ${params['v']}');
    }
    final d = params['d'];
    if (d == null || d.isEmpty) throw const FormatException('데이터가 없습니다');
    final padded = d.padRight((d.length + 3) ~/ 4 * 4, '=');
    final List<int> inflated;
    try {
      inflated = Inflate(base64Url.decode(padded), throwOnError: true).getBytes();
    } on Object {
      throw const FormatException('압축을 풀 수 없습니다');
    }
    final decoded = jsonDecode(utf8.decode(inflated));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('잘못된 데이터 형식');
    }
    return decoded;
  }
}
