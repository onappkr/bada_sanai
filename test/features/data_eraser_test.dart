import 'package:bada_sanai/features/settings/domain/data_eraser.dart';
import 'package:test/test.dart';

class _FakeEraser implements DataEraser {
  _FakeEraser.logging(this.log, {this.fail = false});

  final bool fail;
  final List<String> log;

  @override
  Future<void> eraseAll() async {
    log.add('db');
    if (fail) throw StateError('디스크 오류');
  }
}

void main() {
  test('기록을 먼저 지우고 사진 파일을 지운다', () async {
    final log = <String>[];
    final r = await eraseAllUserData(
      eraser: _FakeEraser.logging(log),
      deletePhotoFiles: () async => log.add('files'),
    );
    expect(log, ['db', 'files']);
    expect(r.complete, isTrue);
  });

  test('기록 삭제가 실패하면 예외를 던지고 사진 파일은 건드리지 않는다', () async {
    final log = <String>[];
    await expectLater(
      eraseAllUserData(
        eraser: _FakeEraser.logging(log, fail: true),
        deletePhotoFiles: () async => log.add('files'),
      ),
      throwsStateError,
    );
    expect(log, ['db']);
  });

  test('기록은 지웠는데 파일 삭제가 실패하면 예외 대신 결과로 알린다', () async {
    final log = <String>[];
    final r = await eraseAllUserData(
      eraser: _FakeEraser.logging(log),
      deletePhotoFiles: () async => throw const FormatException('권한 없음'),
    );
    expect(log, ['db']);
    expect(r.complete, isFalse);
    expect(r.photoFilesError, isA<FormatException>());
  });
}
