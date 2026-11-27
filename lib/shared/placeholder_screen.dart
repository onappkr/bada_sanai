import 'package:material_ui/material_ui.dart';

/// 아직 구현되지 않은 화면의 자리표시자. 화면 ID와 목적을 보여 준다.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.id,
    required this.title,
    required this.purpose,
    this.params = const {},
    this.actions = const [],
  });

  final String id;
  final String title;
  final String purpose;
  final Map<String, String> params;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(id, style: text.labelLarge),
          const SizedBox(height: 8),
          Text(purpose, style: text.bodyLarge),
          for (final e in params.entries) Text('${e.key}: ${e.value}'),
          const SizedBox(height: 24),
          Wrap(spacing: 8, runSpacing: 8, children: actions),
        ],
      ),
    );
  }
}
