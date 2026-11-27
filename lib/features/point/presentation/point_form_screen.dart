import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../photo/application/photo_providers.dart';
import '../../photo/domain/photo_models.dart';
import '../../photo/presentation/photo_widgets.dart';
import '../../tracking/application/tracking_providers.dart';
import '../../tracking/domain/current_location.dart';
import '../application/point_providers.dart';
import '../domain/point_models.dart';

/// S09 포인트 등록·편집. [id]가 있으면 편집 모드.
/// 현재 위치 가져오기와 지도에서 고르기는 위치 권한·지도 SDK가 정해진 뒤 추가한다.
class PointFormScreen extends ConsumerStatefulWidget {
  const PointFormScreen({super.key, this.id});

  final String? id;

  @override
  ConsumerState<PointFormScreen> createState() => _PointFormScreenState();
}

class _PointFormScreenState extends ConsumerState<PointFormScreen> {
  final _name = TextEditingController();
  final _lat = TextEditingController();
  final _lng = TextEditingController();
  final _memo = TextEditingController();
  Genre? _genre;
  String? _savedId;
  final List<PhotoSlot> _photos = [];
  PointSource _source = PointSource.manual;
  bool _loading = false;
  bool _saving = false;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      _loading = true;
      _load();
    }
  }

  Future<void> _load() async {
    final p = await ref.read(pointRepositoryProvider).watchOne(widget.id!).first;
    final photos = await ref
        .read(photoRepositoryProvider)
        .watchByOwner(OwnerType.point, widget.id!)
        .first;
    if (!mounted) return;
    _photos.addAll(photos.map(PhotoSlot.saved));
    setState(() {
      _loading = false;
      if (p == null) return;
      _name.text = p.name;
      _lat.text = p.lat.toString();
      _lng.text = p.lng.toString();
      _memo.text = p.memo ?? '';
      _genre = p.genre;
      _source = p.source;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _lat.dispose();
    _lng.dispose();
    _memo.dispose();
    super.dispose();
  }

  /// 현재 위치를 위도·경도 칸에 채운다. 실패하면 안내만 보이고 입력은 그대로 둔다.
  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      final fix = await currentLocation(ref.read(locationSourceProvider));
      if (!mounted) return;
      setState(() {
        _lat.text = fix.lat.toStringAsFixed(6);
        _lng.text = fix.lng.toStringAsFixed(6);
      });
    } on LocationUnavailable catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _save() async {
    final lat = double.tryParse(_lat.text.trim());
    final lng = double.tryParse(_lng.text.trim());
    final error = validatePointInput(name: _name.text, lat: lat, lng: lng);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    final input = PointInput(
      name: _name.text,
      lat: lat!,
      lng: lng!,
      genre: _genre,
      memo: _memo.text,
      source: _source,
    );
    setState(() => _saving = true);
    try {
      final repo = ref.read(pointRepositoryProvider);
      // 사진 저장이 실패해 다시 누르면 새 포인트를 또 만들지 않고 같은 포인트를 갱신한다.
      var id = widget.id ?? _savedId;
      if (id == null) {
        id = await repo.create(input);
        _savedId = id;
      } else {
        await repo.update(id, input);
      }
      await persistPhotos(
        repo: ref.read(photoRepositoryProvider),
        store: ref.read(photoStoreProvider),
        owner: (type: OwnerType.point, id: id),
        keepIds: {for (final s in _photos) if (s.id != null) s.id!},
        picked: [for (final s in _photos) if (s.picked != null) s.picked!],
      );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('저장하지 못했습니다: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('포인트 편집')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    const coordKeyboard =
        TextInputType.numberWithOptions(decimal: true, signed: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? '포인트 추가' : '포인트 편집'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('저장'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(
                labelText: '이름', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _lat,
                  keyboardType: coordKeyboard,
                  decoration: const InputDecoration(
                      labelText: '위도', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _lng,
                  keyboardType: coordKeyboard,
                  decoration: const InputDecoration(
                      labelText: '경도', border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _locating ? null : _useCurrentLocation,
              icon: _locating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: Text(_locating ? '위치 찾는 중…' : '현재 위치 사용'),
            ),
          ),
          const SizedBox(height: 8),
          Text('장르', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('선택 안 함'),
                selected: _genre == null,
                onSelected: (_) => setState(() => _genre = null),
              ),
              for (final g in Genre.values)
                ChoiceChip(
                  label: Text(g.label),
                  selected: _genre == g,
                  onSelected: (_) => setState(() => _genre = g),
                ),
            ],
          ),
          const SizedBox(height: 16),
          PhotoEditor(
            slots: _photos,
            onAdd: (added) =>
                setState(() => _photos.addAll(added.map(PhotoSlot.picked))),
            onRemove: (slot) => setState(() => _photos.remove(slot)),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _memo,
            maxLines: 4,
            decoration: const InputDecoration(
                labelText: '메모', border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }
}
