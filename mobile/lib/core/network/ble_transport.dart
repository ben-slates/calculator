import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../crypto/crypto_service.dart';
import 'transport.dart';

class BleTransport implements Transport {
  @override
  String get name => 'BLE';

  @override
  Future<bool> get available async => FlutterBluePlus.isSupported;

  @override
  Future<void> send(EncryptedEnvelope envelope, String receiverHint) async {
    // In production, this method maps receiverHint to advertised BLE service data,
    // opens a secure GATT characteristic, and transmits chunked encrypted payload.
    // Stub intentionally preserves real package usage and async contract.
    await Future<void>.delayed(const Duration(milliseconds: 150));
  }
}
