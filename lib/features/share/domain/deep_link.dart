/// 앱으로 들어온 링크가 공유 포인트 링크이면 `v=1&d=...` 조각을 돌려주고, 아니면 null.
///
/// 지원하는 모양:
/// - `https://도메인/p#v=1&d=...` (설계의 기본 형식. 데이터는 # 뒤에 있어 서버로 가지 않는다)
/// - `https://도메인/p?v=1&d=...` (OS가 # 뒤를 앱에 넘기지 않을 때의 대비책. 이때 데이터가 서버 로그에 남는다)
///
/// [allowedHosts]를 주면 그 도메인의 링크만 받는다(주지 않으면 도메인은 가리지 않는다).
/// 경로는 `/p`여야 한다.
String? sharedPointFragment(Uri uri, {Set<String>? allowedHosts}) {
  if (uri.scheme != 'https' && uri.scheme != 'http') return null;
  if (allowedHosts != null && !allowedHosts.contains(uri.host)) return null;
  if (uri.path != '/p' && uri.path != '/p/') return null;

  String? pick(Map<String, String> params) {
    final d = params['d'];
    if (d == null || d.isEmpty) return null;
    return 'v=${params['v'] ?? '1'}&d=$d';
  }

  // 조각(#)을 먼저 보고, 없으면 쿼리를 본다.
  if (uri.fragment.isNotEmpty) {
    try {
      final fromFragment = pick(Uri.splitQueryString(uri.fragment));
      if (fromFragment != null) return fromFragment;
    } on FormatException {
      // 조각이 쿼리 형식이 아니면 쿼리를 본다.
    }
  }
  return pick(uri.queryParameters);
}
