import 'dart:convert';
import 'package:association/models/loger_item_model.dart';
import 'package:http/http.dart' as http;

import '../../../../services/api_service.dart';

class LedgerService {
  static Future<List<PersonalLedgerModel>> fetchLedger(
      String comCode, String mobile) async {
    final url =
        '${BaseUrl.baseUrl}/api/v1/get_MemberPersonalLedger/$comCode/$mobile';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((e) => PersonalLedgerModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load ledger');
    }
  }
}
