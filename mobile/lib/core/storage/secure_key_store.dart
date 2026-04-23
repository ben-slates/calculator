import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureKeyStore {
  SecureKeyStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _privateKeyTag = 'nearpay_private_key_hex';
  final FlutterSecureStorage _storage;

  Future<void> savePrivateKeyHex(String privateKeyHex) {
    return _storage.write(key: _privateKeyTag, value: privateKeyHex);
  }

  Future<String?> readPrivateKeyHex() {
    return _storage.read(key: _privateKeyTag);
  }
}
