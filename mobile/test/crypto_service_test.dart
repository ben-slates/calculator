import 'package:flutter_test/flutter_test.dart';
import 'package:nearpay/core/crypto/crypto_service.dart';
import 'package:nearpay/core/storage/secure_key_store.dart';
import 'package:nearpay/features/transactions/domain/payment_token.dart';

class InMemoryStore extends SecureKeyStore {
  String? _key;

  @override
  Future<String?> readPrivateKeyHex() async => _key;

  @override
  Future<void> savePrivateKeyHex(String privateKeyHex) async {
    _key = privateKeyHex;
  }
}

void main() {
  test('sign + verify token passes', () async {
    final service = CryptoService(keyStore: InMemoryStore());
    final keys = await service.loadOrCreateKeyPair();

    final token = PaymentToken(
      senderId: 'a',
      receiverId: 'b',
      amount: 500,
      timestamp: DateTime.utc(2026, 1, 1),
      nonce: 'nonce',
    );

    final signed = service.signPaymentToken(token, keys.privateKey);
    expect(service.verifyPaymentToken(signed, keys.publicKey), isTrue);
  });

  test('encrypt + decrypt payload roundtrip', () async {
    final service = CryptoService(keyStore: InMemoryStore());
    final keys = await service.loadOrCreateKeyPair();

    final token = PaymentToken(
      senderId: 'a',
      receiverId: 'b',
      amount: 700,
      timestamp: DateTime.utc(2026, 1, 1),
      nonce: 'n-1',
    );
    final signed = service.signPaymentToken(token, keys.privateKey);

    final envelope = await service.encryptForReceiver(
      token: signed,
      senderPrivateKey: keys.privateKey,
      receiverPublicKey: keys.publicKey,
    );

    final restored = await service.decryptFromSender(
      envelope: envelope,
      receiverPrivateKey: keys.privateKey,
    );

    expect(restored.amount, 700);
    expect(restored.signature, isNotNull);
  });
}
