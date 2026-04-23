import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/crypto/crypto_service.dart';
import '../../../core/network/ble_transport.dart';
import '../../../core/network/fallback_transports.dart';
import '../../../core/network/transport.dart';
import '../../../core/storage/secure_key_store.dart';
import '../../transactions/domain/payment_token.dart';

class WalletState {
  const WalletState({
    required this.userId,
    required this.balance,
    required this.pending,
    required this.lastTransport,
  });

  final String userId;
  final int balance;
  final int pending;
  final String? lastTransport;

  WalletState copyWith({
    int? balance,
    int? pending,
    String? lastTransport,
  }) {
    return WalletState(
      userId: userId,
      balance: balance ?? this.balance,
      pending: pending ?? this.pending,
      lastTransport: lastTransport ?? this.lastTransport,
    );
  }
}

final walletControllerProvider = StateNotifierProvider<WalletController, WalletState>((ref) {
  return WalletController(
    cryptoService: CryptoService(keyStore: SecureKeyStore()),
    transports: [
      BleTransport(),
      WifiDirectTransport(),
      NfcTransport(),
      QrTransport(),
    ],
  );
});

class WalletController extends StateNotifier<WalletState> {
  WalletController({required this.cryptoService, required this.transports})
      : super(const WalletState(userId: 'user_a', balance: 10000, pending: 0, lastTransport: null));

  final CryptoService cryptoService;
  final List<Transport> transports;

  Future<void> sendOffline({required String receiverId, required int amount}) async {
    if (amount > 5000) {
      throw StateError('Offline transaction exceeds PKR 5000 limit.');
    }

    if (state.balance < amount) {
      throw StateError('Insufficient local balance.');
    }

    final keys = await cryptoService.loadOrCreateKeyPair();
    final nonce = const Uuid().v4();

    final unsigned = PaymentToken(
      senderId: state.userId,
      receiverId: receiverId,
      amount: amount,
      timestamp: DateTime.now().toUtc(),
      nonce: nonce,
    );

    final signed = cryptoService.signPaymentToken(unsigned, keys.privateKey);
    final envelope = await cryptoService.encryptForReceiver(
      token: signed,
      senderPrivateKey: keys.privateKey,
      receiverPublicKey: keys.publicKey,
    );

    for (final transport in transports) {
      if (await transport.available) {
        await transport.send(envelope, receiverId);
        state = state.copyWith(
          balance: state.balance - amount,
          pending: state.pending + 1,
          lastTransport: transport.name,
        );
        return;
      }
    }

    throw StateError('No transport channel available.');
  }
}
