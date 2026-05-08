import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/event_provider.dart';
import 'providers/duty_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/officer/officer_dashboard.dart';
import 'screens/member/member_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => DutyProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class HudyatColors {
  static const background    = Color(0xFF111111);
  static const surface       = Color(0xFF181818);
  static const card          = Color(0xFF1E1E1E);
  static const cardElevated  = Color(0xFF252525);
  static const accent        = Color(0xFF8B1515);
  static const accentGlow    = Color(0xFFA01E1E);
  static const gold          = Color(0xFFF5C518);
  static const textPrimary   = Color(0xFFF5F5F5);
  static const textSecondary = Color(0xFF888888);
  static const divider       = Color(0xFF2C2C2C);
  static const success       = Color(0xFF30D158);
  static const warning       = Color(0xFFFFD60A);
  static const forestGreen   = Color(0xFF1E4A2D);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HUDYAT Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: HudyatColors.background,
        colorScheme: const ColorScheme.dark(
          primary: HudyatColors.accent,
          surface: HudyatColors.surface,
          onPrimary: Colors.white,
          onSurface: HudyatColors.textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: HudyatColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: HudyatColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        cardTheme: CardThemeData(
          color: HudyatColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.zero,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: HudyatColors.surface,
          selectedItemColor: HudyatColors.accent,
          unselectedItemColor: HudyatColors.textSecondary,
          selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 10),
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: HudyatColors.cardElevated,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: HudyatColors.accent, width: 1.5),
          ),
          labelStyle: const TextStyle(color: HudyatColors.textSecondary, fontSize: 14),
          hintStyle: const TextStyle(color: HudyatColors.textSecondary, fontSize: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: HudyatColors.accent,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        dividerColor: HudyatColors.divider,
        dialogTheme: DialogThemeData(
          backgroundColor: HudyatColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login':   (_) => const LoginScreen(),
        '/admin':   (_) => const AdminDashboard(),
        '/officer': (_) => const OfficerDashboard(),
        '/member':  (_) => const MemberDashboard(),
      },
    );
  }
}
