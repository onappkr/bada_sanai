import 'package:bada_sanai/core/db/app_database.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:test/test.dart';

import 'generated_migrations/schema.dart';

/// 기기에 이미 있는 DB가 앱 업데이트 뒤에도 그대로 열리는지 지키는 시험(SQLite가 되는 환경에서 돈다).
///
/// `drift_schemas/`의 스키마 파일은 출시한 버전의 DB 모양이다. 테이블을 고치면서
/// schemaVersion을 올리지 않으면 이 시험(과 CI의 스냅샷 검사)이 실패한다. 스키마를 바꿀 때는 다음 순서로 한다.
///   1) `AppDatabase.schemaVersion`을 올린다.
///   2) `dart run drift_dev schema dump lib/core/db/app_database.dart drift_schemas/`
///   3) `dart run drift_dev schema steps drift_schemas/ lib/core/db/schema_versions.dart`
///   4) `dart run drift_dev schema generate drift_schemas/ test/generated_migrations/`
///   5) `schema_versions.dart`의 from(N)To(N+1) 단계를 채우고, 아래 [latest]를 올리고,
///      이전 버전 DB에서 이행하는 시험을 더한다(`verifier.schemaAt(이전버전)` → `migrateAndValidate`).
const latest = 2;

void main() {
  late SchemaVerifier verifier;
  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('앱 코드의 schemaVersion이 마지막으로 기록된 스키마 버전과 같다', () {
    expect(AppDatabase(NativeDatabase.memory()).schemaVersion, latest);
  });

  test('기록된 스키마의 DB를 현재 앱 코드가 그대로 연다', () async {
    final schema = await verifier.schemaAt(latest);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, latest);
    await db.close();
  });

  test('새로 설치한 DB(onCreate)의 모양이 코드의 스키마와 같다(인덱스 포함)', () async {
    final db = AppDatabase(NativeDatabase.memory());
    await db.validateDatabaseSchema();
    await db.close();
  });

  test('v1 DB를 v2로 올리면 기존 기록은 그대로이고 팀 테이블이 생긴다', () async {
    final schema = await verifier.schemaAt(1);
    // v1 모양 그대로의 DB에 포인트 한 건을 직접 넣어 둔다.
    schema.rawDatabase.execute(
      "INSERT INTO points (id, name, lat, lng, source, created_at, updated_at) "
      "VALUES ('p1', '방파제', 35.0, 129.0, 'manual', 0, 0)",
    );
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 2);
    expect(await db.select(db.points).get(), hasLength(1));
    expect(await db.select(db.teams).get(), isEmpty);
    await db.close();
  });
}
