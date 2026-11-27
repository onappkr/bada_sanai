import 'package:material_ui/material_ui.dart';

import '../../../core/geo/geo_point.dart';
import '../../../core/geo/projection.dart';

/// 경로 주변에 같이 그릴 포인트 하나.
class PlotMarker {
  const PlotMarker({required this.name, required this.position});

  final String name;
  final GeoPoint position;
}

/// 지도 배경 없이 경로선과 주변 포인트의 상대 위치를 그린다(북쪽이 위).
/// 지도 SDK가 붙으면 이 자리를 지도로 바꾼다.
class TrackPlot extends StatelessWidget {
  const TrackPlot({super.key, required this.route, this.markers = const []});

  final List<GeoPoint> route;
  final List<PlotMarker> markers;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, box) {
        final size = Size(box.maxWidth, box.hasBoundedHeight ? box.maxHeight : box.maxWidth);
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CustomPaint(
            size: size,
            painter: _PlotPainter(
              route: route,
              markers: markers,
              background: scheme.surfaceContainerHighest,
              line: scheme.primary,
              markerColor: scheme.tertiary,
              textStyle: TextStyle(color: scheme.onSurface, fontSize: 11),
            ),
          ),
        );
      },
    );
  }
}

class _PlotPainter extends CustomPainter {
  _PlotPainter({
    required this.route,
    required this.markers,
    required this.background,
    required this.line,
    required this.markerColor,
    required this.textStyle,
  });

  final List<GeoPoint> route;
  final List<PlotMarker> markers;
  final Color background;
  final Color line;
  final Color markerColor;
  final TextStyle textStyle;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    if (route.isEmpty && markers.isEmpty) return;

    // 경로와 마커를 한 좌표계에 투영해야 서로의 위치가 맞는다.
    final all = [...route, for (final m in markers) m.position];
    final projected = projectToBox(all, width: size.width, height: size.height, padding: 28);
    final routePts = projected.take(route.length).toList();
    final markerPts = projected.skip(route.length).toList();

    if (routePts.length > 1) {
      final path = Path()..moveTo(routePts.first.x, routePts.first.y);
      for (final p in routePts.skip(1)) {
        path.lineTo(p.x, p.y);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = line
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    for (var i = 0; i < markers.length; i++) {
      final p = markerPts[i];
      canvas.drawCircle(Offset(p.x, p.y), 6, Paint()..color = markerColor);
      canvas.drawCircle(
        Offset(p.x, p.y),
        6,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      _label(canvas, size, markers[i].name, Offset(p.x + 9, p.y - 7));
    }

    if (routePts.isNotEmpty) {
      canvas.drawCircle(Offset(routePts.first.x, routePts.first.y), 7, Paint()..color = Colors.green);
      if (routePts.length > 1) {
        canvas.drawCircle(Offset(routePts.last.x, routePts.last.y), 7, Paint()..color = Colors.red);
      }
    }
  }

  void _label(Canvas canvas, Size size, String text, Offset at) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: size.width * 0.4);
    // 오른쪽 끝을 넘치면 마커 왼쪽에 둔다.
    final dx = at.dx + tp.width > size.width - 4 ? at.dx - tp.width - 18 : at.dx;
    tp.paint(canvas, Offset(dx, at.dy));
  }

  @override
  bool shouldRepaint(_PlotPainter old) =>
      old.route != route || old.markers != markers || old.background != background;
}
