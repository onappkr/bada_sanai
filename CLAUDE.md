# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 작업 규칙

- 새로운 기능을 작업할 때는 항상 `develop`에서 새 브랜치를 만들어 작업하고, 완료 후 `develop` 브랜치에 머지한다.

## 개요

"바다 사나이": 루어·원투·찍낚시·보트 낚시 기록 앱(Flutter, Android/iOS). 1차는 서버 없이 기기 안(SQLite)에서만 동작한다. 일지, 포인트, 사진, 경로 기록, 포인트 공유 링크, 백업·복원, 이 시기 내 어종이 구현되어 있다. 팀·정산(2차)과 데이터 기반 추천(3차)은 설계만 있고 코드는 순수 로직(`features/team/domain/split_calculator.dart`)뿐이다. `web_viewer/`는 앱이 없는 사람이 공유 링크를 여는 정적 페이지다.

## 명령

```bash
flutter pub get
flutter analyze
dart test test/features/xxx_test.dart     # 순수 Dart 테스트(빠름, SQLite·Flutter 불필요)
flutter test                              # 전체(위젯·Drift 저장소 테스트 포함)
dart run build_runner build               # Drift 생성 코드(app_database.g.dart) 갱신 — 테이블을 고친 뒤 필수
cd web_viewer && node --test              # 웹 뷰어 해독 로직 테스트
flutter build web -t lib/main_preview.dart   # 화면 미리보기(아래 참고)
```

- CI(`.github/workflows/ci.yml`)는 생성 코드 최신 여부, `flutter analyze`, `flutter test`, 웹 뷰어 node 테스트를 돈다. 생성 코드(`app_database.g.dart`)는 커밋 대상이다.
- 테스트 파일은 두 종류다. **순수 로직**(`package:test`만 import, `dart test`로 실행)과 **Flutter·SQLite가 필요한 것**(Drift 저장소 `NativeDatabase.memory()`, `widget_test.dart`). 후자는 `flutter test`나 CI에서만 돈다. 순수 테스트가 `package:flutter*`를 import하면 `dart test`로 못 돌리니, 로직은 프레임워크 없는 파일에 두고 테스트한다.
- **Windows 개발 PC 주의**: 스마트 앱 컨트롤이 서명 없는 실행 파일을 막는 환경이면 `flutter test`, `build_runner`(AOT), SQLite 네이티브 라이브러리가 막힌다. `dart run build_runner build --force-jit`는 우회가 된다. 막힌 테스트는 CI에서 확인한다.

## 구조

기능별 폴더(`lib/features/<기능>/`) 안에 계층을 둔다: `domain`(순수 Dart 모델·규칙·저장소 인터페이스) ← `data`(Drift 등 구현) / `application`(Riverpod provider) / `presentation`(화면). 화면은 인터페이스에만 의존하고 구현은 provider에서 주입한다.

- `core/db`: Drift 스키마(`tables.dart`)와 `AppDatabase`. 모든 키는 UUID 문자열, 주요 테이블에 `updatedAt`/`deletedAt`을 두어 삭제는 표시만 한다(2차 동기화 대비). 시각은 UTC로 저장하고 화면에서 로컬로 바꾼다.
- `core/geo`: 좌표 거리, Douglas-Peucker 단순화, Encoded Polyline. `core/config`: 빌드 때 `--dart-define`으로 바꾸는 값(`SHARE_BASE_URL`).
- `app/`: `go_router` 설정(`app_router.dart`), 경로 상수(`routes.dart`, 화면 ID S01~S18은 주석), 첫 실행 온보딩 리다이렉트(순수 함수 `onboarding_redirect.dart`). 탭 4개(홈·일지·지도·설정)는 `StatefulShellRoute`.
- 저장소 인터페이스마다 **Drift 구현과 메모리 구현** 두 가지가 있다. 메모리 구현은 미리보기·테스트용이다.
- `main.dart`가 시작할 때 사진 폴더와 온보딩 완료 여부를 먼저 읽어 provider를 덮어쓴다(라우터와 이미지 표시가 동기 접근을 필요로 해서).
- 경로 기록: `tracking/domain/track_logic.dart`(점 걸러내기·수집 주기·머문 자리 후보, 순수) → `track_recorder.dart`(세션 진행, 프레임워크 없음) → `application`의 `TrackingController`(앱 전체에서 하나, 화면을 벗어나도 기록 유지). 위치 원천은 `LocationSource` 인터페이스(`GeolocatorLocationSource`).
- 공유 링크: `share/data/share_link_codec.dart`(JSON → raw deflate → base64url, `#v=1&d=...`)는 `web_viewer/codec.js`와 **같은 형식**이어야 한다. 형식을 바꾸면 `v`를 올리고 양쪽을 함께 고친다. 압축은 웹에서도 돌도록 `dart:io` 대신 `archive` 패키지를 쓴다.
- 사진: DB에는 상대 경로만, 파일은 앱 문서 폴더 `photos/`. 작성 화면에서 고른 사진은 저장 버튼을 누를 때에야 파일로 기록한다.

## 화면 미리보기

실기기·에뮬레이터 없이 화면을 보려면 `lib/main_preview.dart`(메모리 저장소와 샘플 데이터, 가짜 위치·권한·백업)를 웹으로 빌드해 정적 서버로 연다. 기본은 온보딩을 건너뛰고, 온보딩부터 보려면 `--dart-define=PREVIEW_ONBOARDING=true`. 파일 선택창·실제 GPS·권한 창은 미리보기로 확인할 수 없다. 브라우저의 서비스 워커 캐시 때문에 새 빌드가 안 보이면 캐시를 지우고 다시 연다.

## 아직 없는 것(결정·자료 필요)

지도 SDK 선정, 물때·날씨(S14)와 지역별 어종 추천(외부 API 키·어종 데이터), 해안 도착 자동 감지(해안선 데이터), 앱 링크 자동 열기(공유 도메인), 카카오톡 공유(카카오 앱 키), 앱 ID·서명. 계획 문서는 Claude Docs "바다 사나이 앱 개발 계획서" 탭들.
