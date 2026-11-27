import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../photo/application/photo_providers.dart';
import '../../photo/domain/photo_models.dart';
import '../../photo/presentation/photo_widgets.dart';
import '../../point/application/point_providers.dart';
import '../../species/domain/species_catalog.dart';
import '../application/catch_log_providers.dart';
import '../domain/catch_log_models.dart';
import 'date_format.dart';

/// S05 일지 작성·수정. [id]가 있으면 수정 모드.
class CatchLogFormScreen extends ConsumerStatefulWidget {
  const CatchLogFormScreen({super.key, this.id});

  final String? id;

  @override
  ConsumerState<CatchLogFormScreen> createState() => _CatchLogFormScreenState();
}

class _ItemRow {
  _ItemRow({this.species = 'seabass', String length = '', this.count = 1})
      : lengthCtrl = TextEditingController(text: length);

  String species;
  int count;
  final TextEditingController lengthCtrl;
}

class _CatchLogFormScreenState extends ConsumerState<CatchLogFormScreen> {
  Genre _genre = Genre.lure;
  DateTime _fishedAt = DateTime.now();
  String? _pointId;
  String? _savedId;
  final List<PhotoSlot> _photos = [];
  final _memo = TextEditingController();
  final Map<String, TextEditingController> _detail = {};
  final List<_ItemRow> _items = [];
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
    final log = await ref.read(catchLogRepositoryProvider).watchOne(widget.id!).first;
    final photos = await ref
        .read(photoRepositoryProvider)
        .watchByOwner(OwnerType.log, widget.id!)
        .first;
    if (!mounted) return;
    _photos.addAll(photos.map(PhotoSlot.saved));
    setState(() {
      _loading = false;
      if (log == null) return;
      _genre = log.genre;
      _fishedAt = log.fishedAt.toLocal();
      _pointId = log.pointId;
      _memo.text = log.memo ?? '';
      for (final f in log.genre.fields) {
        _detail[f.key] = TextEditingController(text: log.genreDetail[f.key] ?? '');
      }
      for (final it in log.items) {
        _items.add(_ItemRow(
          species: it.speciesCode,
          length: it.lengthCm?.toString() ?? '',
          count: it.count,
        ));
      }
    });
  }

  @override
  void dispose() {
    _memo.dispose();
    for (final c in _detail.values) {
      c.dispose();
    }
    for (final r in _items) {
      r.lengthCtrl.dispose();
    }
    super.dispose();
  }

  TextEditingController _ctrl(String key) =>
      _detail.putIfAbsent(key, TextEditingController.new);

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _fishedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_fishedAt),
    );
    if (time == null) return;
    setState(() => _fishedAt =
        DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  Future<void> _save() async {
    final items = <CatchItemInput>[];
    for (final r in _items) {
      final raw = r.lengthCtrl.text.trim();
      final len = raw.isEmpty ? null : double.tryParse(raw);
      if (raw.isNotEmpty && (len == null || len <= 0)) {
        _toast('크기는 0보다 큰 숫자로 입력해 주세요.');
        return;
      }
      items.add(CatchItemInput(
          speciesCode: r.species, lengthCm: len, count: r.count));
    }
    final input = CatchLogInput(
      genre: _genre,
      fishedAt: _fishedAt,
      pointId: _pointId,
      memo: _memo.text,
      genreDetail: {
        for (final f in _genre.fields) f.key: _ctrl(f.key).text,
      },
      items: items,
    );
    setState(() => _saving = true);
    try {
      final repo = ref.read(catchLogRepositoryProvider);
      // 사진 저장이 실패해 다시 누르면 새 일지를 또 만들지 않고 같은 일지를 갱신한다.
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
        owner: (type: OwnerType.log, id: id),
        keepIds: {for (final s in _photos) if (s.id != null) s.id!},
        picked: [for (final s in _photos) if (s.picked != null) s.picked!],
      );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        _toast('저장하지 못했습니다: $e');
      }
    }
  }

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('일지 수정')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? '일지 작성' : '일지 수정'),
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
          SegmentedButton<Genre>(
            segments: [
              for (final g in Genre.values)
                ButtonSegment(value: g, label: Text(g.label)),
            ],
            selected: {_genre},
            onSelectionChanged: (s) => setState(() => _genre = s.first),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule),
            title: Text(formatDateTime(_fishedAt)),
            subtitle: const Text('낚시한 시각'),
            onTap: _pickDateTime,
          ),
          _pointPicker(),
          const SizedBox(height: 12),
          for (final f in _genre.fields)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: _ctrl(f.key),
                decoration: InputDecoration(
                    labelText: f.label, border: const OutlineInputBorder()),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('조과', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              TextButton.icon(
                onPressed: () => setState(() => _items.add(_ItemRow())),
                icon: const Icon(Icons.add),
                label: const Text('어종 추가'),
              ),
            ],
          ),
          if (_items.isEmpty) const Text('꽝이면 비워 두세요.'),
          for (var i = 0; i < _items.length; i++) _itemEditor(i),
          const SizedBox(height: 16),
          PhotoEditor(
            slots: _photos,
            onAdd: (added) => setState(
                () => _photos.addAll(added.map(PhotoSlot.picked))),
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

  /// 포인트 연결. 이미 삭제된 포인트가 연결돼 있으면 선택 안 함으로 보인다.
  Widget _pointPicker() {
    final points = ref.watch(pointsProvider).value ?? const [];
    final selected = points.any((p) => p.id == _pointId) ? _pointId : null;
    return DropdownButtonFormField<String?>(
      key: ValueKey('${points.length}/$selected'),
      initialValue: selected,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: '포인트',
        border: OutlineInputBorder(),
        helperText: '선택하면 포인트 상세에서 이 일지의 장소를 볼 수 있어요',
      ),
      items: [
        const DropdownMenuItem<String?>(value: null, child: Text('선택 안 함')),
        for (final p in points)
          DropdownMenuItem<String?>(value: p.id, child: Text(p.name)),
      ],
      onChanged: (v) => setState(() => _pointId = v),
    );
  }

  Widget _itemEditor(int i) {
    final row = _items[i];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<String>(
              initialValue: row.species,
              isExpanded: true,
              decoration: const InputDecoration(
                  labelText: '어종', border: OutlineInputBorder()),
              items: [
                for (final e in speciesNames.entries)
                  DropdownMenuItem(value: e.key, child: Text(e.value)),
              ],
              onChanged: (v) => setState(() => row.species = v ?? row.species),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              controller: row.lengthCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  labelText: 'cm', border: OutlineInputBorder()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: row.count > 1 ? () => setState(() => row.count--) : null,
          ),
          Text('${row.count}'),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => setState(() => row.count++),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => setState(() {
              _items.removeAt(i).lengthCtrl.dispose();
            }),
          ),
        ],
      ),
    );
  }
}
