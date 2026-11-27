import 'dart:async';

import 'package:app_links/app_links.dart';

/// 앱 링크(https://도메인/p#...)로 앱이 열릴 때 그 주소를 알려 주는 창구.
abstract interface class DeepLinkService {
  /// 앱이 이 링크로 처음 실행됐다면 그 주소, 아니면 null.
  Future<Uri?> initial();

  /// 앱이 이미 켜져 있는 동안 들어오는 링크.
  Stream<Uri> get stream;
}

/// app_links 기반 구현.
class AppLinksDeepLinkService implements DeepLinkService {
  AppLinksDeepLinkService([AppLinks? links]) : _links = links ?? AppLinks();

  final AppLinks _links;

  @override
  Future<Uri?> initial() async {
    try {
      return await _links.getInitialLink();
    } catch (_) {
      return null; // 지원하지 않는 환경(웹·데스크톱 등)
    }
  }

  @override
  Stream<Uri> get stream => _links.uriLinkStream;
}

/// 링크를 받지 않는 환경(미리보기·테스트)용.
class NoDeepLinkService implements DeepLinkService {
  const NoDeepLinkService();

  @override
  Future<Uri?> initial() async => null;

  @override
  Stream<Uri> get stream => const Stream.empty();
}
