import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/painting.dart';

import '../domain/photo_models.dart';
import '../domain/photo_ports.dart';

/// 메모리 사진 저장소. 화면 미리보기·테스트용.
class InMemoryPhotoStore implements PhotoStore {
  final Map<String, Uint8List> files = {};
  int _seq = 0;

  @override
  Future<String> save(PickedPhoto photo) async {
    final path = 'mem/${++_seq}';
    files[path] = photo.bytes;
    return path;
  }

  @override
  Future<void> delete(String path) async => files.remove(path);

  @override
  ImageProvider imageFor(String path) => MemoryImage(files[path]!);
}

class InMemoryPhotoRepository implements PhotoRepository {
  final List<({String id, OwnerType type, String ownerId, String path})> _rows = [];
  final _changes = StreamController<void>.broadcast();
  int _seq = 0;

  List<PhotoView> _of(OwnerType type, String ownerId) => [
        for (final r in _rows)
          if (r.type == type && r.ownerId == ownerId)
            PhotoView(id: r.id, filePath: r.path),
      ];

  @override
  Stream<List<PhotoView>> watchByOwner(OwnerType type, String ownerId) async* {
    yield _of(type, ownerId);
    await for (final _ in _changes.stream) {
      yield _of(type, ownerId);
    }
  }

  @override
  Future<List<String>> replaceForOwner(
    OwnerType type,
    String ownerId, {
    required Set<String> keep,
    required List<String> addPaths,
  }) async {
    final removed = _rows
        .where((r) => r.type == type && r.ownerId == ownerId && !keep.contains(r.id))
        .toList();
    _rows.removeWhere(removed.contains);
    for (final path in addPaths) {
      _rows.add((id: 'ph-${++_seq}', type: type, ownerId: ownerId, path: path));
    }
    _changes.add(null);
    return [for (final r in removed) r.path];
  }
}
