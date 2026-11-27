import 'dart:async';

import '../domain/point_models.dart';
import '../domain/point_repository.dart';

/// 메모리 저장소. 화면 미리보기·위젯 테스트용.
class InMemoryPointRepository implements PointRepository {
  final Map<String, PointView> _store = {};
  final _changes = StreamController<void>.broadcast();
  int _seq = 0;

  List<PointView> _all() =>
      _store.values.toList()..sort((a, b) => a.name.compareTo(b.name));

  @override
  Stream<List<PointView>> watchAll() async* {
    yield _all();
    await for (final _ in _changes.stream) {
      yield _all();
    }
  }

  @override
  Stream<PointView?> watchOne(String id) async* {
    yield _store[id];
    await for (final _ in _changes.stream) {
      yield _store[id];
    }
  }

  PointView _build(String id, PointInput i) {
    final err = validatePointInput(name: i.name, lat: i.lat, lng: i.lng);
    if (err != null) throw ArgumentError(err);
    final memo = i.memo?.trim();
    return PointView(
      id: id,
      name: i.name.trim(),
      lat: i.lat,
      lng: i.lng,
      genre: i.genre,
      memo: (memo == null || memo.isEmpty) ? null : memo,
      source: i.source,
    );
  }

  @override
  Future<String> create(PointInput input) async {
    final id = 'pt-${++_seq}';
    _store[id] = _build(id, input);
    _changes.add(null);
    return id;
  }

  @override
  Future<void> update(String id, PointInput input) async {
    if (!_store.containsKey(id)) throw StateError('포인트를 찾을 수 없습니다: $id');
    _store[id] = _build(id, input);
    _changes.add(null);
  }

  /// 미리보기·테스트용: 모두 지운다.
  void clear() {
    _store.clear();
    _changes.add(null);
  }

  @override
  Future<void> delete(String id) async {
    _store.remove(id);
    _changes.add(null);
  }
}
