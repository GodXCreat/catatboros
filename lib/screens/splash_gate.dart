import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_constants.dart';
import 'lock_screen.dart';
import 'main_shell.dart';
import 'onboarding_screen.dart';

class SplashGate extends StatelessWidget {
  const SplashGate({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    if (app.isLoading) {
      return const Scaffold(body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.account_balance_wallet_rounded, size: 72, color: AppConstants.primaryColor), SizedBox(height: 18), CircularProgressIndicator()])));
    }
    if (app.settings.firstRun) return const OnboardingScreen();
    return AppLockGate(securityEnabled: app.settings.securityEnabled, child: const MainShell());
  }
}
