import 'package:flutter/material.dart';
import 'package:animated_digit/animated_digit.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../services/api_service.dart';
import '../../indexing_page/indexing_page.dart';

class NumberAnimation extends StatefulWidget {
  final UserDetails? userDetails;

  const NumberAnimation({
    Key? key,
    this.userDetails,
  });

  @override
  _NumberAnimationState createState() => _NumberAnimationState();
}

class _NumberAnimationState extends State<NumberAnimation> {
  int totalMembers = 0;

  @override
  void initState() {
    super.initState();
    // Fetch data when the widget is initialized
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final int fetchedMembers = await fetchMember();
      setState(() {
        totalMembers = fetchedMembers;
      });
    } catch (error) {
      // Handle errors
      print('Error fetching data: $error');
    }
  }

  Future<int> fetchMember() async {
    try {
      int compId = widget.userDetails?.selectedCompanyData.compId ?? 0;
      int userId = widget.userDetails?.selectedCompanyData.userId ?? 0;
      int memberId = widget.userDetails?.selectedCompanyData.memberId ?? 0;

      final String apiUrl = '${BaseUrl.baseUrl}/api/v1/CountMember/$compId';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'accept': '*/*',
          'Authorization': BaseUrl.authorization,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        if (responseData.isNotEmpty) {
          final Map<String, dynamic> data = responseData[0];
          final int totalMembers = data['TatalMember'];
          return totalMembers;
        } else {
          throw Exception('Invalid response body');
        }
      } else {
        throw Exception('Failed to load data. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Color(0xff15212D),
        border: Border.all(width: 2, color: Colors.white),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Total Member ",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          AnimatedDigitWidget(
            value: totalMembers, // Use the fetched value
            textStyle: TextStyle(color: Colors.white, fontSize: 20),
            duration: Duration(seconds: 2),
          ),
        ],
      ),
    );
  }
}
