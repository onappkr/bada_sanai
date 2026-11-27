import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catch_log/application/catch_log_providers.dart' show databaseProvider;
import '../data/drift_photo_repository.dart';
import '../data/file_photo_store.dart';
import '../data/image_picker_photo_picker.dart';
import '../domain/photo_models.dart';
import '../domain/photo_ports.dart';

final photoRepositoryProvider = Provider<PhotoRepository>(
  (ref) => DriftPhotoRepository(ref.watch(databaseProvider)),
);

final photoStoreProvider = Provider<PhotoStore>((ref) => FilePhotoStore());

final photoPickerProvider =
    Provider<PhotoPicker>((ref) => ImagePickerPhotoPicker());

typedef PhotoOwner = ({OwnerType type, String id});

final photosByOwnerProvider = StreamProvider.autoDispose
    .family<List<PhotoView>, PhotoOwner>((ref, owner) {
  return ref.watch(photoRepositoryProvider).watchByOwner(owner.type, owner.id);
});

/// 새로 고른 사진을 파일로 저장하고 DB에 반영한다. 지워진 사진 파일도 정리한다.
Future<void> persistPhotos({
  required PhotoRepository repo,
  required PhotoStore store,
  required PhotoOwner owner,
  required Set<String> keepIds,
  required List<PickedPhoto> picked,
}) async {
  final paths = <String>[];
  try {
    for (final p in picked) {
      paths.add(await store.save(p));
    }
    final removed = await repo.replaceForOwner(
      owner.type,
      owner.id,
      keep: keepIds,
      addPaths: paths,
    );
    for (final path in removed) {
      await store.delete(path);
    }
  } catch (_) {
    // DB 반영이 실패하면 방금 쓴 파일이 고아가 되지 않게 지운다.
    for (final path in paths) {
      await store.delete(path);
    }
    rethrow;
  }
}
