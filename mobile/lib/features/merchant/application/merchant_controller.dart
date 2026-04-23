import 'dart:convert';

class MerchantController {
  String exportCsv(List<Map<String, dynamic>> txs) {
    final buffer = StringBuffer('id,sender,amount,timestamp\n');
    for (final tx in txs) {
      buffer.writeln('${tx['id']},${tx['sender']},${tx['amount']},${tx['timestamp']}');
    }
    return utf8.decode(utf8.encode(buffer.toString()));
  }
}
