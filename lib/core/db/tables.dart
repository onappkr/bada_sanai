import 'package:drift/drift.dart';

/// 모든 기본키는 UUID 문자열, 시각은 UTC (Drift DateTime → epoch 초 저장).
/// 2차 동기화를 위해 주요 테이블에 updatedAt/deletedAt을 둔다.

enum Genre { lure, cast, jjik, boat }

enum PointSource { auto, manual, shared }

enum TrackStatus { recording, saved, discarded }

enum CandidateStatus { pending, saved, discarded }

enum OwnerType { log, point }

@DataClassName('CatchLog')
class CatchLogs extends Table {
  TextColumn get id => text()();
  TextColumn get genre => textEnum<Genre>()();
  DateTimeColumn get fishedAt => dateTime()();
  TextColumn get pointId => text().nullable().references(Points, #id)();
  RealColumn get lat => real().nullable()();
  RealColumn get lng => real().nullable()();
  TextColumn get memo => text().nullable()();

  /// 장르별 항목(JSON 문자열). 장르 추가 시 스키마 변경을 피한다.
  TextColumn get genreDetail => text().withDefault(const Constant('{}'))();

  /// 물때·수온·날씨 스냅샷(JSON 문자열).
  TextColumn get env => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CatchItem')
class CatchItems extends Table {
  TextColumn get id => text()();
  TextColumn get logId =>
      text().references(CatchLogs, #id, onDelete: KeyAction.cascade)();
  TextColumn get speciesCode => text()();
  RealColumn get lengthCm => real().nullable()();
  IntColumn get count => integer().withDefault(const Constant(1))();
  TextColumn get memo => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Photo')
class Photos extends Table {
  TextColumn get id => text()();
  TextColumn get ownerType => textEnum<OwnerType>()();
  TextColumn get ownerId => text()();

  /// 앱 저장소 내 파일 경로(상대 경로 권장).
  TextColumn get filePath => text()();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Point')
class Points extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  TextColumn get genre => textEnum<Genre>().nullable()();
  TextColumn get memo => text().nullable()();
  TextColumn get source => textEnum<PointSource>()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Track')
class Tracks extends Table {
  TextColumn get id => text()();
  TextColumn get pointId => text().nullable().references(Points, #id)();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  RealColumn get distanceM => real().withDefault(const Constant(0))();

  /// 저장 후 단순화된 폴리라인 1개만 남긴다.
  TextColumn get encodedPolyline => text().nullable()();
  TextColumn get status => textEnum<TrackStatus>()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 기록 중 임시 버퍼. 저장 완료 시 단순화되어 Tracks로 옮겨지고 삭제된다.
@DataClassName('TrackPoint')
class TrackPoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get trackId =>
      text().references(Tracks, #id, onDelete: KeyAction.cascade)();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  RealColumn get accuracyM => real().nullable()();
  RealColumn get speedMps => real().nullable()();
  DateTimeColumn get recordedAt => dateTime()();
}

@DataClassName('PointCandidate')
class PointCandidates extends Table {
  TextColumn get id => text()();
  TextColumn get trackId =>
      text().references(Tracks, #id, onDelete: KeyAction.cascade)();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  IntColumn get dwellSec => integer()();
  TextColumn get status => textEnum<CandidateStatus>()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ForecastCacheEntry')
class ForecastCache extends Table {
  /// 해역코드+날짜+종류.
  TextColumn get key => text()();
  TextColumn get payload => text()();
  DateTimeColumn get fetchedAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

@DataClassName('ShareImport')
class ShareImports extends Table {
  TextColumn get id => text()();
  TextColumn get pointId => text().references(Points, #id)();

  /// 같은 링크를 여러 번 열어도 중복 저장하지 않기 위한 해시(UNIQUE).
  TextColumn get payloadHash => text().unique()();
  DateTimeColumn get importedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AppSetting')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
