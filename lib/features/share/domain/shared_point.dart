import '../../../core/db/app_database.dart' show Genre;

/// 공유 링크로 주고받는 포인트 정보. 사진·방문 이력은 포함하지 않는다.
class SharedPoint {
  const SharedPoint({
    required this.name,
    required this.lat,
    required this.lng,
    this.genre,
    this.memo,
  });

  final String name;
  final double lat;
  final double lng;
  final Genre? genre;
  final String? memo;

  /// 링크 길이를 줄이려고 키를 짧게 쓴다.
  Map<String, dynamic> toJson() => {
        'n': name,
        'la': lat,
        'ln': lng,
        if (genre != null) 'g': genre!.name,
        if (memo != null) 'm': memo,
      };

  /// 받은 데이터는 믿지 않고 검증한다. 문제가 있으면 [FormatException].
  factory SharedPoint.fromJson(Map<String, dynamic> json) {
    final name = json['n'];
    final lat = json['la'];
    final lng = json['ln'];
    if (name is! String || name.trim().isEmpty) {
      throw const FormatException('포인트 이름이 없습니다');
    }
    if (name.length > 100) throw const FormatException('포인트 이름이 너무 깁니다');
    if (lat is! num || lat < -90 || lat > 90) {
      throw const FormatException('위도가 올바르지 않습니다');
    }
    if (lng is! num || lng < -180 || lng > 180) {
      throw const FormatException('경도가 올바르지 않습니다');
    }
    final memo = json['m'];
    if (memo != null && (memo is! String || memo.length > 2000)) {
      throw const FormatException('메모가 올바르지 않습니다');
    }
    final g = json['g'];
    Genre? genre;
    if (g != null) {
      genre = Genre.values.where((e) => e.name == g).firstOrNull;
      // 앞으로 장르가 늘어도 옛 앱이 깨지지 않게, 모르는 장르는 무시한다.
    }
    return SharedPoint(
      name: name.trim(),
      lat: lat.toDouble(),
      lng: lng.toDouble(),
      genre: genre,
      memo: memo as String?,
    );
  }
}
