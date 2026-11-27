import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/geo/geo_point.dart';
import '../../species/application/species_providers.dart';
import '../../tracking/application/tracking_providers.dart';
import '../../tracking/domain/current_location.dart';
import '../application/forecast_providers.dart';
import '../domain/forecast_models.dart';
import '../domain/forecast_ports.dart';

String _hhmm(DateTime t) {
  final l = t.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(l.hour)}:${two(l.minute)}';
}

/// S14 물때·날씨 상세. 위치는 버튼을 눌렀을 때만 가져온다.
class ForecastScreen extends ConsumerStatefulWidget {
  const ForecastScreen({super.key});

  @override
  ConsumerState<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends ConsumerState<ForecastScreen> {
  bool _loading = false;
  String? _error;
  ForecastBundle? _bundle;
  String? _regionName;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final fix = await currentLocation(ref.read(locationSourceProvider));
      final service = await ref.read(forecastServiceProvider.future);
      final bundle = await service.get(GeoPoint(fix.lat, fix.lng), DateTime.now());
      final book = await ref.read(ruleBookProvider.future);
      final name = book.regions
          .where((r) => r.code == bundle.regionCode)
          .map((r) => r.nameKo)
          .firstOrNull;
      if (mounted) {
        setState(() {
          _bundle = bundle;
          _regionName = name;
        });
      }
    } on LocationUnavailable catch (e) {
      if (mounted) setState(() => _error = e.message);
    } on ForecastError catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = '불러오지 못했어요: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final b = _bundle;
    return Scaffold(
      appBar: AppBar(title: const Text('물때·날씨')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('지금 위치에서 가장 가까운 해역의 오늘 물때와 날씨예요.'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.my_location),
            label: Text(_loading ? '불러오는 중…' : (b == null ? '내 위치로 보기' : '다시 불러오기')),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          if (b != null) ...[
            const SizedBox(height: 16),
            Text(_regionName ?? b.regionCode, style: text.titleLarge),
            Text('${b.date} · 마지막 갱신 ${_hhmm(b.fetchedAt)}', style: text.bodySmall),
            if (b.stale)
              Card(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                margin: const EdgeInsets.only(top: 8),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('새로 가져오지 못해 이전에 받은 정보를 보여 드려요. 실제와 다를 수 있어요.'),
                ),
              ),
            const SizedBox(height: 16),
            _TideSection(tide: b.tide),
            const SizedBox(height: 16),
            _WeatherSection(weather: b.weather),
            const SizedBox(height: 16),
            _row('수온', b.seaTempC == null ? null : '${b.seaTempC!.toStringAsFixed(1)}℃'),
          ],
        ],
      ),
    );
  }
}

Widget _row(String label, String? value) => ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(label),
      trailing: Text(value ?? '정보 없음'),
    );

class _TideSection extends StatelessWidget {
  const _TideSection({required this.tide});

  final TideInfo? tide;

  @override
  Widget build(BuildContext context) {
    final t = tide;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('물때', style: Theme.of(context).textTheme.titleMedium),
        _row('물때', t?.mulddae == null ? null : '${t!.mulddae}물'),
        if (t == null || t.extremes.isEmpty)
          _row('만조·간조', null)
        else
          for (final e in t.extremes)
            _row('${e.type == TideType.high ? '만조' : '간조'} ${_hhmm(e.time)}', '${e.heightCm}cm'),
      ],
    );
  }
}

class _WeatherSection extends StatelessWidget {
  const _WeatherSection({required this.weather});

  final WeatherInfo? weather;

  @override
  Widget build(BuildContext context) {
    final w = weather;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('날씨', style: Theme.of(context).textTheme.titleMedium),
        _row('하늘', skyLabel(w?.sky)),
        _row('기온', w?.tempC == null ? null : '${w!.tempC!.toStringAsFixed(0)}℃'),
        _row(
          '바람',
          w?.windMps == null
              ? null
              : '${w!.windDirDeg == null ? '' : '${windDirectionLabel(w.windDirDeg!)} '}${w.windMps}m/s',
        ),
        _row('파고', w?.waveM == null ? null : '${w!.waveM}m'),
        _row('강수', w?.precipMm == null ? null : '${w!.precipMm}mm'),
      ],
    );
  }
}
