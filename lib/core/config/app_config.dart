/// 공유 링크의 기준 주소. 도메인이 정해지면 빌드 때
/// `--dart-define=SHARE_BASE_URL=https://실제도메인/p` 로 바꾼다.
/// 기본값은 예약된 example 도메인이라 실제로는 열리지 않는다.
const shareBaseUrl = String.fromEnvironment(
  'SHARE_BASE_URL',
  defaultValue: 'https://bada-sanai.example/p',
);

/// 기상청 단기예보(공공데이터포털) 서비스 키. 코드에 넣지 않고 빌드 때
/// `--dart-define=KMA_SERVICE_KEY=발급받은키` 로 넘긴다. 공공데이터포털의 "일반 인증키(Decoding)"를 쓴다(Encoding 키는 이중 인코딩된다). 비어 있으면 날씨 연동은 "준비 중"으로 보인다.
const kmaServiceKey = String.fromEnvironment('KMA_SERVICE_KEY');
