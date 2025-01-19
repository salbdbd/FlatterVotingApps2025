import 'package:association/pages/Login_Or_Signup/login_page.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../Custom_widget/custom_text_field.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController reNewPasswordController = TextEditingController();

  bool passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Your background animation or image
          Lottie.asset(
            'assets/Images/login_page_animation.json',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SingleChildScrollView(
            child: Container(
              height: screenHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Your app bar and logo
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppBar(
                        backgroundColor: Colors.transparent,
                        leading: IconButton(
                            onPressed: () {
                              // Navigate back or handle the back button
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.arrow_back_ios,
                                color: Colors.white)),
                        elevation: 0,
                      ),
                      Column(
                        children: [
                          // Your logo animation or image
                          Container(
                            height: 180,
                            width: 180,
                            child: Lottie.asset(
                              'assets/Images/animation_login.json',
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 20),
                          // Custom text field for username
                          CustomTextFields(
                            controller: newPasswordController,
                            labelText: 'New Password',
                            hintText: 'New Password',
                            disableOrEnable: true,
                            borderColor: 0xFFBCC2C2,
                            filled: false,
                            prefixIcon: Icons.password_rounded,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  // Toggle the visibility of the password
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

                          CustomTextFields(
                            controller: reNewPasswordController,
                            labelText: 'Re New Password',
                            hintText: 'Re New Password',
                            disableOrEnable: true,
                            borderColor: 0xFFBCC2C2,
                            filled: false,
                            prefixIcon: Icons.password_rounded,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  // Toggle the visibility of the password
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
                        ],
                      ),
                    ],
                  ),
                  // Your "Sign In" and "Sign Up" buttons
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // Implement the logic for sending OTP or other actions
                                  sendOtp();
                                },
                                child: Text(
                                  "Continue",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                      Colors.transparent),
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      side: BorderSide(
                                        color: Colors.white,
                                        width: 3.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Your "Sign Up" link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Remember your password? ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to the login page
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()),
                              );
                            },
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void sendOtp() {
    // Implement the logic for sending OTP here
    // You can navigate to the OTP verification page or perform other actions
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}
