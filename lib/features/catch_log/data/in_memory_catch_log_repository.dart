import 'dart:async';

import '../domain/catch_log_models.dart';
import '../domain/catch_log_repository.dart';

/// 메모리 저장소. 화면 미리보기·위젯 테스트용이며 앱을 끄면 데이터가 사라진다.
class InMemoryCatchLogRepository implements CatchLogRepository {
  final Map<String, CatchLogView> _store = {};
  final _changes = StreamController<void>.broadcast();
  int _seq = 0;

  List<CatchLogView> _all(Genre? genre, String? pointId) {
    final list = _store.values
        .where((e) => genre == null || e.genre == genre)
        .where((e) => pointId == null || e.pointId == pointId)
        .toList()
      ..sort((a, b) => b.fishedAt.compareTo(a.fishedAt));
    return list;
  }

  @override
  Stream<List<CatchLogView>> watchAll({Genre? genre, String? pointId}) async* {
    yield _all(genre, pointId);
    await for (final _ in _changes.stream) {
      yield _all(genre, pointId);
    }
  }

  @override
  Stream<CatchLogView?> watchOne(String id) async* {
    yield _store[id];
    await for (final _ in _changes.stream) {
      yield _store[id];
    }
  }

  CatchLogView _build(String id, CatchLogInput i) => CatchLogView(
        id: id,
        genre: i.genre,
        fishedAt: i.fishedAt,
        pointId: i.pointId,
        memo: (i.memo?.trim().isEmpty ?? true) ? null : i.memo!.trim(),
        genreDetail: {
          for (final e in i.genreDetail.entries)
            if (e.value.trim().isNotEmpty) e.key: e.value.trim(),
        },
        items: i.items,
      );

  @override
  Future<String> create(CatchLogInput input) async {
    final id = 'mem-${++_seq}';
    _store[id] = _build(id, input);
    _changes.add(null);
    return id;
  }

  @override
  Future<void> update(String id, CatchLogInput input) async {
    if (!_store.containsKey(id)) throw StateError('일지를 찾을 수 없습니다: $id');
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
