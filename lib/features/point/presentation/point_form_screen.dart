import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

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
  PointSource _source = PointSource.manual;
  bool _loading = false;
  bool _saving = false;

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
    if (!mounted) return;
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
      if (widget.id == null) {
        await repo.create(input);
      } else {
        await repo.update(widget.id!, input);
      }
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
          const SizedBox(height: 16),
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
