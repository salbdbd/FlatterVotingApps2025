// import 'dart:convert';
import 'package:association/models/loger_item_model.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;

// class LedgerController extends GetxController {
//   var isLoading = true.obs;
//   var ledgerList = <PersonalLedgerModel>[].obs;

//   Future<void> fetchLedger(String comCode, String mobile) async {
//     try {
//       isLoading(true);
//       final url =
//           'http://103.125.253.59:2004/api/v1/get_MemberPersonalLedger/$comCode/$mobile';
//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         List jsonData = jsonDecode(response.body);
//         ledgerList.value =
//             jsonData.map((e) => PersonalLedgerModel.fromJson(e)).toList();
//       } else {
//         ledgerList.value = [];
//       }
//     } catch (e) {
//       Get.snackbar('Error', e.toString());
//     } finally {
//       isLoading(false);
//     }
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     fetchLedger('202', '01757389204');
//   }
// }

// Updated Controller - ledger_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class LedgerController extends GetxController {
  var isLoading = true.obs;
  var ledgerList = <PersonalLedgerModel>[].obs;
  var runningBalance = 0.0.obs;

  Future<void> fetchLedger(String comCode, String mobile) async {
    try {
      isLoading(true);
      final url =
          'http://103.125.253.59:2004/api/v1/get_MemberPersonalLedger/$comCode/$mobile';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List jsonData = jsonDecode(response.body);
        ledgerList.value =
            jsonData.map((e) => PersonalLedgerModel.fromJson(e)).toList();
        calculateRunningBalance();
      } else {
        ledgerList.value = [];
        Get.snackbar('Error', 'Failed to load data');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
      ledgerList.value = [];
    } finally {
      isLoading(false);
    }
  }

  void calculateRunningBalance() {
    double balance = 0.0;
    for (var item in ledgerList) {
      balance += item.drAmount - item.crAmount;
    }
    runningBalance.value = balance;
  }

  @override
  void onInit() {
    super.onInit();
    fetchLedger('202', '01757389204');
  }
}
