import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/wallet_controller.dart';

class WalletDashboardPage extends ConsumerWidget {
  const WalletDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walletControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('NearPay Wallet')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User: ${state.userId}'),
            Text('Balance: PKR ${state.balance}'),
            Text('Pending sync: ${state.pending}'),
            Text('Last transport: ${state.lastTransport ?? '-'}'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                try {
                  await ref.read(walletControllerProvider.notifier).sendOffline(
                        receiverId: 'nearby_user_b',
                        amount: 1000,
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Offline payment sent')),
                    );
                  }
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error.toString())),
                    );
                  }
                }
              },
              child: const Text('Send PKR 1000 to Nearby User'),
            ),
            const SizedBox(height: 12),
            const Chip(label: Text('Offline mode enabled')),
          ],
        ),
      ),
    );
  }
}
