import 'dart:convert';
import 'dart:io';

/// 공유 링크 v1: `https://{domain}/p#v=1&d={base64url(deflate(json))}`
/// 데이터는 URL fragment에 담겨 서버로 전송되지 않는다.
class ShareLinkCodec {
  const ShareLinkCodec._();

  static const int version = 1;

  static String encodeFragment(Map<String, dynamic> payload) {
    final raw = utf8.encode(jsonEncode(payload));
    final deflated = ZLibCodec(raw: true, level: 9).encode(raw);
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
    final inflated = ZLibCodec(raw: true).decode(base64Url.decode(padded));
    final decoded = jsonDecode(utf8.decode(inflated));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('잘못된 데이터 형식');
    }
    return decoded;
  }
}
