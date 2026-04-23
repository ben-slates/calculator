import 'dart:convert';

import 'package:http/http.dart' as http;

import '../db/local_ledger.dart';

class SyncEngine {
  SyncEngine({
    required this.db,
    required this.baseUrl,
    required this.jwt,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final LocalLedgerDatabase db;
  final String baseUrl;
  final String jwt;
  final http.Client _client;

  Future<int> syncPending() async {
    final pending = await db.pending();
    var syncedCount = 0;

    for (final tx in pending) {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/sync/transactions/'),
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': tx.id,
          'sender_id': tx.senderId,
          'receiver_id': tx.receiverId,
          'amount': tx.amount,
          'nonce': tx.nonce,
          'signature': tx.signature,
          'timestamp': tx.createdAt.toUtc().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await db.markSynced(tx.id);
        syncedCount += 1;
      }
    }

    return syncedCount;
  }
}
