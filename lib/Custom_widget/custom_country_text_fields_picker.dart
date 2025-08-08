import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

class CustomTextFieldsCountrycode extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final bool disableOrEnable;
  final int borderColor;
  final bool filled;
  final IconData? prefixIcon;
  final ValueChanged<PhoneNumber> onPhoneNumberChanged;

  const CustomTextFieldsCountrycode({
    Key? key,
    required this.controller,
    this.labelText,
    required this.hintText,
    required this.disableOrEnable,
    required this.borderColor,
    required this.filled,
    this.prefixIcon,
    required this.onPhoneNumberChanged,
  }) : super(key: key);

  @override
  State<CustomTextFieldsCountrycode> createState() =>
      _CustomTextFieldsCountrycodeState();
}

class _CustomTextFieldsCountrycodeState
    extends State<CustomTextFieldsCountrycode>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isFocused = false;
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
        if (_isFocused) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  // Outer glow effect when focused
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1 * _glowAnimation.value),
                    blurRadius: 20 * _glowAnimation.value,
                    spreadRadius: 2 * _glowAnimation.value,
                  ),
                  // Inner shadow for depth
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    // Glassmorphism background
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.25),
                        Colors.white.withOpacity(0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isFocused
                          ? Colors.white.withOpacity(0.4)
                          : Colors.white.withOpacity(0.2),
                      width: _isFocused ? 2.0 : 1.0,
                    ),
                  ),
                  child: IntlPhoneField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    languageCode: "en",
                    initialCountryCode: "BD",
                    onChanged: widget.onPhoneNumberChanged,
                    onCountryChanged: (country) {
                      print('Country changed to: ${country.name}');
                    },
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: widget.labelText,
                      hintText: widget.hintText,

                      // Remove all default borders
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,

                      contentPadding: EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),

                      // Modern label styling
                      labelStyle: TextStyle(
                        color: _isFocused
                            ? Colors.white.withOpacity(0.9)
                            : Colors.white.withOpacity(0.7),
                        fontSize: _isFocused ? 14 : 16,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),

                      // Hint text styling
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),

                      // Floating label behavior
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      floatingLabelStyle: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),

                      // Prefix icon styling
                      prefixIcon: widget.prefixIcon != null
                          ? Container(
                              margin: EdgeInsets.only(right: 12),
                              child: Icon(
                                widget.prefixIcon,
                                color: _isFocused
                                    ? Colors.white.withOpacity(0.9)
                                    : Colors.white.withOpacity(0.7),
                                size: 24,
                              ),
                            )
                          : null,

                      // Error styling
                      errorStyle: TextStyle(
                        color: Colors.redAccent.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),

                      // Filled background
                      filled: false,
                    ),

                    // Country selector styling - only use supported properties
                    dropdownTextStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),

                    // Remove unsupported properties
                    showDropdownIcon: true,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
