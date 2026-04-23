import 'dart:convert';

class PaymentToken {
  const PaymentToken({
    required this.senderId,
    required this.receiverId,
    required this.amount,
    required this.timestamp,
    required this.nonce,
    this.signature,
  });

  final String senderId;
  final String receiverId;
  final int amount;
  final DateTime timestamp;
  final String nonce;
  final String? signature;

  PaymentToken copyWith({String? signature}) {
    return PaymentToken(
      senderId: senderId,
      receiverId: receiverId,
      amount: amount,
      timestamp: timestamp,
      nonce: nonce,
      signature: signature ?? this.signature,
    );
  }

  Map<String, dynamic> toJson() => {
        'sender_id': senderId,
        'receiver_id': receiverId,
        'amount': amount,
        'timestamp': timestamp.toUtc().toIso8601String(),
        'nonce': nonce,
        'signature': signature,
      };

  static PaymentToken fromJson(Map<String, dynamic> json) => PaymentToken(
        senderId: json['sender_id'] as String,
        receiverId: json['receiver_id'] as String,
        amount: json['amount'] as int,
        timestamp: DateTime.parse(json['timestamp'] as String),
        nonce: json['nonce'] as String,
        signature: json['signature'] as String?,
      );

  String canonicalPayload() {
    final data = {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'amount': amount,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'nonce': nonce,
    };
    return jsonEncode(data);
  }
}
