import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const BadaSanaiApp());
}

class BadaSanaiApp extends StatelessWidget {
  const BadaSanaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '바다 사나이',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B5FA5)),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('바다 사나이')),
      ),
    );
  }
}
