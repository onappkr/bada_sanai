#!/usr/bin/env python3
"""해안선 GeoJSON을 앱의 해안 셀 파일(assets/data/coast_cells.json)로 바꾼다.

도착 감지는 해안선 전체를 OS 지오펜스로 등록할 수 없어서(동시에 등록 가능한 수 제한) 해안을
일정 간격의 점(셀)으로 나눠 들고 있다가 현재 위치 주변의 셀만 쓴다. 이 도구가 그 점을 만든다.

입력: GeoJSON(WGS84, 좌표 순서는 [경도, 위도]). LineString, MultiLineString, Polygon,
      MultiPolygon과 이들을 담은 Feature·FeatureCollection·GeometryCollection을 읽는다.
출력: {"version": N, "cell_radius_m": R, "cells": [[위도, 경도], ...]}

사용법:
  python tool/make_coast_cells.py 해안선.geojson -o assets/data/coast_cells.json \\
      --spacing 150 --radius 100 --version 1

해안선 원본은 공공 데이터(국토지리정보원, 해양수산부 등)에서 내려받아야 하며, 이용 조건과
좌표계(WGS84가 아니면 먼저 변환)를 직접 확인해야 한다. 이 도구는 데이터를 만들어 내지 않는다.
"""
import argparse
import json
import math
import sys

EARTH_RADIUS_M = 6371000.0
MAX_CELLS_WARNING = 200_000


def haversine_m(lat1, lng1, lat2, lng2):
    p1, p2 = math.radians(lat1), math.radians(lat2)
    dphi = p2 - p1
    dlmb = math.radians(lng2 - lng1)
    a = math.sin(dphi / 2) ** 2 + math.cos(p1) * math.cos(p2) * math.sin(dlmb / 2) ** 2
    return 2 * EARTH_RADIUS_M * math.asin(math.sqrt(a))


def iter_lines(geometry):
    """GeoJSON 객체에서 선(좌표 [경도, 위도] 목록)을 모두 꺼낸다. 알 수 없는 것은 건너뛴다."""
    if not isinstance(geometry, dict):
        return
    kind = geometry.get('type')
    if kind == 'FeatureCollection':
        for f in geometry.get('features', []):
            yield from iter_lines(f)
    elif kind == 'Feature':
        yield from iter_lines(geometry.get('geometry'))
    elif kind == 'GeometryCollection':
        for g in geometry.get('geometries', []):
            yield from iter_lines(g)
    elif kind == 'LineString':
        yield geometry.get('coordinates', [])
    elif kind == 'MultiLineString':
        yield from geometry.get('coordinates', [])
    elif kind == 'Polygon':
        yield from geometry.get('coordinates', [])  # 바깥·안쪽 고리를 모두 해안선으로 본다
    elif kind == 'MultiPolygon':
        for polygon in geometry.get('coordinates', []):
            yield from polygon


def valid_point(c):
    return (
        isinstance(c, (list, tuple))
        and len(c) >= 2
        and all(isinstance(v, (int, float)) and math.isfinite(v) for v in c[:2])
        and -180 <= c[0] <= 180
        and -90 <= c[1] <= 90
    )


def resample(line, spacing_m):
    """선을 따라 [spacing_m]미터마다 점을 찍는다. 첫 점은 항상 포함한다."""
    pts = [(c[1], c[0]) for c in line if valid_point(c)]  # (위도, 경도)
    if not pts:
        return []
    out = [pts[0]]
    carried = 0.0  # 마지막 점을 찍은 뒤 지금까지 걸어온 거리
    for (lat1, lng1), (lat2, lng2) in zip(pts, pts[1:]):
        seg = haversine_m(lat1, lng1, lat2, lng2)
        if seg == 0:
            continue
        pos = spacing_m - carried  # 이 선분 안에서 다음 점을 찍을 위치
        while pos <= seg:
            t = pos / seg
            out.append((lat1 + (lat2 - lat1) * t, lng1 + (lng2 - lng1) * t))
            pos += spacing_m
        carried = seg - (pos - spacing_m)
    return out


class SpatialIndex:
    """가까운 점이 이미 있는지 빨리 찾는 격자 색인(셀 크기 = 최소 간격)."""

    def __init__(self, min_gap_m):
        self.gap = min_gap_m
        self.cell_deg = max(min_gap_m / 111_195.0, 1e-7)
        self.grid = {}

    def _key(self, lat, lng):
        return (math.floor(lat / self.cell_deg), math.floor(lng / self.cell_deg))

    def too_close(self, lat, lng):
        ky, kx = self._key(lat, lng)
        # 경도 1도의 길이는 위도에 따라 줄어드므로 이웃 칸을 넉넉히(±2) 본다.
        for dy in range(-2, 3):
            for dx in range(-2, 3):
                for (plat, plng) in self.grid.get((ky + dy, kx + dx), ()):
                    if haversine_m(lat, lng, plat, plng) < self.gap:
                        return True
        return False

    def add(self, lat, lng):
        self.grid.setdefault(self._key(lat, lng), []).append((lat, lng))


def build_cells(geojson, spacing_m=150.0, dedupe_ratio=0.5):
    """해안선에서 셀 중심 목록을 만든다. 서로 [spacing_m * dedupe_ratio]미터 안의 점은 하나만 남긴다."""
    if spacing_m <= 0:
        raise ValueError('간격(spacing)은 0보다 커야 합니다')
    index = SpatialIndex(spacing_m * dedupe_ratio)
    cells = []
    for line in iter_lines(geojson):
        for lat, lng in resample(line, spacing_m):
            if not index.too_close(lat, lng):
                index.add(lat, lng)
                cells.append((round(lat, 6), round(lng, 6)))
    cells.sort()  # 같은 입력이면 항상 같은 결과가 나오게 한다
    return cells


def make_document(cells, radius_m, version):
    return {
        'version': version,
        'cell_radius_m': radius_m,
        'cells': [[lat, lng] for lat, lng in cells],
    }


def main(argv=None):
    ap = argparse.ArgumentParser(description='해안선 GeoJSON → 해안 셀(coast_cells.json)')
    ap.add_argument('input', help='해안선 GeoJSON 파일(WGS84)')
    ap.add_argument('-o', '--output', default='assets/data/coast_cells.json')
    ap.add_argument('--spacing', type=float, default=150.0, help='셀 사이 간격(미터), 기본 150')
    ap.add_argument('--radius', type=float, default=100.0, help='셀 반경(미터), 기본 100')
    ap.add_argument('--version', type=int, default=1, help='데이터 버전')
    args = ap.parse_args(argv)

    if args.radius <= 0:
        ap.error('--radius는 0보다 커야 합니다')
    if args.spacing > 2 * args.radius:
        print(f'경고: 간격({args.spacing}m)이 반경 두 배({2 * args.radius}m)보다 커서 셀 사이에 빈틈이 생겨 '
              '해안을 지나가도 감지하지 못할 수 있습니다.', file=sys.stderr)

    with open(args.input, encoding='utf-8') as f:
        data = json.load(f)

    cells = build_cells(data, spacing_m=args.spacing)
    if not cells:
        print('오류: 입력에서 해안선(선 또는 면)을 찾지 못했습니다.', file=sys.stderr)
        return 1
    if len(cells) > MAX_CELLS_WARNING:
        print(f'경고: 셀이 {len(cells):,}개입니다. 앱 용량과 검색 속도를 위해 간격을 늘리거나 '
              '지역별로 나누는 것을 고려하세요.', file=sys.stderr)

    with open(args.output, 'w', encoding='utf-8') as f:
        json.dump(make_document(cells, args.radius, args.version), f, ensure_ascii=False, separators=(',', ':'))
        f.write('\n')
    print(f'셀 {len(cells):,}개를 {args.output}에 썼습니다(간격 {args.spacing}m, 반경 {args.radius}m).')
    return 0


if __name__ == '__main__':
    sys.exit(main())
