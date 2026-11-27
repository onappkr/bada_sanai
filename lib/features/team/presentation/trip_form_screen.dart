import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../application/team_providers.dart';
import '../domain/team_models.dart';
import 'team_widgets.dart';

/// 출조 추가(teamId) 또는 수정(tripId). 이름·날짜·참여자를 정한다.
class TripFormScreen extends ConsumerStatefulWidget {
  const TripFormScreen.create({super.key, required String this.teamId}) : tripId = null;
  const TripFormScreen.edit({super.key, required String this.tripId}) : teamId = null;

  final String? teamId;
  final String? tripId;

  @override
  ConsumerState<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends ConsumerState<TripFormScreen> {
  final _title = TextEditingController();
  DateTime _date = DateTime.now();
  final _selected = <String>{};
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.tripId != null;
    final trip = editing ? ref.watch(tripProvider(widget.tripId!)) : null;
    final teamId = editing ? trip?.value?.teamId : widget.teamId;
    final team = teamId == null ? null : ref.watch(teamProvider(teamId));

    if (editing && trip!.isLoading || team == null || team.isLoading) {
      return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    }
    final t = team.value;
    if (t == null || (editing && trip!.value == null)) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('없는 항목입니다.')));
    }
    if (!_loaded) {
      _loaded = true;
      if (editing) {
        final v = trip!.value!;
        _title.text = v.title;
        _date = v.date.toLocal();
        _selected.addAll(v.participantIds);
      } else {
        _selected.addAll(t.activeMembers.map((m) => m.id)); // 기본은 전원 참여
      }
    }

    // 고를 수 있는 사람: 팀의 활성 멤버 + (수정 시) 이미 참여 중인 사람
    final shown = [
      for (final m in t.members)
        if (!m.removed || _selected.contains(m.id)) m,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(editing ? '출조 수정' : '출조 추가')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: '출조 이름', hintText: '예: 가덕도 갯바위'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event),
            title: Text('${_date.year}.${_date.month.toString().padLeft(2, '0')}.${_date.day.toString().padLeft(2, '0')}'),
            subtitle: const Text('출조한 날'),
            onTap: _pickDate,
          ),
          const SizedBox(height: 8),
          Text('참여자 ${_selected.length}명', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final m in shown)
                FilterChip(
                  label: Text(m.removed ? '${m.name}(뺀 멤버)' : m.name),
                  selected: _selected.contains(m.id),
                  onSelected: (v) => setState(() => v ? _selected.add(m.id) : _selected.remove(m.id)),
                ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : () => _save(t),
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _save(TeamView team) async {
    setState(() => _saving = true);
    final repo = ref.read(teamRepositoryProvider);
    // 팀 멤버 순서를 따라 정렬해 저장한다.
    final ids = [for (final m in team.members) if (_selected.contains(m.id)) m.id];
    final input = TripInput(title: _title.text, date: DateTime(_date.year, _date.month, _date.day), participantIds: ids);
    try {
      if (widget.tripId != null) {
        await repo.updateTrip(widget.tripId!, input);
        if (mounted) context.pop();
      } else {
        final id = await repo.createTrip(team.id, input);
        if (mounted) {
          context.pop();
          context.push(Routes.tripOf(id));
        }
      }
    } on ArgumentError catch (e) {
      if (mounted) toast(context, '${e.message}');
    } on StateError catch (e) {
      if (mounted) toast(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
