/// 어종 코드 → 표시 이름. 1차 데이터 파일(species)이 붙기 전까지 쓰는 임시 목록.
const Map<String, String> speciesNames = {
  'seabass': '농어',
  'flatfish': '광어',
  'rockfish': '우럭',
  'greenling': '쥐노래미',
  'mackerel': '고등어',
  'horse_mackerel': '전갱이',
  'squid': '오징어',
  'webfoot_octopus': '쭈꾸미',
  'file_fish': '쥐치',
  'sea_bream': '참돔',
  'amberjack': '부시리',
  'korean_bullhead': '볼락',
  'other': '기타',
};

String speciesLabel(String code) => speciesNames[code] ?? code;
