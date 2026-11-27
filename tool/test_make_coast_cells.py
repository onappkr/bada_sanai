import json
import os
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.dirname(__file__))
import make_coast_cells as m  # noqa: E402


def line_north(meters, lng=129.0, lat0=35.0):
    """위도 방향으로 meters만큼 가는 선(GeoJSON [경도, 위도])."""
    return [[lng, lat0], [lng, lat0 + meters / 111195.0]]


def feature(geometry):
    return {'type': 'Feature', 'properties': {}, 'geometry': geometry}


class ResampleTest(unittest.TestCase):
    def test_점을_간격마다_찍고_첫_점을_포함한다(self):
        cells = m.build_cells(feature({'type': 'LineString', 'coordinates': line_north(1000)}), spacing_m=150)
        # 0, 150, ..., 900 → 7개(1000m까지 150m 간격)
        self.assertEqual(len(cells), 7)
        self.assertAlmostEqual(cells[0][0], 35.0, places=5)

    def test_이웃한_셀_사이_거리가_간격과_같다(self):
        cells = m.build_cells(feature({'type': 'LineString', 'coordinates': line_north(2000)}), spacing_m=150)
        for a, b in zip(cells, cells[1:]):
            self.assertAlmostEqual(m.haversine_m(a[0], a[1], b[0], b[1]), 150, delta=1.5)

    def test_꺾인_선도_거리가_이어서_계산된다(self):
        # 북쪽 500m 후 동쪽으로 500m 꺾임: 꺾이는 점에서 거리가 초기화되면 간격이 어긋난다.
        lat_end = 35.0 + 500 / 111195.0
        lng_step = 500 / (111195.0 * 0.8192)  # 위도 35도에서 경도 1도 ≈ 91.1km
        line = [[129.0, 35.0], [129.0, lat_end], [129.0 + lng_step, lat_end]]
        cells = m.build_cells(feature({'type': 'LineString', 'coordinates': line}), spacing_m=100)
        gaps = [m.haversine_m(a[0], a[1], b[0], b[1]) for a, b in zip(cells, cells[1:])]
        self.assertTrue(all(g > 60 for g in gaps), gaps)  # 꺾인 곳에서도 촘촘해지지 않는다
        self.assertTrue(all(g < 140 for g in gaps), gaps)

    def test_짧은_선은_첫_점만(self):
        cells = m.build_cells(feature({'type': 'LineString', 'coordinates': line_north(50)}), spacing_m=150)
        self.assertEqual(len(cells), 1)


class GeometryTypesTest(unittest.TestCase):
    def test_여러_도형_종류를_읽는다(self):
        ring = [[129.0, 35.0], [129.01, 35.0], [129.01, 35.01], [129.0, 35.01], [129.0, 35.0]]
        collections = {
            'type': 'FeatureCollection',
            'features': [
                feature({'type': 'LineString', 'coordinates': line_north(500, lng=128.0)}),
                feature({'type': 'MultiLineString', 'coordinates': [line_north(500, lng=127.0), line_north(500, lng=126.0)]}),
                feature({'type': 'Polygon', 'coordinates': [ring]}),
                feature({'type': 'MultiPolygon', 'coordinates': [[ring]]}),
                feature({'type': 'Point', 'coordinates': [129.5, 35.5]}),  # 선이 아니므로 무시
            ],
        }
        cells = m.build_cells(collections, spacing_m=150)
        lngs = {round(c[1], 1) for c in cells}
        self.assertTrue({128.0, 127.0, 126.0}.issubset(lngs))
        self.assertGreater(len(cells), 20)  # 면의 둘레(약 4.4km)에서도 셀이 나온다

    def test_GeometryCollection도_읽는다(self):
        g = {'type': 'GeometryCollection', 'geometries': [{'type': 'LineString', 'coordinates': line_north(400)}]}
        self.assertGreater(len(m.build_cells(g, spacing_m=150)), 1)

    def test_잘못된_좌표는_건너뛴다(self):
        line = [[129.0, 35.0], [999.0, 35.0], ['a', 'b'], [129.0, 35.002]]
        cells = m.build_cells(feature({'type': 'LineString', 'coordinates': line}), spacing_m=100)
        self.assertGreaterEqual(len(cells), 1)
        for lat, lng in cells:
            self.assertTrue(-90 <= lat <= 90 and -180 <= lng <= 180)

    def test_해안선이_없으면_빈_목록(self):
        self.assertEqual(m.build_cells({'type': 'FeatureCollection', 'features': []}), [])
        self.assertEqual(m.build_cells('엉뚱한 값'), [])


class DedupeTest(unittest.TestCase):
    def test_겹치는_선은_가까운_점을_하나만_남긴다(self):
        a = feature({'type': 'LineString', 'coordinates': line_north(1000)})
        b = feature({'type': 'LineString', 'coordinates': line_north(1000, lng=129.0 + 10 / 91000.0)})  # 약 10m 옆
        both = m.build_cells({'type': 'FeatureCollection', 'features': [a, b]}, spacing_m=150)
        one = m.build_cells(a, spacing_m=150)
        self.assertEqual(len(both), len(one))

    def test_멀리_떨어진_선은_모두_남긴다(self):
        a = feature({'type': 'LineString', 'coordinates': line_north(1000)})
        b = feature({'type': 'LineString', 'coordinates': line_north(1000, lng=130.0)})
        both = m.build_cells({'type': 'FeatureCollection', 'features': [a, b]}, spacing_m=150)
        self.assertEqual(len(both), 2 * len(m.build_cells(a, spacing_m=150)))

    def test_같은_입력은_항상_같은_결과(self):
        data = feature({'type': 'LineString', 'coordinates': line_north(3000)})
        self.assertEqual(m.build_cells(data), m.build_cells(data))


class ErrorsTest(unittest.TestCase):
    def test_간격이_0_이하면_오류(self):
        with self.assertRaises(ValueError):
            m.build_cells(feature({'type': 'LineString', 'coordinates': line_north(100)}), spacing_m=0)


class CommandLineTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)

    def run_cli(self, geojson, *extra):
        src = os.path.join(self.tmp.name, 'in.geojson')
        out = os.path.join(self.tmp.name, 'out.json')
        with open(src, 'w', encoding='utf-8') as f:
            json.dump(geojson, f)
        code = m.main([src, '-o', out, *extra])
        return code, out

    def test_앱이_읽는_형식으로_쓴다(self):
        code, out = self.run_cli(feature({'type': 'LineString', 'coordinates': line_north(1000)}),
                                 '--spacing', '150', '--radius', '100', '--version', '3')
        self.assertEqual(code, 0)
        with open(out, encoding='utf-8') as f:
            doc = json.load(f)
        self.assertEqual(doc['version'], 3)
        self.assertEqual(doc['cell_radius_m'], 100)
        self.assertEqual(len(doc['cells']), 7)
        # 앱(Dart의 CoastCells.parse)이 요구하는 형식: [위도, 경도] 두 숫자, 범위 안
        for c in doc['cells']:
            self.assertEqual(len(c), 2)
            self.assertTrue(-90 <= c[0] <= 90 and -180 <= c[1] <= 180)

    def test_해안선이_없으면_실패한다(self):
        code, _ = self.run_cli({'type': 'FeatureCollection', 'features': []})
        self.assertEqual(code, 1)


if __name__ == '__main__':
    unittest.main()
