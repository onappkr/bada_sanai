#!/usr/bin/env python3
"""flutter test의 JSON 보고서를 읽어 실패한 테스트를 GitHub Actions 주석(::error)으로 남긴다.

주석은 Actions 로그에 로그인하지 않아도 공개 API(check-runs/.../annotations)로 읽을 수 있어서,
로그를 내려받기 어려운 환경에서도 실패한 테스트의 이름과 오류를 확인할 수 있다.

사용법: python3 tool/ci_annotate_tests.py test_report.json
"""
import json
import sys

MAX_ANNOTATIONS = 10  # GitHub은 한 단계에 오류 주석을 10개까지만 보여 준다.
MAX_MESSAGE_CHARS = 600


def escape(text: str) -> str:
    """워크플로 명령의 값에 쓸 수 있게 이스케이프한다."""
    return text.replace('%', '%25').replace('\r', '%0D').replace('\n', '%0A')


def main(path: str) -> int:
    names: dict[int, str] = {}
    paths: dict[int, str] = {}
    suites: dict[int, str] = {}
    errors: list[tuple[str, str, str]] = []
    passed = failed = skipped = 0

    with open(path, encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line.startswith('{'):
                continue
            try:
                e = json.loads(line)
            except json.JSONDecodeError:
                continue
            kind = e.get('type')
            if kind == 'suite':
                suites[e['suite']['id']] = e['suite'].get('path', '')
            elif kind == 'testStart':
                t = e['test']
                names[t['id']] = t['name']
                paths[t['id']] = suites.get(t.get('suiteID'), '') or t.get('url') or ''
            elif kind == 'testDone':
                if e.get('hidden'):
                    continue
                if e.get('skipped'):
                    skipped += 1
                elif e.get('result') == 'success':
                    passed += 1
                else:
                    failed += 1
            elif kind == 'error':
                tid = e.get('testID')
                errors.append((names.get(tid, f'test#{tid}'), paths.get(tid, ''), str(e.get('error', ''))))

    print(f'테스트 결과: 통과 {passed}, 실패 {failed}, 건너뜀 {skipped}, 오류 기록 {len(errors)}건')
    for i, (name, file, message) in enumerate(errors[:MAX_ANNOTATIONS]):
        body = message.strip()[:MAX_MESSAGE_CHARS]
        loc = f' file={file}' if file else ''
        print(f'::error{loc},title={escape("테스트 실패: " + name[:100])}::{escape(body)}')
    if len(errors) > MAX_ANNOTATIONS:
        print(f'::warning::오류가 {len(errors)}건이라 앞의 {MAX_ANNOTATIONS}건만 주석으로 남겼습니다.')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1]) if len(sys.argv) > 1 else 2)
