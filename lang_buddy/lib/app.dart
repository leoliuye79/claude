import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'router.dart';

const _onboardingKey = 'onboarding_complete';
const _storage = FlutterSecureStorage();

final onboardingCompleteProvider =
    FutureProvider<bool>((ref) async {
  final value = await _storage.read(key: _onboardingKey);
  return value == 'true';
});

class LangBuddyApp extends ConsumerWidget {
  const LangBuddyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final onboardingAsync = ref.watch(onboardingCompleteProvider);

    return onboardingAsync.when(
      loading: () => MaterialApp(
        title: 'LangBuddy',
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, __) => _buildOnboarding(context, ref, themeMode),
      data: (done) {
        if (!done) return _buildOnboarding(context, ref, themeMode);
        return MaterialApp.router(
          title: 'LangBuddy',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }

  Widget _buildOnboarding(
      BuildContext context, WidgetRef ref, ThemeMode themeMode) {
    return MaterialApp(
      title: 'LangBuddy',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: OnboardingScreen(
        onComplete: () async {
          await _storage.write(key: _onboardingKey, value: 'true');
          ref.invalidate(onboardingCompleteProvider);
        },
      ),
    );
  }
}
