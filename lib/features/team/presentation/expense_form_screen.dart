import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../application/team_providers.dart';
import '../domain/team_models.dart';
import 'team_widgets.dart';

/// 비용 추가(expenseId 없음) 또는 수정. 내용·금액·결제한 사람·나눌 사람.
class ExpenseFormScreen extends ConsumerStatefulWidget {
  const ExpenseFormScreen({super.key, required this.tripId, this.expenseId});

  final String tripId;
  final String? expenseId;

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _desc = TextEditingController();
  final _amount = TextEditingController();
  String? _payer;
  final _targets = <String>{};
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _desc.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(tripProvider(widget.tripId));
    final expenses = ref.watch(expensesProvider(widget.tripId));
    final teamId = trip.value?.teamId;
    final team = teamId == null ? null : ref.watch(teamProvider(teamId));
    if (trip.isLoading || expenses.isLoading || team == null || team.isLoading) {
      return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    }
    final tv = trip.value, t = team.value;
    if (tv == null || t == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('없는 출조입니다.')));
    }
    final existing = widget.expenseId == null
        ? null
        : expenses.value?.where((e) => e.id == widget.expenseId).firstOrNull;
    if (widget.expenseId != null && existing == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('없는 비용입니다.')));
    }
    if (!_loaded) {
      _loaded = true;
      if (existing != null) {
        _desc.text = existing.description;
        _amount.text = existing.amount.toString();
        _payer = existing.payerId;
        _targets.addAll(existing.targetIds);
      } else {
        _payer = tv.participantIds.first;
        _targets.addAll(tv.participantIds); // 기본은 전원이 나눔
      }
    }
    final people = tv.participantIds;

    return Scaffold(
      appBar: AppBar(
        title: Text(existing == null ? '비용 추가' : '비용 수정'),
        actions: [
          if (existing != null)
            IconButton(
              tooltip: '비용 삭제',
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final ok = await confirm(context, '이 비용을 삭제할까요?', '${existing.description} ${existing.amount}원', ok: '삭제');
                if (!ok) return;
                await ref.read(teamRepositoryProvider).deleteExpense(existing.id);
                if (context.mounted) context.pop();
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _desc,
            decoration: const InputDecoration(labelText: '내용', hintText: '예: 기름값, 미끼, 점심'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amount,
            decoration: const InputDecoration(labelText: '금액(원)', suffixText: '원'),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 16),
          Text('결제한 사람', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final id in people)
                ChoiceChip(
                  label: Text(t.nameOf(id)),
                  selected: _payer == id,
                  onSelected: (_) => setState(() => _payer = id),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Text('나눌 사람 ${_targets.length}명', style: Theme.of(context).textTheme.titleSmall)),
              TextButton(
                onPressed: () => setState(() => _targets
                  ..clear()
                  ..addAll(people)),
                child: const Text('전원'),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final id in people)
                FilterChip(
                  label: Text(t.nameOf(id)),
                  selected: _targets.contains(id),
                  onSelected: (v) => setState(() => v ? _targets.add(id) : _targets.remove(id)),
                ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : () => _save(people),
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  Future<void> _save(List<String> people) async {
    setState(() => _saving = true);
    final input = ExpenseInput(
      description: _desc.text,
      amount: int.tryParse(_amount.text) ?? 0,
      payerId: _payer ?? '',
      targetIds: [for (final id in people) if (_targets.contains(id)) id],
    );
    final repo = ref.read(teamRepositoryProvider);
    try {
      if (widget.expenseId == null) {
        await repo.addExpense(widget.tripId, input);
      } else {
        await repo.updateExpense(widget.expenseId!, input);
      }
      if (mounted) context.pop();
    } on ArgumentError catch (e) {
      if (mounted) toast(context, '${e.message}');
    } on StateError catch (e) {
      if (mounted) toast(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
