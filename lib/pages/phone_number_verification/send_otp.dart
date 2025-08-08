import 'dart:async';
import 'dart:math';
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
    with TickerProviderStateMixin {
  bool isPhoneNumberValid = false;
  late AnimationController _titleController;
  late AnimationController _floatingController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;

  CommonMethods cMethods = CommonMethods();
  TextEditingController phoneNumberController = TextEditingController();
  String countryCode = '';
  final ScrollController _scrollController = ScrollController();
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
    _getAvailableBiometric();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Title animation controller
    _titleController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    // Floating elements controller
    _floatingController = AnimationController(
      duration: Duration(milliseconds: 4000),
      vsync: this,
    );

    // Slide animation controller
    _slideController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    // Define animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(_floatingController);

    // Start animations
    _titleController.repeat(reverse: true);
    _floatingController.repeat();
    _slideController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _floatingController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
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
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } on PlatformException catch (e) {
      print(e);
    }

    setState(() {
      authorized =
          authenticated ? "Authorized success" : "Failed to authenticate";
      if (authenticated) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VotingPage()),
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
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final bool isKeyboardOpen = mediaQuery.viewInsets.bottom > 0;
    final double screenHeight = mediaQuery.size.height;
    final double screenWidth = mediaQuery.size.width;
    final bool isSmallScreen = screenHeight < 700;

    // Update keyboard visibility state
    if (_isKeyboardVisible != isKeyboardOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _isKeyboardVisible = isKeyboardOpen;
        });
      });
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFF1e3c72),
              Color(0xFF2a5298),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles (reduce when keyboard is open)
            if (!isKeyboardOpen)
              ...List.generate(
                isSmallScreen ? 8 : 15,
                (index) =>
                    _buildFloatingParticle(index, screenWidth, screenHeight),
              ),

            // Glassmorphism overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
              ),
            ),

            // Main scrollable content
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    controller: _scrollController,
                    physics: ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth > 600 ? 48.0 : 24.0,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Top section with title
                              Flexible(
                                flex: isKeyboardOpen ? 1 : 2,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        height: isKeyboardOpen
                                            ? 20
                                            : (isSmallScreen ? 40 : 60)),

                                    // Animated title (smaller when keyboard is open)
                                    AnimatedBuilder(
                                      animation: _titleController,
                                      builder: (context, child) {
                                        double titleSize = isKeyboardOpen
                                            ? (isSmallScreen ? 40 : 50)
                                            : (isSmallScreen ? 60 : 72);

                                        return Transform.scale(
                                          scale: 1.0 +
                                              (_titleController.value * 0.05),
                                          child: ShaderMask(
                                            shaderCallback: (bounds) =>
                                                LinearGradient(
                                              colors: [
                                                Colors.white,
                                                Color(0xFFf093fb),
                                                Color(0xFFf5576c),
                                                Colors.white,
                                              ],
                                              stops: [0.0, 0.3, 0.7, 1.0],
                                            ).createShader(bounds),
                                            child: Text(
                                              "Vote",
                                              style: TextStyle(
                                                fontSize: titleSize,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                                letterSpacing: titleSize / 20,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    if (!isKeyboardOpen) ...[
                                      SizedBox(height: isSmallScreen ? 10 : 20),

                                      // Subtitle with fade animation
                                      FadeTransition(
                                        opacity: _fadeAnimation,
                                        child: Text(
                                          "Secure Verification",
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.8),
                                            fontSize: isSmallScreen ? 16 : 18,
                                            fontWeight: FontWeight.w300,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Phone input card - always visible
                              Flexible(
                                flex: 2,
                                child: SlideTransition(
                                  position: _slideAnimation,
                                  child: ScaleTransition(
                                    scale: _scaleAnimation,
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: double.infinity,
                                      constraints: BoxConstraints(
                                        maxWidth: 400,
                                      ),
                                      padding: EdgeInsets.all(
                                          isSmallScreen ? 24 : 32),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white.withOpacity(0.2),
                                            Colors.white.withOpacity(0.1),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.2),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 20,
                                            offset: Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Phone number input
                                            Center(
                                              child:
                                                  CustomTextFieldsCountrycode(
                                                controller:
                                                    phoneNumberController,
                                                // labelText: 'Phone Number',
                                                hintText:
                                                    'Enter your phone number',
                                                disableOrEnable: true,
                                                borderColor: 0x00FFFFFF,
                                                filled: false,
                                                prefixIcon:
                                                    Icons.phone_outlined,
                                                onPhoneNumberChanged:
                                                    (PhoneNumber phoneNumber) {
                                                  setState(() {
                                                    isPhoneNumberValid =
                                                        _isValidPhoneNumber(
                                                            phoneNumber
                                                                .completeNumber);
                                                    countryCode =
                                                        phoneNumber.countryCode;
                                                  });
                                                },
                                              ),
                                            ),

                                            SizedBox(
                                                height:
                                                    isSmallScreen ? 20 : 32),

                                            // Send OTP button with modern styling
                                            Container(
                                              width: double.infinity,
                                              height: isSmallScreen ? 50 : 56,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  // Dismiss keyboard first
                                                  FocusScope.of(context)
                                                      .unfocus();

                                                  if (isPhoneNumberValid) {
                                                    cMethods.displaySnackBarGreen(
                                                        "OTP code sent successfully",
                                                        context);
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            OtpVerificationPage(
                                                          userDetails: widget
                                                              .userDetails,
                                                          phoneNumber:
                                                              phoneNumberController
                                                                  .text,
                                                          countryCode:
                                                              countryCode,
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    cMethods.displaySnackBarRed(
                                                        "Please enter a valid phone number",
                                                        context);
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  shadowColor:
                                                      Colors.transparent,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                ),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Color(0xFF667eea),
                                                        Color(0xFF764ba2),
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Color(0xFF667eea)
                                                            .withOpacity(0.3),
                                                        blurRadius: 12,
                                                        offset: Offset(0, 6),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "Send OTP",
                                                      style: TextStyle(
                                                        fontSize: isSmallScreen
                                                            ? 16
                                                            : 18,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white,
                                                        letterSpacing: 1,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Bottom section with animated text (hidden when keyboard is open)
                              if (!isKeyboardOpen)
                                Flexible(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      SizedBox(height: isSmallScreen ? 20 : 40),

                                      // Animated typing text
                                      FadeTransition(
                                        opacity: _fadeAnimation,
                                        child: ModernTypingTextAnimation(
                                          isSmallScreen: isSmallScreen,
                                        ),
                                      ),

                                      SizedBox(height: isSmallScreen ? 20 : 40),
                                    ],
                                  ),
                                ),

                              // Add some padding at bottom when keyboard is open
                              if (isKeyboardOpen) SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingParticle(
      int index, double screenWidth, double screenHeight) {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        double animationValue = _floatingController.value + (index * 0.1);
        double x =
            screenWidth * (0.1 + 0.8 * sin(animationValue * 2 * pi + index));
        double y =
            screenHeight * (0.1 + 0.8 * cos(animationValue * pi + index * 0.5));

        return Positioned(
          left: x,
          top: y,
          child: Transform.rotate(
            angle: _rotationAnimation.value + index,
            child: Container(
              width: 4 + (index % 3) * 2,
              height: 4 + (index % 3) * 2,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.6),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    return phoneNumber.length > 6;
  }
}

class ModernTypingTextAnimation extends StatefulWidget {
  final bool isSmallScreen;

  const ModernTypingTextAnimation({
    Key? key,
    this.isSmallScreen = false,
  }) : super(key: key);

  @override
  _ModernTypingTextAnimationState createState() =>
      _ModernTypingTextAnimationState();
}

class _ModernTypingTextAnimationState extends State<ModernTypingTextAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String displayedText = "";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );

    _controller.addListener(() {
      setState(() {});
    });

    _startAnimation();
  }

  void _startAnimation() {
    _controller.forward().then((_) {
      _timer = Timer(Duration(seconds: 2), () {
        if (mounted) {
          _controller.reset();
          _startAnimation();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    int charCount = (_controller.value * text.length).floor();
    displayedText = text.substring(0, charCount);

    return Container(
      constraints: BoxConstraints(maxWidth: 350),
      padding: EdgeInsets.symmetric(
        horizontal: widget.isSmallScreen ? 16 : 24,
        vertical: widget.isSmallScreen ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Text(
              displayedText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: widget.isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w400,
                height: 1.4,
                letterSpacing: 0.5,
              ),
            ),
          ),
          if (_controller.value < 1.0)
            Container(
              width: 2,
              height: widget.isSmallScreen ? 16 : 20,
              margin: EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  final String text = "Please verify your phone number to continue";
}
