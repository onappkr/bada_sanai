#!/usr/bin/env python3
"""빌드 로그에서 실패 원인을 골라 GitHub Actions 주석(::error)으로 남긴다.

Actions 로그는 로그인 없이 내려받을 수 없지만 주석은 공개 API로 읽을 수 있어서,
빌드가 실패했을 때 원인을 확인하기 위해 쓴다.

사용법: python3 tool/ci_annotate_log.py build.log "주석 제목"
"""
import sys

TAIL_LINES = 30
MAX_CHARS = 1500


def escape(text: str) -> str:
    return text.replace('%', '%25').replace('\r', '%0D').replace('\n', '%0A')


def main(path: str, title: str) -> int:
    with open(path, encoding='utf-8', errors='replace') as f:
        lines = [l.rstrip('\n') for l in f]

    # Gradle은 "What went wrong:" 아래에 원인을 적는다. 있으면 그 블록을 먼저 보여 준다.
    went_wrong: list[str] = []
    for i, line in enumerate(lines):
        if 'What went wrong' in line:
            went_wrong = lines[i:i + 10]
            break

    parts: list[str] = []
    if went_wrong:
        parts.append('[원인]\n' + '\n'.join(went_wrong))
    # 그 밖의 오류 줄(컴파일 오류, 환경 오류 등)
    hints = [l for l in lines if 'error:' in l.lower() or 'Error:' in l or 'FAILURE:' in l]
    if hints:
        parts.append('[오류 줄]\n' + '\n'.join(hints[:8]))
    parts.append('[로그 끝]\n' + '\n'.join(lines[-TAIL_LINES:]))

    body = '\n\n'.join(parts)[:MAX_CHARS]
    print(f'::error title={escape(title)}::{escape(body)}')
    return 0


if __name__ == '__main__':
    if len(sys.argv) < 3:
        sys.exit(2)
    sys.exit(main(sys.argv[1], sys.argv[2]))
