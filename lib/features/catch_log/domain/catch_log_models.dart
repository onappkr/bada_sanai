import '../../../core/db/app_database.dart' show Genre;
import 'log_environment.dart';

export '../../../core/db/app_database.dart' show Genre;

extension GenreLabel on Genre {
  String get label => switch (this) {
        Genre.lure => '루어',
        Genre.cast => '원투',
        Genre.jjik => '찍낚시',
        Genre.boat => '보트',
      };

  /// 장르별 입력 항목(genre_detail JSON의 키 이름과 안내 문구).
  List<GenreField> get fields => switch (this) {
        Genre.lure => const [
            GenreField('lure', '루어 종류·색상'),
            GenreField('rod', '로드·릴'),
          ],
        Genre.cast => const [
            GenreField('bait', '미끼'),
            GenreField('sinker', '봉돌 호수'),
          ],
        Genre.jjik => const [
            GenreField('rig', '채비'),
            GenreField('depth', '수심(m)'),
          ],
        Genre.boat => const [
            GenreField('boatName', '선박·선장'),
            GenreField('rig', '채비'),
          ],
      };
}

class GenreField {
  const GenreField(this.key, this.label);
  final String key;
  final String label;
}

/// 조과 1건(어종·크기·마릿수).
class CatchItemInput {
  const CatchItemInput({
    required this.speciesCode,
    this.lengthCm,
    this.count = 1,
    this.memo,
  });

  final String speciesCode;
  final double? lengthCm;
  final int count;
  final String? memo;
}

/// 일지 작성·수정 입력.
class CatchLogInput {
  const CatchLogInput({
    required this.genre,
    required this.fishedAt,
    this.pointId,
    this.memo,
    this.genreDetail = const {},
    this.items = const [],
    this.environment,
  });

  final Genre genre;
  final DateTime fishedAt;
  final String? pointId;
  final String? memo;

  /// 장르별 항목. 값이 비어 있는 키는 저장하지 않는다.
  final Map<String, String> genreDetail;
  final List<CatchItemInput> items;

  /// 일지를 쓸 때 자동으로 붙인 환경(위치·물때·날씨·수온).
  /// 수정할 때 null이면 이미 저장된 환경을 그대로 둔다.
  final LogEnvironment? environment;
}

/// 조회용 일지.
class CatchLogView {
  const CatchLogView({
    required this.id,
    required this.genre,
    required this.fishedAt,
    required this.genreDetail,
    required this.items,
    this.pointId,
    this.memo,
    this.environment,
  });

  final String id;
  final Genre genre;
  final DateTime fishedAt;
  final String? pointId;
  final String? memo;
  final Map<String, String> genreDetail;
  final List<CatchItemInput> items;

  /// 기록할 때 자동으로 붙은 환경. 붙은 것이 없으면 null.
  final LogEnvironment? environment;

  int get totalCount => items.fold(0, (a, b) => a + b.count);

  CatchLogInput toInput() => CatchLogInput(
        genre: genre,
        fishedAt: fishedAt,
        pointId: pointId,
        memo: memo,
        genreDetail: genreDetail,
        items: items,
        environment: environment,
      );
}
