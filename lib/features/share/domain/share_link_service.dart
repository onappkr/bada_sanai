import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../data/share_link_codec.dart';
import 'shared_point.dart';

/// 포인트 ↔ 공유 링크 변환. 데이터는 URL fragment에 담겨 서버로 가지 않는다.
class ShareLinkService {
  const ShareLinkService(this.baseUrl);

  final String baseUrl;

  /// `{baseUrl}#v=1&d=...`
  Uri buildLink(SharedPoint point) {
    final fragment = ShareLinkCodec.encodeFragment(point.toJson());
    return Uri.parse('$baseUrl#$fragment');
  }

  /// 전체 링크, `#` 뒤 조각, 링크가 섞인 문자 메시지 모두 받는다.
  /// 읽을 수 없으면 [FormatException].
  SharedPoint parse(String input) {
    final fragment = extractFragment(input);
    return SharedPoint.fromJson(ShareLinkCodec.decodeFragment(fragment));
  }

  /// 입력에서 `v=...&d=...` 조각만 뽑는다.
  static String extractFragment(String input) {
    final text = input.trim();
    final hash = text.indexOf('#');
    var f = hash >= 0 ? text.substring(hash + 1) : text;
    // 문자 메시지에 링크 뒤로 문장이 이어져도 공백·줄바꿈에서 끊는다.
    f = f.split(RegExp(r'\s')).first;
    if (!f.contains('v=') || !f.contains('d=')) {
      throw const FormatException('공유 링크가 아닙니다');
    }
    return f;
  }

  /// 같은 링크를 여러 번 열어도 한 번만 저장하기 위한 지문(데이터 부분의 SHA-256).
  static String fingerprint(String fragment) {
    final d = Uri.splitQueryString(fragment)['d'] ?? fragment;
    return sha256.convert(utf8.encode(d)).toString();
  }

  /// 카카오톡·문자로 보낼 본문.
  String messageFor(SharedPoint point, Uri link) =>
      '[바다 사나이] ${point.name} 포인트를 공유합니다.\n$link\n앱이 없어도 링크에서 위치를 볼 수 있어요.';
}
