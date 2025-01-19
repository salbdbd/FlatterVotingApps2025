import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:local_auth/local_auth.dart';

import '../../../Custom_widget/custom_country_text_fields_picker.dart';
import '../../../methods/common_methods.dart';
import 'ForgetOtpVerificationPage.dart';

class ForgetSandOtpPage extends StatefulWidget {
  const ForgetSandOtpPage({Key? key}) : super(key: key);

  @override
  _ForgetSandOtpPageState createState() => _ForgetSandOtpPageState();
}

class _ForgetSandOtpPageState extends State<ForgetSandOtpPage>
    with SingleTickerProviderStateMixin {
  bool isPhoneNumberValid = false;
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  CommonMethods cMethods = CommonMethods();

  TextEditingController phoneNumberController = TextEditingController();
  String countryCode = ''; // Store the country code

  @override
  void initState() {
    super.initState();

    _checkBiometric();
    _getAvailableBiometric();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(_controller);

    _colorAnimation.addListener(() {
      setState(() {});
    });

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final auth = LocalAuthentication();
  String authorized = " not authorized";
  bool _canCheckBiometric = false;
  late List<BiometricType> _availableBiometric;

  Future<void> _authenticate() async {
    bool authenticated = false;

    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Let OS determine authentication method',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (e) {
      print(e);
    }

    setState(() {
      authorized =
          authenticated ? "Authorized success" : "Failed to authenticate";
      print(authorized);

      if (authenticated) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ForgetOtpVerificationPage(
                      phoneNumber: '',
                      countryCode: '',
                    )));

        final snackBar = const SnackBar(
          content: Text('Authentication successful'),
          backgroundColor: Colors.green,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }

  Future<void> _checkBiometric() async {
    bool canCheckBiometric = false;

    try {
      canCheckBiometric = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    setState(() {
      _canCheckBiometric = canCheckBiometric;
    });
  }

  Future _getAvailableBiometric() async {
    List<BiometricType> availableBiometric = [];

    try {
      availableBiometric = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }

    setState(() {
      _availableBiometric = availableBiometric;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3C3E52),
      body: Stack(
        children: [
          Container(
            //   color: Colors.transparent,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              Colors.blue.shade100,
              Colors.blueGrey.shade100,
              Colors.blue.shade100
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),
                Container(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(seconds: 1),
                        style: TextStyle(
                          color: _colorAnimation.value,
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                        child: const Text("Forget your password?"),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      CustomTextFieldsCountrycode(
                        controller: phoneNumberController,
                        labelText: 'Phone Number',
                        hintText: 'Phone Number',
                        disableOrEnable: true,
                        borderColor: 0xFF000000,
                        filled: false,
                        onPhoneNumberChanged: (PhoneNumber phoneNumber) {
                          setState(() {
                            isPhoneNumberValid =
                                _isValidPhoneNumber(phoneNumber.completeNumber);
                            countryCode = phoneNumber.countryCode;
                          });

                          // Access phoneNumberController here
                          print(
                              'Selected Phone Number: ${phoneNumberController.text}');
                        },
                      ),
                      Container(
                        height: 40.0,
                        width: 200.0,
                        child: ElevatedButton(
                          onPressed: () {
                            if (isPhoneNumberValid) {
                              cMethods.displaySnackBarGreen(
                                  "OTP code sent successfully", context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ForgetOtpVerificationPage(
                                    phoneNumber: phoneNumberController.text,
                                    countryCode: countryCode,
                                  ),
                                ),
                              );
                            } else {
                              cMethods.displaySnackBarRed(
                                  "Please give a valid phone number", context);
                              print('Invalid phone number');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: const Text(
                            "Send OTP",
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 15.0),
                  child: TypingTextAnimation(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    return phoneNumber.length > 6;
  }
}

class TypingTextAnimation extends StatefulWidget {
  @override
  _TypingTextAnimationState createState() => _TypingTextAnimationState();
}

class _TypingTextAnimationState extends State<TypingTextAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String displayedText = "";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _controller.forward();
    startTimer();
  }

  void startTimer() {
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _controller.reset();
          _controller.forward();
        });
        startTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int charCount = (_controller.value * text.length).floor();
    displayedText = text.substring(0, charCount);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15.0),
      child: Text(
        displayedText,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.blue, height: 1.5),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final String text = "Please kindly send Verification code your phone number";
}
