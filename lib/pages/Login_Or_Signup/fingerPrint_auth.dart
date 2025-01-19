import 'dart:async';

import 'package:association/pages/indexing_page/get_usercompay_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';

import '../../models/login.dart';
import '../dashboard.dart';
import '../indexing_page/indexing_page.dart';
import '../voting_page/voting_page.dart';

class FingerprintAuth extends StatefulWidget {
  final UserDetails? userDetails;
  final VotingCandidate? candidate;

  const FingerprintAuth({
    Key? key,
    this.userDetails,
    this.candidate,
  }) : super(key: key);

  @override
  _FingerprintAuthState createState() => _FingerprintAuthState();
}

class _FingerprintAuthState extends State<FingerprintAuth>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    if (widget.candidate != null) {
      VotingCandidate candidate = widget.candidate!;
      print(
          'Candidate ID: ${candidate.candidateID}, Name: ${candidate.memberName}');
    }

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
          context,
          MaterialPageRoute(
            builder: (context) => Dashboard(
              userDetails: widget.userDetails ??
                  UserDetails(
                      userData: Login(),
                      selectedCompanyData: GetUserCompanyModel()),
            ),
          ),
        );

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

  Future<void> _getAvailableBiometric() async {
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
            margin: EdgeInsets.symmetric(horizontal: 50),
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
                      GestureDetector(
                        onTap: _authenticate,
                        child: Center(
                          child: Icon(
                            Icons.fingerprint_outlined,
                            size: 100,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        "Fingerprint Verification",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
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

  final String text =
      "Authenticate using your fingerprint instead of your password";
}



/*import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';

import '../dashboard.dart';
import '../indexing_page/indexing_page.dart';
import '../voting_page/voting_page.dart';


class FingerprintAuth extends StatefulWidget {
  final UserDetails? userDetails;
  final VotingCandidate? candidate;
  const FingerprintAuth({
    Key? key,
     this.userDetails,
    this.candidate,
  }) : super(key: key);

  @override
  _FingerprintAuthState createState() => _FingerprintAuthState();
}

class _FingerprintAuthState extends State<FingerprintAuth>
    with SingleTickerProviderStateMixin{


  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;


  @override
  void initState() {
    super.initState();

    if (widget.candidate != null) {
      VotingCandidate candidate = widget.candidate!;
      print('Candidate ID: ${candidate.candidateID}, Name: ${candidate.memberName}');
    }

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
        // If authentication is successful, navigate to the homepage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Dashboard(
              userDetails: widget.userDetails ?? UserDetails(userData: {}, selectedCompanyData: {}), // Provide a default value
            ),
          ),
        );

        // Display a snackbar message
        final snackBar = SnackBar(
          content: Text('Authentication successful'),
          backgroundColor: Colors.green,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }

  /*Future<void> _authenticate() async {
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

    if (authenticated) {
      // Retrieve and save the biometric data
      final biometricData = await auth.authenticate(localizedReason: '');

      // Convert the biometric data to a byte string
      final byteString = base64Encode(biometricData as List<int>);

      print("Biometric Data: $byteString");

      // Save the byte string to storage or use it as needed

      // If authentication is successful, navigate to the homepage
      Navigator.pushReplacementNamed(context, '/loginpage');

      // Display a snackbar message
      final snackBar = SnackBar(
        content: Text('Authentication successful'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    setState(() {
      authorized = authenticated ? "Authorized success" : "Failed to authenticate";
      print(authorized);
    });
  }*/

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
            margin: EdgeInsets.symmetric(horizontal: 50),
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
                          color: _colorAnimation.value, // Use the animated color
                          fontSize: 70.0,
                          fontWeight: FontWeight.bold,
                        ),
                        child: Text("Vote"),
                      ),

                      SizedBox(height: 50,),

                      GestureDetector(
                        onTap: _authenticate,
                        child: Center(
                            child: Icon(
                              Icons.fingerprint_outlined,
                              size: 100,
                              color: Colors.green,
                            )
                        ),
                      ),

                      SizedBox(height: 30,),
                      Text(
                        "Fingerprint Verification",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
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
}






class TypingTextAnimation extends StatefulWidget {
  @override
  _TypingTextAnimationState createState() => _TypingTextAnimationState();
}

class _TypingTextAnimationState extends State<TypingTextAnimation>
    with SingleTickerProviderStateMixin{
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
        startTimer(); // Restart the timer
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

  final String text = "Authenticate using your fingerprint instead of your password";
}*/