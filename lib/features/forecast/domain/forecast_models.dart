/// 물때·날씨·수온 통일 응답 모델(설계 문서 5장). 값을 모르면 해당 필드는 null이고
/// 화면에서 "정보 없음"으로 표시한다. JSON 키는 문서의 형식을 따른다.
library;

enum TideType { high, low }

class TideExtreme {
  const TideExtreme({required this.time, required this.type, required this.heightCm});

  final DateTime time;
  final TideType type;
  final int heightCm;

  Map<String, dynamic> toJson() => {
        'time': time.toIso8601String(),
        'type': type.name,
        'height_cm': heightCm,
      };

  factory TideExtreme.fromJson(Map<String, dynamic> j) => TideExtreme(
        time: DateTime.parse(j['time'] as String),
        type: TideType.values.byName(j['type'] as String),
        heightCm: (j['height_cm'] as num).toInt(),
      );
}

class TideInfo {
  const TideInfo({this.mulddae, this.extremes = const []});

  /// 물때 숫자(보통 1~15). 원천이 주지 않으면 null.
  final int? mulddae;

  /// 만조·간조 시각과 높이, 시간 순.
  final List<TideExtreme> extremes;

  Map<String, dynamic> toJson() => {
        'mulddae': mulddae,
        'extremes': [for (final e in extremes) e.toJson()],
      };

  factory TideInfo.fromJson(Map<String, dynamic> j) => TideInfo(
        mulddae: (j['mulddae'] as num?)?.toInt(),
        extremes: [
          for (final e in (j['extremes'] as List? ?? const []))
            TideExtreme.fromJson(e as Map<String, dynamic>),
        ],
      );
}

class WeatherInfo {
  const WeatherInfo({
    this.tempC,
    this.windDirDeg,
    this.windMps,
    this.waveM,
    this.sky,
    this.precipMm,
  });

  final double? tempC;
  final int? windDirDeg;
  final double? windMps;
  final double? waveM;

  /// `clear`, `cloudy`, `overcast`, `rain` 같은 하늘 상태 코드. 값의 종류는 원천에 맞춰 정한다.
  final String? sky;
  final double? precipMm;

  Map<String, dynamic> toJson() => {
        'temp_c': tempC,
        'wind_dir_deg': windDirDeg,
        'wind_mps': windMps,
        'wave_m': waveM,
        'sky': sky,
        'precip_mm': precipMm,
      };

  factory WeatherInfo.fromJson(Map<String, dynamic> j) => WeatherInfo(
        tempC: (j['temp_c'] as num?)?.toDouble(),
        windDirDeg: (j['wind_dir_deg'] as num?)?.toInt(),
        windMps: (j['wind_mps'] as num?)?.toDouble(),
        waveM: (j['wave_m'] as num?)?.toDouble(),
        sky: j['sky'] as String?,
        precipMm: (j['precip_mm'] as num?)?.toDouble(),
      );
}

/// 한 해역·하루치 예보. 물때(tide)·날씨(weather)·수온(seaTempC)은 각각 따로 가져오므로
/// 일부만 있을 수 있다.
class ForecastBundle {
  const ForecastBundle({
    required this.regionCode,
    required this.date,
    required this.fetchedAt,
    required this.stale,
    this.tide,
    this.weather,
    this.seaTempC,
  });

  final String regionCode;

  /// `2026-11-27` 형식.
  final String date;

  /// 쓰인 값 중 가장 오래된 갱신 시각(UTC). 화면의 "마지막 갱신 시각"이다.
  final DateTime fetchedAt;

  /// 새로 가져오지 못해 만료된 캐시를 섞어 썼으면 true.
  final bool stale;

  final TideInfo? tide;
  final WeatherInfo? weather;
  final double? seaTempC;

  Map<String, dynamic> toJson() => {
        'region_code': regionCode,
        'date': date,
        'fetched_at': fetchedAt.toUtc().toIso8601String(),
        'stale': stale,
        'tide': tide?.toJson(),
        'weather': weather?.toJson(),
        'sea_temp_c': seaTempC,
      };

  factory ForecastBundle.fromJson(Map<String, dynamic> j) => ForecastBundle(
        regionCode: j['region_code'] as String,
        date: j['date'] as String,
        fetchedAt: DateTime.parse(j['fetched_at'] as String),
        stale: j['stale'] as bool? ?? false,
        tide: j['tide'] == null ? null : TideInfo.fromJson(j['tide'] as Map<String, dynamic>),
        weather:
            j['weather'] == null ? null : WeatherInfo.fromJson(j['weather'] as Map<String, dynamic>),
        seaTempC: (j['sea_temp_c'] as num?)?.toDouble(),
      );
}

/// 날짜를 `2026-11-27` 형식으로(로컬 날짜 기준).
String forecastDateKey(DateTime d) {
  final l = d.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${l.year}-${two(l.month)}-${two(l.day)}';
}

/// 풍향(도)을 8방위 한글로. 0도 = 북풍(북쪽에서 불어옴). 범위를 벗어난 값도 0~359로 맞춰 읽는다.
String windDirectionLabel(int deg) {
  const names = ['북', '북동', '동', '남동', '남', '남서', '서', '북서'];
  final index = (((deg % 360 + 360) % 360) / 45).round() % 8;
  return '${names[index]}풍';
}
