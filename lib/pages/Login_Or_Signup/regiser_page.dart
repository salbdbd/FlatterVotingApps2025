import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:lottie/lottie.dart';
import '../../Custom_widget/custom_text_field.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey();
  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppBar(
                        backgroundColor: Colors.transparent,
                        leading: IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginPage(),
                                ));
                          },
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                        ),
                        elevation: 0,
                      ),
                      Column(
                        children: [
                          Container(
                            height: 180,
                            width: 180,
                            child: Lottie.asset(
                              'assets/Images/animation_login.json',
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          CustomTextFields(
                            controller: userNameController,
                            labelText: 'User Name',
                            hintText: 'User Name',
                            disableOrEnable: true,
                            borderColor: 0xFFBCC2C2,
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
                          ),
                          CustomTextFields(
                            controller: confirmPasswordController,
                            labelText: 'ConfirmPassword',
                            hintText: 'Confirm Password',
                            disableOrEnable: true,
                            borderColor: 0xFFBCC2C2,
                            filled: false,
                            prefixIcon: Icons.password_rounded,
                          ),
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(30, 0, 30, 10),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  IntlPhoneField(
                                    focusNode: focusNode,
                                    decoration: InputDecoration(
                                      labelText: 'Phone Number',
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          width: 2,
                                          color: Colors
                                              .white, // Set the border color to white
                                        ),
                                      ),

                                      labelStyle: TextStyle(
                                          color: Colors
                                              .white), // Set the label text color to white
                                      prefixStyle: TextStyle(
                                          color: Colors
                                              .white), // Set the prefix (e.g., '+') text color to white
                                      hintStyle: TextStyle(
                                          color: Colors
                                              .black), // Set the hint text color to white
                                      prefixIconColor: Colors.white,
                                    ),
                                    languageCode: "en",
                                    onChanged: (phone) {
                                      print(phone.completeNumber);
                                    },
                                    onCountryChanged: (country) {
                                      print('Country changed to: ' +
                                          country.name);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  _formKey.currentState?.validate();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LoginPage(),
                                      ));
                                },
                                child: Text(
                                  "Sign Up",
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "I have an account...",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginPage(),
                                  ));
                            },
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 20,
                              ),
                            ),
                          )
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
}
