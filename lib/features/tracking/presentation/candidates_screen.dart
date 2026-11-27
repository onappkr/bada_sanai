import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../application/tracking_providers.dart';
import '../domain/tracking_ports.dart';

/// S12 포인트 후보 확정: 머문 자리마다 이름을 붙여 저장하거나 버린다.
class CandidatesScreen extends ConsumerWidget {
  const CandidatesScreen({super.key, required this.trackId});

  final String trackId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(pendingCandidatesProvider(trackId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('포인트 후보'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => context.go(Routes.map),
            child: const Text('완료'),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('불러오지 못했습니다: $e')),
        data: (items) => items.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('확정할 후보가 없어요.\n경로는 저장되었어요.', textAlign: TextAlign.center),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('오래 머문 자리예요. 이름을 붙여 포인트로 저장하세요.'),
                  const SizedBox(height: 8),
                  for (final c in items) _CandidateCard(key: ValueKey(c.id), candidate: c),
                ],
              ),
      ),
    );
  }
}

class _CandidateCard extends ConsumerStatefulWidget {
  const _CandidateCard({super.key, required this.candidate});

  final CandidateView candidate;

  @override
  ConsumerState<_CandidateCard> createState() => _CandidateCardState();
}

class _CandidateCardState extends ConsumerState<_CandidateCard> {
  final _name = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action, {String? done}) async {
    setState(() => _busy = true);
    try {
      await action();
      if (done != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(done)));
      }
    } on ArgumentError catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('${e.message}')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('실패했습니다: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.candidate;
    final repo = ref.read(trackRepositoryProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${c.dwell.inMinutes}분 머문 자리',
                style: Theme.of(context).textTheme.titleMedium),
            Text('${c.lat.toStringAsFixed(5)}, ${c.lng.toStringAsFixed(5)}'),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                  labelText: '포인트 이름', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _busy ? null : () => _run(() => repo.dismissCandidate(c.id)),
                  child: const Text('버리기'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _busy
                      ? null
                      : () => _run(
                            () async => repo.confirmCandidate(c.id, _name.text),
                            done: '포인트로 저장했어요.',
                          ),
                  child: const Text('저장'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
