import 'package:flutter/material.dart';

import '../features/home/flixnest_shell.dart';
import 'flixnest_theme.dart';

class FlixNestApp extends StatelessWidget {
  const FlixNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlixNest',
      debugShowCheckedModeBanner: false,
      theme: FlixNestTheme.dark,
      home: const FlixNestShell(),
    );
  }
}
