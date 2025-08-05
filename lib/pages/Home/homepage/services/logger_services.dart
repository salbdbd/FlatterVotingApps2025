import 'dart:convert';
import 'package:association/models/loger_item_model.dart';
import 'package:http/http.dart' as http;

class LedgerService {
  static Future<List<PersonalLedgerModel>> fetchLedger(
      String comCode, String mobile) async {
    final url =
        'http://103.125.253.59:2004/api/v1/get_MemberPersonalLedger/$comCode/$mobile';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((e) => PersonalLedgerModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load ledger');
    }
  }
}
