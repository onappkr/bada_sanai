import 'package:bada_sanai/core/db/app_database.dart';
import 'package:bada_sanai/features/catch_log/data/drift_catch_log_repository.dart';
import 'package:bada_sanai/features/catch_log/domain/catch_log_models.dart';
import 'package:bada_sanai/features/photo/data/drift_photo_repository.dart';
import 'package:bada_sanai/features/point/data/drift_point_repository.dart';
import 'package:bada_sanai/features/point/domain/point_models.dart';
import 'package:bada_sanai/features/settings/data/drift_data_eraser.dart';
import 'package:bada_sanai/features/settings/data/settings_repositories.dart';
import 'package:bada_sanai/features/settings/domain/settings_repository.dart';
import 'package:bada_sanai/features/team/data/drift_team_repository.dart';
import 'package:bada_sanai/features/team/domain/team_models.dart';
import 'package:bada_sanai/features/tracking/data/drift_track_repository.dart';
import 'package:bada_sanai/features/tracking/domain/track_logic.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

/// SQLite가 되는 환경(CI 등)에서 도는 테스트. 모든 테이블이 비워지는지 확인한다.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('모든 기록이 지워지고 앱 설정은 남는다', () async {
    final t0 = DateTime.utc(2026, 11, 27, 6);
    final points = DriftPointRepository(db);
    final logs = DriftCatchLogRepository(db);
    final tracks = DriftTrackRepository(db);
    final photos = DriftPhotoRepository(db);

    final pointId = await points.create(const PointInput(name: '곳', lat: 35, lng: 129));
    final logId = await logs.create(CatchLogInput(
      genre: Genre.lure,
      fishedAt: t0,
      pointId: pointId,
      items: const [CatchItemInput(speciesCode: 'seabass')],
    ));
    await photos.replaceForOwner(OwnerType.log, logId, keep: {}, addPaths: ['photos/a.jpg']);
    final trackId = await tracks.start(t0);
    await tracks.addSample(trackId, LocationSample(lat: 35, lng: 129, time: t0));
    await tracks.finish(
      trackId,
      TrackResult(
        startedAt: t0,
        endedAt: t0.add(const Duration(minutes: 11)),
        distanceM: 0,
        encodedPolyline: '',
        candidates: const [CandidateDraft(lat: 35, lng: 129, dwell: Duration(minutes: 11))],
      ),
    );
    final teams = DriftTeamRepository(db);
    final teamId = await teams.createTeam('팀');
    final memberId = await teams.addMember(teamId, '철수');
    final tripId = await teams.createTrip(
        teamId, TripInput(title: '출조', date: t0, participantIds: [memberId]));
    await teams.addExpense(
        tripId,
        ExpenseInput(description: '밥', amount: 1000, payerId: memberId, targetIds: [memberId]));
    await DriftSettingsRepository(db).markOnboardingDone();

    await DriftDataEraser(db).eraseAll();

    expect(await db.select(db.points).get(), isEmpty);
    expect(await db.select(db.catchLogs).get(), isEmpty);
    expect(await db.select(db.catchItems).get(), isEmpty);
    expect(await db.select(db.photos).get(), isEmpty);
    expect(await db.select(db.tracks).get(), isEmpty);
    expect(await db.select(db.trackPoints).get(), isEmpty);
    expect(await db.select(db.pointCandidates).get(), isEmpty);
    expect(await db.select(db.shareImports).get(), isEmpty);
    expect(await db.select(db.teams).get(), isEmpty);
    expect(await db.select(db.teamMembers).get(), isEmpty);
    expect(await db.select(db.trips).get(), isEmpty);
    expect(await db.select(db.tripExpenses).get(), isEmpty);
    expect(await db.select(db.forecastCache).get(), isEmpty);
    // 설정은 사용자 기록이 아니므로 남긴다.
    expect(await DriftSettingsRepository(db).isOnboardingDone(), isTrue);
  });

  test('빈 DB에서도 문제없이 지운다', () async {
    await DriftDataEraser(db).eraseAll();
    expect(await db.select(db.points).get(), isEmpty);
  });
}
