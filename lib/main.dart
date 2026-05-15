import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/splash_gate.dart';
import 'services/backup_service.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/security_service.dart';
import 'services/widget_service.dart';
import 'utils/app_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final database = DatabaseService();
  await database.init();
  final notifications = NotificationService();
  await notifications.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(
        databaseService: database,
        notificationService: notifications,
        backupService: BackupService(database),
        securityService: SecurityService(),
        widgetService: WidgetService(),
      )..load(),
      child: const CatatBorosApp(),
    ),
  );
}

class CatatBorosApp extends StatelessWidget {
  const CatatBorosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, app, _) {
      final baseTextTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConstants.appName,
        locale: const Locale('id', 'ID'),
        supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        themeMode: app.settings.themeMode,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: AppConstants.primaryColor, brightness: Brightness.light),
          textTheme: baseTextTheme,
          scaffoldBackgroundColor: const Color(0xFFF7F7F9),
          cardTheme: CardThemeData(color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
          appBarTheme: const AppBarTheme(centerTitle: false, scrolledUnderElevation: 0, backgroundColor: Colors.transparent),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: AppConstants.primaryColor, brightness: Brightness.dark),
          textTheme: baseTextTheme,
          scaffoldBackgroundColor: AppConstants.darkBackground,
          cardTheme: CardThemeData(color: const Color(0xFF1B1D21), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
          appBarTheme: const AppBarTheme(centerTitle: false, scrolledUnderElevation: 0, backgroundColor: Colors.transparent),
        ),
        builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(app.settings.fontScale)), child: child!),
        home: const SplashGate(),
      );
    });
  }
}
