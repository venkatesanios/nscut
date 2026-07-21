import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'ui/screens/editor_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NSCutApp());
}

class NSCutApp extends StatelessWidget {
  const NSCutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'nscut Video Editor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const EditorScreen(),
    );
  }
}
