import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class AppLockGate extends StatefulWidget {
  final bool securityEnabled;
  final Widget child;
  const AppLockGate({super.key, required this.securityEnabled, required this.child});
  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  bool locked = false;
  DateTime? pausedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    locked = widget.securityEnabled;
  }

  @override
  void didUpdateWidget(covariant AppLockGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.securityEnabled && !oldWidget.securityEnabled) locked = true;
    if (!widget.securityEnabled) locked = false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final app = context.read<AppProvider>();
    if (state == AppLifecycleState.paused) pausedAt = DateTime.now();
    if (state == AppLifecycleState.resumed && widget.securityEnabled && pausedAt != null) {
      final diff = DateTime.now().difference(pausedAt!).inMinutes;
      if (diff >= app.settings.autoLockMinutes) setState(() => locked = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.securityEnabled || !locked) return widget.child;
    return LockScreen(onUnlocked: () => setState(() => locked = false));
  }
}

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  const LockScreen({super.key, required this.onUnlocked});
  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final pinController = TextEditingController();
  String error = '';

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.lock_rounded, size: 80, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 18),
              Text('CatatBoros terkunci', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              const Text('Masukkan PIN atau gunakan biometrik untuk membuka aplikasi.'),
              const SizedBox(height: 24),
              if (app.settings.pinEnabled)
                TextField(
                  controller: pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(labelText: 'PIN', errorText: error.isEmpty ? null : error, border: const OutlineInputBorder()),
                  onSubmitted: (_) => _unlockWithPin(),
                ),
              const SizedBox(height: 8),
              Row(children: [
                if (app.settings.pinEnabled) Expanded(child: FilledButton(onPressed: _unlockWithPin, child: const Text('Buka'))),
                if (app.settings.biometricEnabled) ...[
                  if (app.settings.pinEnabled) const SizedBox(width: 10),
                  Expanded(child: OutlinedButton.icon(onPressed: _unlockBiometric, icon: const Icon(Icons.fingerprint), label: const Text('Biometrik'))),
                ],
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  void _unlockWithPin() {
    final app = context.read<AppProvider>();
    if (app.securityService.verifyPin(pinController.text, app.settings.pinHash)) {
      widget.onUnlocked();
    } else {
      setState(() => error = 'PIN salah');
    }
  }

  Future<void> _unlockBiometric() async {
    final app = context.read<AppProvider>();
    if (await app.securityService.authenticateBiometric()) widget.onUnlocked();
  }
}
