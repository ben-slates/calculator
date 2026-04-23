import '../crypto/crypto_service.dart';

abstract class Transport {
  String get name;
  Future<bool> get available;
  Future<void> send(EncryptedEnvelope envelope, String receiverHint);
}
