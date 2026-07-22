import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  final themeController = ThemeController();
  await themeController.load();
  runApp(QrApp(themeController: themeController));
}

class QrApp extends StatelessWidget {
  final ThemeController themeController;

  const QrApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: themeController,
      child: Consumer<ThemeController>(
        builder: (context, controller, _) {
          return MaterialApp(
            title: 'QR Code',
            debugShowCheckedModeBanner: false,
            locale: const Locale('fa'),
            supportedLocales: const [Locale('fa')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: controller.themeMode,
            home: const _SplashFadeIn(child: HomeScreen()),
          );
        },
      ),
    );
  }
}

/// اسپلش نیتیو را تا آماده شدن اولین فریم واقعی نگه می‌دارد، سپس آن را کنار
/// می‌زند و محتوای اپ را با یک فیدِ نرم روی همان رنگ پس‌زمینه‌ی اسپلش نشان
/// می‌دهد تا گذار ناگهانی و پرشی حس نشود.
class _SplashFadeIn extends StatefulWidget {
  final Widget child;

  const _SplashFadeIn({required this.child});

  @override
  State<_SplashFadeIn> createState() => _SplashFadeInState();
}

class _SplashFadeInState extends State<_SplashFadeIn> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF0E0B1A),
      child: FadeTransition(opacity: _controller, child: widget.child),
    );
  }
}
