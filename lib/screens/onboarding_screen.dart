import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/money_formatter.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  final budgetController = TextEditingController();
  int page = 0;

  @override
  void dispose() {
    controller.dispose();
    budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _OnboardPage(icon: Icons.account_balance_wallet_rounded, title: 'Selamat datang di CatatBoros', message: 'Catat pengeluaran harian tanpa form panjang. Semua data tersimpan lokal di HP.'),
      _OnboardPage(icon: Icons.auto_awesome, title: 'Smart Input', message: 'Cukup ketik “mie ayam 15k” atau “bensin 50rb”, lalu aplikasi mendeteksi nominal dan kategori.'),
      Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.savings_outlined, size: 82),
          const SizedBox(height: 18),
          Text('Atur budget awal', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          const Text('Opsional. Bisa dikosongkan dan diatur nanti.', textAlign: TextAlign.center),
          const SizedBox(height: 20),
          TextField(controller: budgetController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Budget bulanan', prefixText: 'Rp', border: OutlineInputBorder())),
        ]),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(child: PageView(controller: controller, onPageChanged: (v) => setState(() => page = v), children: pages)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              TextButton(onPressed: _finish, child: const Text('Lewati')),
              const Spacer(),
              FilledButton.icon(onPressed: page == pages.length - 1 ? _finish : _next, icon: Icon(page == pages.length - 1 ? Icons.check : Icons.arrow_forward), label: Text(page == pages.length - 1 ? 'Mulai' : 'Lanjut')),
            ]),
          ),
        ]),
      ),
    );
  }

  void _next() => controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  void _finish() {
    final budget = MoneyFormatter.parse(budgetController.text);
    context.read<AppProvider>().finishOnboarding(firstBudget: budget > 0 ? budget : null);
  }
}

class _OnboardPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const _OnboardPage({required this.icon, required this.title, required this.message});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 88, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 22),
          Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
        ]),
      );
}
