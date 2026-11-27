import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../domain/photo_models.dart';
import '../domain/photo_ports.dart';

/// 앱 문서 폴더의 `photos/` 아래에 파일로 저장한다. DB에는 상대 경로만 남기므로
/// 앱 폴더 위치가 바뀌어도(백업 복원 등) 경로가 깨지지 않는다.
class FilePhotoStore implements PhotoStore {
  FilePhotoStore({
    Future<Directory> Function()? rootProvider,
    this._uuid = const Uuid(),
  }) : _rootProvider = rootProvider ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _rootProvider;
  final Uuid _uuid;
  Directory? _root;

  /// 동기 접근(imageFor)을 위해 [save]/[prepare] 이후에만 쓸 수 있다.
  Future<Directory> prepare() async => _root ??= await _rootProvider();

  @override
  Future<String> save(PickedPhoto photo) async {
    final root = await prepare();
    final ext = _extension(photo.name);
    final rel = p.posix.join('photos', '${_uuid.v4()}$ext');
    final file = File(p.join(root.path, rel));
    await file.parent.create(recursive: true);
    await file.writeAsBytes(photo.bytes, flush: true);
    return rel;
  }

  @override
  Future<void> delete(String path) async {
    final root = await prepare();
    final file = File(p.join(root.path, path));
    if (await file.exists()) await file.delete();
  }

  @override
  ImageProvider imageFor(String path) {
    final root = _root;
    if (root == null) throw StateError('prepare()를 먼저 호출해야 합니다');
    return FileImage(File(p.join(root.path, path)));
  }

  static String _extension(String name) {
    final ext = p.extension(name).toLowerCase();
    return const {'.jpg', '.jpeg', '.png', '.webp', '.heic'}.contains(ext)
        ? ext
        : '.jpg';
  }
}
