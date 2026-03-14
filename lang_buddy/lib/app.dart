import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'router.dart';

final onboardingCompleteProvider = StateProvider<bool>((ref) => false);

class LangBuddyApp extends ConsumerWidget {
  const LangBuddyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final onboardingDone = ref.watch(onboardingCompleteProvider);

    if (!onboardingDone) {
      return MaterialApp(
        title: 'LangBuddy',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        debugShowCheckedModeBanner: false,
        home: OnboardingScreen(
          onComplete: () {
            ref.read(onboardingCompleteProvider.notifier).state = true;
          },
        ),
      );
    }

    return MaterialApp.router(
      title: 'LangBuddy',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
