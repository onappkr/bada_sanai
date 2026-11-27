# 앱에 포함하는 데이터 파일

현재 `species_rule.json`, `region.json`, `coast_cells.json`은 **비어 있습니다**(`version: 0`). 실제 어종·해역 데이터는
전문가 감수가 필요한 값이라 코드가 만들어 넣지 않았습니다. 이 두 파일을 실제 데이터로 바꾸기만 하면
앱의 "이 해역 추천"(어종 화면)이 나타납니다. 앱 코드는 고칠 필요가 없습니다.

## species_rule.json

```json
{
  "version": 3,
  "species": [ {"code": "SP-001", "name_ko": "어종A", "image": "sp-001.webp"} ],
  "rules": [
    {
      "species": "SP-001",
      "regions": ["S-012", "S-013"],
      "months": [5, 6, 7, 8, 9, 10],
      "peak_months": [7, 8, 9],
      "genres": ["lure", "cast"],
      "note": "참고용 설명 한 줄"
    }
  ]
}
```

- 점수: 달이 `peak_months`에 있으면 2점, `months`에만 있으면 1점, 그 밖은 추천하지 않습니다.
- `genres`에는 `lure`, `cast`, `jjik`, `boat` 중 해당하는 것을 넣습니다.
- 규칙의 `species`는 같은 파일의 `species`에 정의된 코드여야 합니다(아니면 파일 전체를 읽지 못합니다).
- 파일을 읽지 못하면 앱은 빈 데이터로 동작합니다(추천 화면만 숨겨집니다).

## region.json

```json
{
  "version": 1,
  "regions": [
    {
      "code": "S-012",
      "name_ko": "해역명",
      "center": {"lat": 35.0, "lng": 129.0},
      "grid": {"nx": 0, "ny": 0},
      "tide_station_id": "관측소 ID",
      "sea_temp_station_id": "관측소 ID"
    }
  ]
}
```

- 현재 위치에서 가장 가까운 `center`의 해역을 쓰며, 150km보다 멀면 "이 위치는 데이터가 없는 바다"로 봅니다.
- `grid`, `tide_station_id`, `sea_temp_station_id`는 물때·날씨 기능(D1)에서 쓰며 지금은 읽기만 합니다.

## coast_cells.json

도착 감지(해안에 들어와 3분 머물면 "도착")에 쓰는 해안 셀입니다.

```json
{
  "version": 1,
  "cell_radius_m": 100,
  "cells": [[34.880, 128.620], [34.881, 128.622]]
}
```

- `cells`는 `[위도, 경도]` 목록이고, 각 점에서 `cell_radius_m`(미터) 안이면 그 셀에 들어온 것으로 봅니다.
- 해안선 전체를 OS 지오펜스로 등록할 수 없어서(동시에 등록 가능한 수 제한) 현재 위치에서 가까운 셀 몇 개만
  등록하는 용도입니다. 셀 데이터는 공공 해안선 데이터에서 만들어야 하며 변환 도구는 아직 없습니다.
- 도착 판단 기준값(3분 체류, 같은 구역 6시간 재알림 금지 등)은 `lib/features/arrival/domain/arrival_detector.dart`의
  `ArrivalConfig`에 있고, 해안 현장 테스트 후 조정합니다.
