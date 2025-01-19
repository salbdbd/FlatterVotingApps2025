import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';
import '../../Custom_widget/custom_country_text_fields_picker.dart';
import '../../methods/common_methods.dart';
import '../indexing_page/indexing_page.dart';
import '../voting_page/voting_page.dart';
import 'OtpVerificationPage.dart';

class SandOtpPage extends StatefulWidget {
  final UserDetails? userDetails;
  const SandOtpPage({Key? key, this.userDetails}) : super(key: key);

  @override
  _SandOtpPageState createState() => _SandOtpPageState();
}

class _SandOtpPageState extends State<SandOtpPage>
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
      duration: Duration(seconds: 2),
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
            context, MaterialPageRoute(builder: (context) => VotingPage()));

        final snackBar = SnackBar(
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
      backgroundColor: Color(0xFF3C3E52),
      body: Stack(
        children: [
          Lottie.asset(
            'assets/Images/login_page_animation.json',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(),
                Container(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(seconds: 1),
                        style: TextStyle(
                          color: _colorAnimation.value,
                          fontSize: 70.0,
                          fontWeight: FontWeight.bold,
                        ),
                        child: Text("Vote"),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      CustomTextFieldsCountrycode(
                        controller: phoneNumberController,
                        labelText: 'Phone Number',
                        hintText: 'Phone Number',
                        disableOrEnable: true,
                        borderColor: 0xFFBCC2C2,
                        filled: false,
                        prefixIcon: Icons.contact_phone,
                        onPhoneNumberChanged: (PhoneNumber phoneNumber) {
                          setState(() {
                            isPhoneNumberValid =
                                _isValidPhoneNumber(phoneNumber.completeNumber);
                            countryCode = phoneNumber.countryCode;
                          });
                          print(
                              'Selected Phone Number: ${phoneNumber.completeNumber}');
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
                                  builder: (context) => OtpVerificationPage(
                                    userDetails: widget.userDetails,
                                    phoneNumber: phoneNumberController.text,
                                    countryCode: countryCode,
                                  ),
                                ),
                              );
                              int compId = widget.userDetails
                                      ?.selectedCompanyData.compId ??
                                  0;
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
                          child: Text(
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
                  margin: EdgeInsets.symmetric(vertical: 15.0),
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
      duration: Duration(seconds: 2),
    );
    _controller.forward();
    startTimer();
  }

  void startTimer() {
    Timer(Duration(seconds: 5), () {
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
      margin: EdgeInsets.symmetric(vertical: 15.0),
      child: Text(
        displayedText,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, height: 1.5),
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
