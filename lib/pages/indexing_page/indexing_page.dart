import 'dart:convert';
import 'package:association/pages/indexing_page/get_usercompay_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../Custom_widget/loading_dialog.dart';
import '../../models/login.dart';
import '../../services/api_service.dart';
import '../dashboard.dart';

class IndexingPage extends StatefulWidget {
  final Login? userData; // Make userData nullable

  const IndexingPage({Key? key, this.userData}) : super(key: key);

  @override
  State<IndexingPage> createState() => _IndexingPageState();
}

class _IndexingPageState extends State<IndexingPage> {
  late Future<List<GetUserCompanyModel>> userCompanyData;

  @override
  void initState() {
    super.initState();
    userCompanyData = fetchUserCompanyData();
  }

  Future<void> _navigateToDashboard(
      List<GetUserCompanyModel> userCompanies) async {
    if (userCompanies.length == 1) {
      UserDetails userDetails = UserDetails(
        userData: widget.userData!,
        selectedCompanyData: userCompanies.first,
      );

      Get.off(() => Dashboard(userDetails: userDetails));
    }
    // If the user has more than one company, they will stay on the IndexingPage.
  }

  Future<List<GetUserCompanyModel>> fetchUserCompanyData() async {
    try {
      final response = await http.get(
        Uri.parse(
            '${BaseUrl.baseUrl}/api/v1/Get_UserCompany/${widget.userData!.userName}'),
        headers: {
          'accept': '*/*',
          'Authorization': '${BaseUrl.authorization}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        List<GetUserCompanyModel> userCompanies =
            List<GetUserCompanyModel>.from(
          jsonResponse.map((data) => GetUserCompanyModel.fromJson(data)),
        );

        // Directly navigate to Dashboard if the user has only one company
        await _navigateToDashboard(userCompanies);

        return userCompanies;
      } else {
        throw Exception('Failed to load user company data');
      }
    } catch (error) {
      print('Error fetching user company data: $error');
      // Handle errors here, you might want to show an error message to the user.
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.greenAccent,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10.0),
              bottomRight: Radius.circular(10.0),
            ),
          ),
          child: AppBar(
            backgroundColor: const Color(0xff15212D),
            elevation: 0.0,
            title: const Text(
              "Select Membership Account",
              style: TextStyle(color: Colors.white),
            ),
            automaticallyImplyLeading: false,
          ),
        ),
      ),
      body: FutureBuilder<List<GetUserCompanyModel>>(
        future: userCompanyData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: LoadingDialog(messageText: "Allowing you to login..."));
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<GetUserCompanyModel> userCompanies = snapshot.data!;

            return SingleChildScrollView(
              child: Column(
                children: userCompanies.map((company) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: GestureDetector(
                      onTap: () {
                        UserDetails userDetails = UserDetails(
                          userData: widget.userData!,
                          selectedCompanyData: company,
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Dashboard(userDetails: userDetails),
                          ),
                        );
                      },
                      child: Container(
                        height: 100,
                        width: screenWidth,
                        decoration: BoxDecoration(
                          color: Color(0xff15212D),
                          border:
                              Border.all(width: 2, color: Color(0xff15212D)),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                company.name ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'compId: ${company.compId}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white60,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }
}

class UserDetails {
  final Login userData;
  final GetUserCompanyModel selectedCompanyData;
  UserDetails({
    required this.userData,
    required this.selectedCompanyData,
  });
}
