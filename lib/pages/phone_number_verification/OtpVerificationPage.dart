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

  const OtpVerificationPage({
    Key? key,
    required this.phoneNumber,
    required this.countryCode,
    this.userDetails,
  }) : super(key: key);

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  Timer? _typingTimer;

  List<TextEditingController> otpControllers =
      List.generate(6, (index) => TextEditingController());
  List<FocusNode> otpFocusNodes = List.generate(6, (index) => FocusNode());

  final auth = LocalAuthentication();
  String authorized = "not authorized";
  bool _canCheckBiometric = false;
  late List<BiometricType> _availableBiometric = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkBiometric();
    _getAvailableBiometric();
    _setupOtpListeners();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _colorAnimation.addListener(() {
      if (mounted) setState(() {});
    });

    _controller.repeat(reverse: true);
  }

  void _setupOtpListeners() {
    for (int i = 0; i < otpControllers.length; i++) {
      otpControllers[i].addListener(() {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _typingTimer?.cancel();

    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var focusNode in otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (!_canCheckBiometric || _availableBiometric.isEmpty) {
      _showSnackBar('Biometric authentication not available', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool authenticated = false;

    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Please verify your identity to continue',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      print('Authentication error: $e');
      _showSnackBar('Authentication failed: ${e.message}', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    if (authenticated) {
      _navigateToVotingPage();
      _showSnackBar('Authentication successful!', Colors.green);
    } else {
      _showSnackBar('Authentication failed', Colors.red);
    }
  }

  Future<void> _checkBiometric() async {
    try {
      bool canCheckBiometric = await auth.canCheckBiometrics;
      if (mounted) {
        setState(() {
          _canCheckBiometric = canCheckBiometric;
        });
      }
    } on PlatformException catch (e) {
      print('Error checking biometrics: $e');
    }
  }

  Future<void> _getAvailableBiometric() async {
    try {
      List<BiometricType> availableBiometric =
          await auth.getAvailableBiometrics();
      if (mounted) {
        setState(() {
          _availableBiometric = availableBiometric;
        });
      }
    } on PlatformException catch (e) {
      print('Error getting available biometrics: $e');
    }
  }

  Future<void> _verifyOTP() async {
    String enteredOTP =
        otpControllers.map((controller) => controller.text).join();

    if (enteredOTP.length < 6) {
      _showSnackBar('Please enter complete OTP', Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (enteredOTP == "223344") {
      _navigateToVotingPage();
      _showSnackBar('OTP verified successfully!', Colors.green);
    } else {
      _showSnackBar('Invalid OTP. Please try again.', Colors.red);
      _clearOTP();
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _clearOTP() {
    for (var controller in otpControllers) {
      controller.clear();
    }
    otpFocusNodes[0].requestFocus();
  }

  void _navigateToVotingPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => VotingPage(userDetails: widget.userDetails),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty) {
      // Move to next field
      if (index < 5) {
        otpFocusNodes[index + 1].requestFocus();
      } else {
        // Last field, remove focus
        otpFocusNodes[index].unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      // Move to previous field if current is empty
      otpFocusNodes[index - 1].requestFocus();
    }

    // Auto-verify when all fields are filled
    String currentOtp =
        otpControllers.map((controller) => controller.text).join();
    if (currentOtp.length == 6) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _verifyOTP();
      });
    }
  }

  Widget _buildOtpField(int index) {
    return Container(
      width: 45,
      height: 55,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: otpControllers[index].text.isNotEmpty
              ? Colors.blue
              : Colors.grey.withOpacity(0.5),
          width: 2.0,
        ),
        color: Colors.white.withOpacity(0.1),
      ),
      child: TextField(
        controller: otpControllers[index],
        focusNode: otpFocusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) => _onOtpChanged(value, index),
        onTap: () {
          // Clear and focus current field
          otpControllers[index].selection = TextSelection.fromPosition(
            TextPosition(offset: otpControllers[index].text.length),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3C3E52),
      resizeToAvoidBottomInset: true, // Important for keyboard handling
      body: SafeArea(
        child: Stack(
          children: [
            // Background animation
            Positioned.fill(
              child: Lottie.asset(
                'assets/Images/dot pattern background.json',
                fit: BoxFit.contain,
              ),
            ),

            // Main content
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Top spacing
                      const SizedBox(height: 60),

                      // Animated title
                      AnimatedDefaultTextStyle(
                        duration: const Duration(seconds: 1),
                        style: TextStyle(
                          color: _colorAnimation.value,
                          fontSize: 70.0,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text("Vote"),
                      ),

                      const SizedBox(height: 40),

                      // Instructions
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: TypingTextAnimation(
                          phoneNumber: widget.phoneNumber,
                          countryCode: widget.countryCode,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // OTP input fields
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                              6, (index) => _buildOtpField(index)),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Verify button
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _verifyOTP,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 5,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Verify OTP",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Biometric authentication option
                      if (_canCheckBiometric && _availableBiometric.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            children: [
                              const Text(
                                "Or use biometric authentication",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 10),
                              IconButton(
                                onPressed: _isLoading ? null : _authenticate,
                                icon: Icon(
                                  _availableBiometric
                                          .contains(BiometricType.fingerprint)
                                      ? Icons.fingerprint
                                      : Icons.face,
                                  size: 40,
                                  color: Colors.white,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.blue.withOpacity(0.2),
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(15),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Bottom spacing
                      const Spacer(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TypingTextAnimation extends StatefulWidget {
  final String phoneNumber;
  final String countryCode;

  const TypingTextAnimation({
    Key? key,
    required this.phoneNumber,
    required this.countryCode,
  }) : super(key: key);

  @override
  _TypingTextAnimationState createState() => _TypingTextAnimationState();
}

class _TypingTextAnimationState extends State<TypingTextAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _restartTimer;
  String displayedText = "";

  static const String baseText =
      "Please enter the 6-digit verification code sent to your phone number: ";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _controller.addListener(() {
      if (mounted) {
        setState(() {
          int charCount = (_controller.value * baseText.length).floor();
          displayedText = baseText.substring(0, charCount);
        });
      }
    });

    _startAnimation();
  }

  void _startAnimation() {
    _controller.forward();

    _restartTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) {
        _controller.reset();
        _startAnimation();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _restartTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24),
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: "${widget.countryCode} ${widget.phoneNumber}",
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
