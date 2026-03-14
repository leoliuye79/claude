import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'router.dart';

class LangBuddyApp extends StatelessWidget {
  const LangBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LangBuddy',
      theme: AppTheme.light,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
