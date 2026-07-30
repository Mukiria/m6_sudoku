import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_theme_extension.dart';
import 'core/routing/app_router.dart';
import 'core/constants/app_constants.dart';
import 'core/di/service_locator.dart';
import 'features/settings/presentation/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDependencies();

  runApp(
    const ProviderScope(
      child: M6SudokuApp(),
    ),
  );
}

class M6SudokuApp extends ConsumerWidget {
  const M6SudokuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme.copyWith(
        extensions: [AppThemeExtension.light],
      ),
      darkTheme: AppTheme.darkTheme.copyWith(
        extensions: [AppThemeExtension.dark],
      ),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context)
                  .textScaler
                  .clamp(
                    minScaleFactor: 0.8,
                    maxScaleFactor: 1.3,
                  )
                  .scale(1.0),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
