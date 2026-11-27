import 'dart:typed_data';

import 'package:bada_sanai/core/db/app_database.dart';
import 'package:bada_sanai/features/photo/application/photo_providers.dart';
import 'package:bada_sanai/features/photo/data/drift_photo_repository.dart';
import 'package:bada_sanai/features/photo/data/in_memory_photo.dart';
import 'package:bada_sanai/features/photo/domain/photo_models.dart';
import 'package:bada_sanai/features/photo/domain/photo_ports.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

PickedPhoto photo(String name) =>
    PickedPhoto(name: name, bytes: Uint8List.fromList([1, 2, 3]));

const owner = (type: OwnerType.log, id: 'log1');

/// 저장소·보관소 계약 테스트. 메모리 구현은 즉시, Drift 구현은 SQLite가 되는 환경에서 돈다.
void contract(String label, PhotoRepository Function() repo) {
  group(label, () {
    late InMemoryPhotoStore store;
    setUp(() => store = InMemoryPhotoStore());

    Future<List<PhotoView>> current() =>
        repo().watchByOwner(owner.type, owner.id).first;

    test('새 사진을 저장하면 파일과 행이 생긴다', () async {
      await persistPhotos(
          repo: repo(), store: store, owner: owner, keepIds: {}, picked: [photo('a.jpg'), photo('b.png')]);
      expect((await current()).length, 2);
      expect(store.files.length, 2);
    });

    test('유지 목록에 없는 사진은 행과 파일이 함께 지워진다', () async {
      await persistPhotos(
          repo: repo(), store: store, owner: owner, keepIds: {}, picked: [photo('a.jpg'), photo('b.jpg')]);
      final before = await current();
      await persistPhotos(
          repo: repo(), store: store, owner: owner, keepIds: {before.first.id}, picked: []);
      final after = await current();
      expect(after.map((e) => e.id), [before.first.id]);
      expect(store.files.keys, [before.first.filePath]);
    });

    test('다른 소유자의 사진은 건드리지 않는다', () async {
      await persistPhotos(
          repo: repo(), store: store, owner: owner, keepIds: {}, picked: [photo('a.jpg')]);
      await persistPhotos(
          repo: repo(),
          store: store,
          owner: (type: OwnerType.log, id: 'other'),
          keepIds: {},
          picked: []);
      expect((await current()).length, 1);
    });
  });
}

void main() {
  final mem = InMemoryPhotoRepository();
  contract('메모리 저장소', () => mem);

  late AppDatabase db;
  late DriftPhotoRepository drift;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    drift = DriftPhotoRepository(db);
  });
  tearDown(() => db.close());
  contract('Drift 저장소', () => drift);
}
