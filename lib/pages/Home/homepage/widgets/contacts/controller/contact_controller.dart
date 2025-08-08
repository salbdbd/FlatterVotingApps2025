import 'package:association/pages/Home/homepage/widgets/contacts/model/contacts_model.dart';
import 'package:association/services/api_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MemberController extends GetxController {
  var isLoading = true.obs;
  var memberList = <Member>[].obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    fetchMembers();
    super.onInit();
  }

  Future<void> fetchMembers() async {
    try {
      isLoading(true);
      errorMessage('');

      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/v1/GetLEDGERMemberShortList/202'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        memberList.assignAll(
            jsonResponse.map((item) => Member.fromJson(item)).toList());
      } else {
        errorMessage('Failed to load members: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage('Error fetching members: $e');
    } finally {
      isLoading(false);
    }
  }
}
