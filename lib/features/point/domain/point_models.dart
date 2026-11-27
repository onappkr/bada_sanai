import '../../../core/db/app_database.dart' show Genre, PointSource;

export '../../../core/db/app_database.dart' show Genre, PointSource;
export '../../catch_log/domain/catch_log_models.dart' show GenreLabel;

extension PointSourceLabel on PointSource {
  String get label => switch (this) {
        PointSource.auto => '자동 저장',
        PointSource.manual => '직접 등록',
        PointSource.shared => '공유 받음',
      };
}

/// 포인트 입력값 검증. 문제가 없으면 null, 있으면 사용자에게 보일 메시지.
String? validatePointInput({
  required String name,
  required double? lat,
  required double? lng,
}) {
  if (name.trim().isEmpty) return '이름을 입력해 주세요.';
  if (lat == null || lat < -90 || lat > 90) return '위도는 -90 ~ 90 사이 숫자여야 합니다.';
  if (lng == null || lng < -180 || lng > 180) {
    return '경도는 -180 ~ 180 사이 숫자여야 합니다.';
  }
  return null;
}

class PointInput {
  const PointInput({
    required this.name,
    required this.lat,
    required this.lng,
    this.genre,
    this.memo,
    this.source = PointSource.manual,
  });

  final String name;
  final double lat;
  final double lng;
  final Genre? genre;
  final String? memo;
  final PointSource source;
}

class PointView {
  const PointView({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.source,
    this.genre,
    this.memo,
  });

  final String id;
  final String name;
  final double lat;
  final double lng;
  final Genre? genre;
  final String? memo;
  final PointSource source;

  PointInput toInput() => PointInput(
        name: name,
        lat: lat,
        lng: lng,
        genre: genre,
        memo: memo,
        source: source,
      );
}
