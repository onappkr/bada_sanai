/// 공유 링크의 기준 주소. 도메인이 정해지면 빌드 때
/// `--dart-define=SHARE_BASE_URL=https://실제도메인/p` 로 바꾼다.
/// 기본값은 예약된 example 도메인이라 실제로는 열리지 않는다.
const shareBaseUrl = String.fromEnvironment(
  'SHARE_BASE_URL',
  defaultValue: 'https://bada-sanai.example/p',
);
