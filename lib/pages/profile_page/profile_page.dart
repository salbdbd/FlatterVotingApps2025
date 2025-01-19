import 'dart:convert';
import 'package:association/pages/indexing_page/indexing_page.dart';
import 'package:association/pages/profile_page/change_password/change_password.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_service.dart';
import '../Login_Or_Signup/login_page.dart';
import 'components/custom_text_field_for_profile.dart';

class ProfilePage extends StatefulWidget {
  final UserDetails? userDetails;

  const ProfilePage({
    Key? key,
    this.userDetails,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isContainerVisible = false;
  bool isLoading = true;

  TextEditingController memberCodeController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController fatherNameController = TextEditingController();
  TextEditingController motherNameController = TextEditingController();
  TextEditingController presentAddressController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchGetMemberUserById();
  }

  Future<void> fetchGetMemberUserById() async {
    final compId = widget.userDetails?.selectedCompanyData.compId ?? 0;
    final userName = widget.userDetails?.userData.userName ?? 0;
    // final mobileNo = widget.userDetails?.userData.mobileNo?? 0;

    /*// get data by member id if user name is member id
    final memberId= widget.userDetails?.selectedCompanyData.memberId??0;*/

    // debugPrint("\n\n Member Id : ${memberId}\n\n");

    final url = Uri.parse(
        '${BaseUrl.baseUrl}/api/v1/GetMemberUserById/$compId/$userName');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': '${BaseUrl.authorization}',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // debugPrint("\n\nRay json data : $jsonData\n\n");

        setState(() {
          memberCodeController.text = jsonData['memberCode'] ?? '';
          userNameController.text = jsonData['memberName'] ?? '';
          fatherNameController.text = jsonData['fathersName'] ?? '';
          motherNameController.text = jsonData['mothersName'] ?? '';
          presentAddressController.text = jsonData['presentAddress'] ?? '';
          mobileNoController.text = jsonData['mobileNo'] ?? '';
          emailController.text = jsonData['email'] ?? '';
          isLoading = false;
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Center(
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/Images/TigerHRMSwhite.png',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            width: 200,
                            child: Text(
                              widget.userDetails?.userData.companyName ?? '',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isContainerVisible = !isContainerVisible;
                      });
                    },
                    child: Container(
                      height: 50,
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'See Your Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Icon(
                            isContainerVisible
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 700),
                    curve: Curves.easeInOut,
                    height: isContainerVisible ? null : 0,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        CustomTextFieldsforProfile(
                          controller: memberCodeController,
                          labelText: 'Member Code',
                          hintText: 'Member Code',
                          disableOrEnable: false,
                          borderColor: 0xFFBCC2C2,
                          filled: false,
                          prefixIcon: Icons.code,
                        ),
                        CustomTextFieldsforProfile(
                          controller: userNameController,
                          labelText: 'Name',
                          hintText: 'Name',
                          disableOrEnable: false,
                          borderColor: 0xFFBCC2C2,
                          filled: false,
                          prefixIcon: Icons.account_circle,
                        ),
                        CustomTextFieldsforProfile(
                          controller: fatherNameController,
                          labelText: 'Father Name',
                          hintText: 'Father Name',
                          disableOrEnable: false,
                          borderColor: 0xFFBCC2C2,
                          filled: false,
                          prefixIcon: Icons.family_restroom,
                        ),
                        CustomTextFieldsforProfile(
                          controller: motherNameController,
                          labelText: 'Mother Name',
                          hintText: 'Mother Name',
                          disableOrEnable: false,
                          borderColor: 0xFFBCC2C2,
                          filled: false,
                          prefixIcon: Icons.family_restroom,
                        ),
                        CustomTextFieldsforProfile(
                          controller: mobileNoController,
                          labelText: 'Mobile No',
                          hintText: 'Mobile No',
                          disableOrEnable: false,
                          borderColor: 0xFFBCC2C2,
                          filled: false,
                          prefixIcon: Icons.phone_iphone,
                        ),
                        CustomTextFieldsforProfile(
                          controller: emailController,
                          labelText: 'Email',
                          hintText: 'Email',
                          disableOrEnable: false,
                          borderColor: 0xFFBCC2C2,
                          filled: false,
                          prefixIcon: Icons.email_outlined,
                        ),
                        CustomTextFieldsforProfile(
                          controller: presentAddressController,
                          labelText: 'Present Address',
                          hintText: 'Present Address',
                          disableOrEnable: false,
                          borderColor: 0xFFBCC2C2,
                          filled: false,
                          prefixIcon: Icons.other_houses,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: GestureDetector(
                      onTap: _logout,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xff15212D),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: const Text(
                                  'LogOut',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                subtitle: const Text(
                                  'LogOut your Company',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                leading: Icon(
                                  Icons.logout,
                                  color: Colors.white,
                                  size: 50,
                                ),
                                trailing: Icon(Icons.arrow_forward_ios,
                                    size: 40, color: Colors.orange),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChangePasswordPage()));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xff15212D),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: const Text(
                                  'Chnage Password',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                leading: Icon(
                                  Icons.change_circle,
                                  color: Colors.white,
                                  size: 50,
                                ),
                                trailing: Icon(Icons.arrow_forward_ios,
                                    size: 40, color: Colors.orange),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _logout() async {
    await Hive.close();
    await Hive.deleteBoxFromDisk('loginData');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Get.offAll(() => LoginPage());
  }
}
