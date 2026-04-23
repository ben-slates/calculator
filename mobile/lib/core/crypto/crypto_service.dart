import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:cryptography/cryptography.dart';
import 'package:elliptic/elliptic.dart';

import '../../features/transactions/domain/payment_token.dart';
import '../storage/secure_key_store.dart';

class CryptoService {
  CryptoService({required SecureKeyStore keyStore}) : _keyStore = keyStore;

  final SecureKeyStore _keyStore;
  final Curve _curve = getSecp256k1();
  final AesGcm _aes = AesGcm.with256bits();

  Future<({PrivateKey privateKey, PublicKey publicKey})> loadOrCreateKeyPair() async {
    final stored = await _keyStore.readPrivateKeyHex();
    if (stored != null) {
      final pk = PrivateKey.fromHex(_curve, stored);
      return (privateKey: pk, publicKey: pk.publicKey);
    }

    final secureRandom = Random.secure();
    final entropy = List<int>.generate(32, (_) => secureRandom.nextInt(256));
    final privateKeyHex = hex.encode(entropy);
    final privateKey = PrivateKey.fromHex(_curve, privateKeyHex);
    await _keyStore.savePrivateKeyHex(privateKey.toHex());
    return (privateKey: privateKey, publicKey: privateKey.publicKey);
  }

  PaymentToken signPaymentToken(PaymentToken token, PrivateKey privateKey) {
    final digest = crypto.sha256.convert(utf8.encode(token.canonicalPayload())).bytes;
    final signature = _curve.sign(privateKey, digest);
    return token.copyWith(signature: signature.toCompactHex());
  }

  bool verifyPaymentToken(PaymentToken token, PublicKey senderPublicKey) {
    if (token.signature == null) return false;
    final digest = crypto.sha256.convert(utf8.encode(token.canonicalPayload())).bytes;
    final signature = Signature.fromCompactHex(_curve, token.signature!);
    return _curve.verify(senderPublicKey, digest, signature);
  }

  Future<EncryptedEnvelope> encryptForReceiver({
    required PaymentToken token,
    required PrivateKey senderPrivateKey,
    required PublicKey receiverPublicKey,
  }) async {
    final sharedSecret = _deriveSharedSecret(senderPrivateKey, receiverPublicKey);
    final secretKey = SecretKey(_expandToAes256(sharedSecret));
    final nonce = _randomBytes(12);
    final payload = utf8.encode(jsonEncode(token.toJson()));
    final encrypted = await _aes.encrypt(payload, secretKey: secretKey, nonce: nonce);

    return EncryptedEnvelope(
      senderPublicKeyHex: senderPrivateKey.publicKey.toHex(),
      nonceHex: hex.encode(encrypted.nonce),
      cipherHex: hex.encode(encrypted.cipherText),
      macHex: hex.encode(encrypted.mac.bytes),
    );
  }

  Future<PaymentToken> decryptFromSender({
    required EncryptedEnvelope envelope,
    required PrivateKey receiverPrivateKey,
  }) async {
    final senderPublic = PublicKey.fromHex(_curve, envelope.senderPublicKeyHex);
    final sharedSecret = _deriveSharedSecret(receiverPrivateKey, senderPublic);
    final secretKey = SecretKey(_expandToAes256(sharedSecret));

    final box = SecretBox(
      hex.decode(envelope.cipherHex),
      nonce: hex.decode(envelope.nonceHex),
      mac: Mac(hex.decode(envelope.macHex)),
    );

    final decrypted = await _aes.decrypt(box, secretKey: secretKey);
    return PaymentToken.fromJson(jsonDecode(utf8.decode(decrypted)) as Map<String, dynamic>);
  }

  List<int> _deriveSharedSecret(PrivateKey ownPrivateKey, PublicKey remotePublicKey) {
    final shared = remotePublicKey * ownPrivateKey;
    return shared.toBytes();
  }

  List<int> _expandToAes256(List<int> sharedSecret) {
    return crypto.sha256.convert(sharedSecret).bytes;
  }

  List<int> _randomBytes(int size) {
    final random = Random.secure();
    return List<int>.generate(size, (_) => random.nextInt(256));
  }
}

class EncryptedEnvelope {
  const EncryptedEnvelope({
    required this.senderPublicKeyHex,
    required this.nonceHex,
    required this.cipherHex,
    required this.macHex,
  });

  final String senderPublicKeyHex;
  final String nonceHex;
  final String cipherHex;
  final String macHex;

  Map<String, dynamic> toJson() => {
        'sender_pub': senderPublicKeyHex,
        'nonce': nonceHex,
        'cipher': cipherHex,
        'mac': macHex,
      };

  static EncryptedEnvelope fromJson(Map<String, dynamic> json) => EncryptedEnvelope(
        senderPublicKeyHex: json['sender_pub'] as String,
        nonceHex: json['nonce'] as String,
        cipherHex: json['cipher'] as String,
        macHex: json['mac'] as String,
      );
}
