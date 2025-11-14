import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'utils/theme.dart';
import 'utils/locale_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Skip Firebase initialization on web for now (requires web config)
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      // If Firebase isn't configured, app will continue
      // but Firestore calls will error at runtime
      debugPrint('Firebase init error: $e');
    }
  }

  await LocaleService.init();

  runApp(const MurasuApp());
}

class MurasuApp extends StatefulWidget {
  const MurasuApp({super.key});

  @override
  State<MurasuApp> createState() => _MurasuAppState();
}

class _MurasuAppState extends State<MurasuApp> {
  @override
  void initState() {
    super.initState();
    LocaleService.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    LocaleService.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'முரசு - Murasu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: LocaleService.locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ta')],
      home: const SplashScreen(),
    );
  }
}
