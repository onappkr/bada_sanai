import 'package:material_ui/material_ui.dart';

void toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// 한 줄 글자를 묻는 대화상자. 취소하거나 비우면 null.
Future<String?> askText(
  BuildContext context, {
  required String title,
  required String label,
  String? hint,
  String initial = '',
}) {
  return showDialog<String>(
    context: context,
    builder: (c) => _AskTextDialog(title: title, label: label, hint: hint, initial: initial),
  );
}

class _AskTextDialog extends StatefulWidget {
  const _AskTextDialog({required this.title, required this.label, this.hint, required this.initial});

  final String title;
  final String label;
  final String? hint;
  final String initial;

  @override
  State<_AskTextDialog> createState() => _AskTextDialogState();
}

class _AskTextDialogState extends State<_AskTextDialog> {
  late final _c = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _submit() {
    final v = _c.text.trim();
    Navigator.pop(context, v.isEmpty ? null : v);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _c,
        autofocus: true,
        decoration: InputDecoration(labelText: widget.label, hintText: widget.hint),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
        FilledButton(onPressed: _submit, child: const Text('확인')),
      ],
    );
  }
}

Future<bool> confirm(BuildContext context, String title, String body, {String ok = '확인'}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('취소')),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(ok)),
      ],
    ),
  );
  return r == true;
}
