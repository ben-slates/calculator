import 'package:flutter/material.dart';

import '../features/wallet/presentation/wallet_dashboard_page.dart';

class NearPayApp extends StatelessWidget {
  const NearPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NearPay',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const WalletDashboardPage(),
    );
  }
}
