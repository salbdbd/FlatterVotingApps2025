import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';
import '../indexing_page/indexing_page.dart';
import '../voting_page/voting_page.dart';

class OtpVerificationPage extends StatefulWidget {
  final UserDetails? userDetails;
  final String phoneNumber;
  final String countryCode;
  const OtpVerificationPage(
      {Key? key,
      required this.phoneNumber,
      required this.countryCode,
      this.userDetails})
      : super(key: key);

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  TextEditingController phoneNumberController = TextEditingController();

  List<TextEditingController> otpControllers =
      List.generate(6, (index) => TextEditingController());

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
    for (var controller in otpControllers) {
      controller.dispose();
    }
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
        // If authentication is successful, navigate to the homepage
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => VotingPage(
                      userDetails: widget.userDetails,
                    )));

        // Display a snackbar message
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

/*  @override
  void initState() {
    _checkBiometric();
    _getAvailableBiometric();

    super.initState();
  }*/

  Future<void> _verifyOTP() async {
    // Get the entered OTP from controllers
    String enteredOTP =
        otpControllers.map((controller) => controller.text).join();

    // Compare with the expected OTP (e.g., "223344")
    if (enteredOTP == "223344") {
      // OTP is correct, navigate to VotingPage with userDetails
      _navigateToVotingPage();

      // Display a snackbar message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Correct OTP. Thanks.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Incorrect OTP, show an error message or handle accordingly
      // For example, you can display a SnackBar with an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incorrect OTP. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToVotingPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => VotingPage(userDetails: widget.userDetails),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("Fingerprint Auth")),
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
            //margin: EdgeInsets.symmetric(horizontal: 50),
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
                          color:
                              _colorAnimation.value, // Use the animated color
                          fontSize: 70.0,
                          fontWeight: FontWeight.bold,
                        ),
                        child: Text("Vote"),
                      ),

                      SizedBox(
                        height: 50,
                      ),

                      // OTP code box

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          6,
                          (index) => Container(
                            width: 40,
                            height: 40,
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: otpControllers[index].text.isNotEmpty
                                      ? Colors.blue
                                      : Colors.red,
                                  width: otpControllers[index].text.isNotEmpty
                                      ? 3.0
                                      : 3.0,
                                ),
                              ),
                            ),
                            child: TextField(
                              controller: otpControllers[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                              decoration: InputDecoration(
                                counterText: '',
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                // Custom logic when OTP is entered
                                // For example, you can move focus to the next box
                                if (value.isNotEmpty && index < 5) {
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        height: 40.0, // Set the desired height
                        width: 200.0, // Set the desired width
                        child: ElevatedButton(
                          onPressed: () {
                            _verifyOTP();
                            // Add your phone verification logic here
                            // For example, you can navigate to a new screen for OTP input
                            //Navigator.push(context, MaterialPageRoute(builder: (context) => FingerprintAuth()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.green, // Set the background color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10.0), // Set the border radius
                            ),
                          ),
                          child: Text(
                            "Verify OTP",
                            style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15.0),
                  child: TypingTextAnimation(
                      phoneNumber: widget.phoneNumber,
                      countryCode: widget.countryCode),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TypingTextAnimation extends StatefulWidget {
  final String phoneNumber;
  final String countryCode;

  const TypingTextAnimation(
      {Key? key, required this.phoneNumber, required this.countryCode})
      : super(key: key);

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
        "$displayedText ${widget.countryCode} ${widget.phoneNumber}",
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white, height: 1.5, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final String text =
      "Please kindly input valid Verification code from your phone number:";
}
