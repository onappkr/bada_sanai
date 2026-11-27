import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../../core/geo/geo_point.dart';
import '../../../core/geo/map_viewport.dart';
import '../../../core/geo/polyline_codec.dart';
import '../../share/presentation/paste_link_dialog.dart';
import '../../tracking/application/tracking_providers.dart';
import '../../tracking/domain/current_location.dart';
import '../application/point_providers.dart';
import '../domain/point_models.dart';

/// 지도에 한 번에 그리는 저장 경로의 최대 개수(최근 순). 너무 많으면 지도가 느려진다.
const mapTrackLimit = 30;

/// S07 포인트 지도: 내 포인트 마커와 저장된 이동 경로, 현재 위치.
/// 지도는 OpenStreetMap 타일(API 키 불필요)을 쓴다. 많은 사용자가 쓰게 되면
/// OSM 타일 서버 이용 정책상 자체 타일 서버나 상용 타일로 바꿔야 한다.
class PointMapScreen extends ConsumerStatefulWidget {
  const PointMapScreen({super.key});

  @override
  ConsumerState<PointMapScreen> createState() => _PointMapScreenState();
}

class _PointMapScreenState extends ConsumerState<PointMapScreen> {
  final _controller = MapController();
  GeoPoint? _me;
  bool _locating = false;

  static LatLng _ll(GeoPoint p) => LatLng(p.lat, p.lng);

  Future<void> _goToMe() async {
    setState(() => _locating = true);
    try {
      final fix = await currentLocation(ref.read(locationSourceProvider));
      final me = GeoPoint(fix.lat, fix.lng);
      if (!mounted) return;
      setState(() => _me = me);
      _controller.move(_ll(me), 15);
    } on LocationUnavailable catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _fitAll(MapViewportPlan plan) {
    if (plan.bounds != null) {
      final b = plan.bounds!;
      _controller.fitCamera(CameraFit.bounds(
        bounds: LatLngBounds(_ll(b.southWest), _ll(b.northEast)),
        padding: const EdgeInsets.all(48),
        maxZoom: 16,
      ));
    } else {
      _controller.move(_ll(plan.center!), plan.zoom!);
    }
  }

  void _showPoint(PointView p) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.name, style: Theme.of(c).textTheme.titleLarge),
              Text([
                if (p.genre != null) p.genre!.label,
                '${p.lat.toStringAsFixed(5)}, ${p.lng.toStringAsFixed(5)}',
              ].join(' · ')),
              if (p.memo != null) ...[const SizedBox(height: 8), Text(p.memo!)],
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  Navigator.pop(c);
                  context.push(Routes.pointDetailOf(p.id));
                },
                child: const Text('포인트 상세'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pointsAsync = ref.watch(pointsProvider);
    final tracksAsync = ref.watch(savedTracksProvider);

    final points = pointsAsync.value ?? const <PointView>[];
    final lines = <List<GeoPoint>>[
      for (final t in (tracksAsync.value ?? const []).take(mapTrackLimit))
        if (t.encodedPolyline.isNotEmpty) PolylineCodec.decode(t.encodedPolyline),
    ];

    final plan = planViewport([
      for (final p in points) GeoPoint(p.lat, p.lng),
      for (final l in lines) ...l,
    ]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('지도'),
        actions: [
          IconButton(
            tooltip: '목록으로 보기',
            icon: const Icon(Icons.list),
            onPressed: () => context.push(Routes.pointList),
          ),
          IconButton(
            tooltip: '내 경로',
            icon: const Icon(Icons.route),
            onPressed: () => context.push(Routes.tracks),
          ),
          IconButton(
            tooltip: '링크로 포인트 받기',
            icon: const Icon(Icons.link),
            onPressed: () => showPasteLinkDialog(context),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'fit',
            tooltip: '전체 보기',
            onPressed: () => _fitAll(plan),
            child: const Icon(Icons.zoom_out_map),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'me',
            tooltip: '내 위치',
            onPressed: _locating ? null : _goToMe,
            child: _locating
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.my_location),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'add',
            onPressed: () => context.push(Routes.pointNew),
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('포인트 추가'),
          ),
        ],
      ),
      // 데이터가 오기 전에 지도를 만들면 처음 화면이 엉뚱한 곳에 맞춰지므로 첫 값을 기다린다.
      body: (!pointsAsync.hasValue || !tracksAsync.hasValue)
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _controller,
              options: MapOptions(
                initialCenter: plan.center == null ? const LatLng(36.5, 127.8) : _ll(plan.center!),
                initialZoom: plan.zoom ?? 7,
                initialCameraFit: plan.bounds == null
                    ? null
                    : CameraFit.bounds(
                        bounds: LatLngBounds(_ll(plan.bounds!.southWest), _ll(plan.bounds!.northEast)),
                        padding: const EdgeInsets.all(48),
                        maxZoom: 16,
                      ),
                minZoom: 3,
                maxZoom: 18,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'kr.onapp.bada_sanai',
                ),
                PolylineLayer(polylines: [
                  for (final l in lines)
                    if (l.length > 1)
                      Polyline(
                        points: [for (final p in l) _ll(p)],
                        strokeWidth: 4,
                        color: scheme.primary.withValues(alpha: 0.85),
                      ),
                ]),
                MarkerLayer(markers: [
                  for (final p in points)
                    Marker(
                      point: LatLng(p.lat, p.lng),
                      width: 44,
                      height: 44,
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () => _showPoint(p),
                        child: Icon(Icons.location_on, size: 44, color: scheme.error),
                      ),
                    ),
                  if (_me != null)
                    Marker(
                      point: _ll(_me!),
                      width: 22,
                      height: 22,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                      ),
                    ),
                ]),
                const RichAttributionWidget(
                  attributions: [TextSourceAttribution('© OpenStreetMap contributors')],
                ),
              ],
            ),
    );
  }
}
