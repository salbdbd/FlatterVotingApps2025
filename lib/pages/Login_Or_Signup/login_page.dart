import 'package:association/pages/indexing_page/indexing_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import '../../Custom_widget/custom_text_field.dart';
import '../../methods/common_methods.dart';
import 'package:association/models/login.dart';
import '../../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import this
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../forget_pass_page/phone_number_verification/forget_send_otp.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  SharedPreferences? sharedPreferences;

  String? save;
  Map<String, dynamic>? jsonResponse;
  CommonMethods cMethods = CommonMethods();

  bool rememberMe = false;
  bool passwordVisible = false;

  List<Map<String, String>> userCredentialsList = [];

  checkIfNetworkIsAvailable() async {
    final bool isConnected = await cMethods.checkConnectivity(context);
    if (isConnected) {
      signIn();
    }
    // else if(!isConnected){
    //       //cMethods.displaySnackBarRed("Your Internet is not available. Check your connection and try again.", context);
    //
    // }
    // cMethods.checkConnectivity(context).then((isConnected) {
    //   if (isConnected) {
    //     signIn();
    //   }
    //   else {
    //   //  signIn();
    //     cMethods.displaySnackBarRed("Your Internet is not available. Check your connection and try again.", context);
    //   }
    // });
  }

  Future<void> signIn() async {
    try {
      var url = Uri.parse('${BaseUrl.baseUrl}/api/v1/login');
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': '${BaseUrl.authorization}'
      };
      var body = json.encode({
        "userName": userNameController.text,
        "password": passwordController.text,
      });

      var response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);

        // Use the Login model to parse the JSON response
        var loginModel = Login.fromJson(jsonResponse);

        print("loginModelimon$loginModel");

        // Save login data to SharedPreferences
        saveLoginData(loginModel);

        // Navigate to IndexingPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => IndexingPage(userData: loginModel)),
        );

        // Remove this line
        // Get.off(IndexingPage(userData: loginModel));

        // Save username and password if 'Remember Me' is checked

        cMethods.displaySnackBarGreen("Login successful", context);
      } else {
        print('Login failed: ${response.reasonPhrase}');
        cMethods.displaySnackBarRed("Login Failed", context);
      }
    } catch (error) {
      print('Error during login: $error');
    }
  }

  // Save all login data using Hive
  void saveLoginData(Login loginData) async {
    var box = await Hive.openBox('loginData');

    // Convert the Login object to a JSON string
    String jsonData = json.encode(loginData.toJson());

    box.put('userData', jsonData);
  }

  void saveCredentials(String userName, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', userName);

    // Request permission to save password
    var status = await Permission.storage.request();

    if (status.isGranted) {
      prefs.setString('password', password);

      // Save credentials to the list
      Map<String, String> credentials = {
        'userName': userName,
        'password': password
      };
      userCredentialsList.add(credentials);

      // Save the updated list to SharedPreferences
      prefs.setString('userCredentialsList', json.encode(userCredentialsList));
    } else {
      print('Permission not granted to save password.');
    }
  }

  // Save credentials using SharedPreferences

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body:
          //Stack(
          //   children: [
          // Lottie.asset(
          //   'assets/Images/login_page_animation.json',
          //   fit: BoxFit.cover,
          //   width: double.infinity,
          //   height: double.infinity,
          // ),
          SafeArea(
        child: Container(
          padding: const EdgeInsets.all(10),
          height: screenHeight,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Colors.blue.shade100,
            Colors.blueGrey.shade100,
            Colors.blue.shade100
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: (screenHeight * .2),
                ),
                Column(
                  children: [
                    // Container(
                    //   height: 180,
                    //   width: 180,
                    // child: Lottie.asset(
                    //   'assets/Images/animation_login.json',
                    //   fit: BoxFit.cover,
                    // ),
                    // ),

                    const Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextFields(
                      controller: userNameController,
                      labelText: 'User Name',
                      hintText: 'User Name',
                      disableOrEnable: true,
                      borderColor: 0xFF000000,
                      filled: false,
                      prefixIcon: Icons.account_circle,
                    ),
                    CustomTextFields(
                      controller: passwordController,
                      labelText: 'Password',
                      hintText: 'Password',
                      disableOrEnable: true,
                      borderColor: 0xFFBCC2C2,
                      filled: false,
                      prefixIcon: Icons.password_rounded,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            passwordVisible = !passwordVisible;
                          });
                        },
                        icon: Icon(
                          passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                      ),
                      obscureText: !passwordVisible,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            rememberMe = !rememberMe;
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      rememberMe = value ?? false;
                                    });
                                  },
                                ),
                                const Text(
                                  'Remember me',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 16,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.blue),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ForgetSandOtpPage()));
                              },
                              child: const Text(
                                "Forget password?",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            checkIfNetworkIsAvailable();
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all(Colors.blue),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                side: BorderSide(
                                  color: Colors.grey.shade100,
                                  width: 3.0,
                                ),
                              ),
                            ),
                          ),
                          child: const Text(
                            "Sign In",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                /*Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "I have no account...",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                          },
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),*/
              ],
            ),
          ),
        ),
      ),
      // ],
      //  ),
    );
  }

  @override
  void initState() {
    super.initState();
    retrieveSavedCredentialsList();
  }

  void retrieveSavedCredentialsList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUserName = prefs.getString('userName');
    String? savedPassword = prefs.getString('password');
    String? savedCredentialsListString = prefs.getString('userCredentialsList');

    // Initialize the userCredentialsList as an empty list
    userCredentialsList = [];

    // Check if savedCredentialsListString is not null before decoding
    if (savedCredentialsListString != null && savedCredentialsListString.isNotEmpty) {
      try {
        // Convert the saved string back to a list of maps
        List<dynamic> savedCredentialsList = json.decode(savedCredentialsListString);

        // Iterate through the list and add each credential to userCredentialsList
        for (var item in savedCredentialsList) {
          if (item is Map<String, dynamic>) {
            userCredentialsList.add(Map<String, String>.from(item));
          }
        }
      } catch (e) {
        print('Error decoding saved credentials: $e');
        // Clear the corrupted data
        await prefs.remove('userCredentialsList');
      }
    }

    if (userCredentialsList.isNotEmpty && mounted) {
      setState(() {
        userNameController.text = userCredentialsList[0]['userName'] ?? '';
        passwordController.text = userCredentialsList[0]['password'] ?? '';
      });
    }
  }

  Widget buildCredentialsList() {
    return ListView.builder(
      itemCount: userCredentialsList.length,
      itemBuilder: (context, index) {
        String userName = userCredentialsList[index]['userName'] ?? '';
        String password = userCredentialsList[index]['password'] ?? '';

        return ListTile(
          title: Text('User: $userName, Password: $password'),
          onTap: () {
            // Set the tapped credentials in the text fields
            setState(() {
              userNameController.text = userName;
              passwordController.text = password;
            });
          },
        );
      },
    );
  }

  @override
  void dispose() {
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
