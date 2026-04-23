import '../crypto/crypto_service.dart';
import 'transport.dart';

class WifiDirectTransport implements Transport {
  @override
  String get name => 'WiFi Direct';

  @override
  Future<bool> get available async => false;

  @override
  Future<void> send(EncryptedEnvelope envelope, String receiverHint) async {
    throw UnimplementedError('WiFi Direct adapter to be completed in phase 3.');
  }
}

class NfcTransport implements Transport {
  @override
  String get name => 'NFC';

  @override
  Future<bool> get available async => false;

  @override
  Future<void> send(EncryptedEnvelope envelope, String receiverHint) async {
    throw UnimplementedError('NFC adapter to be completed in phase 3.');
  }
}

class QrTransport implements Transport {
  @override
  String get name => 'QR';

  @override
  Future<bool> get available async => true;

  @override
  Future<void> send(EncryptedEnvelope envelope, String receiverHint) async {
    // Manual QR display/scan exchange as last fallback path.
  }
}
