import 'package:flutter/material.dart';

class CustomTextFieldsforProfile extends StatelessWidget {
  const CustomTextFieldsforProfile({
    Key? key,
    this.controller,
    required this.hintText,
    required this.disableOrEnable,
    required this.labelText,
    required this.borderColor,
    required this.filled,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.obscureText = false,
  }) : super(key: key);

  final TextEditingController? controller;
  final String hintText;
  final String labelText;
  final bool disableOrEnable;
  final int borderColor;
  final bool filled;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon; // Change the type to Widget
  final VoidCallback? onSuffixIconPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
      child: Container(
        color: Color(0xff15212D),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 2, color: Color(0xFFFFFFFF)),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 2, color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 2, color: Colors.blueAccent),
            ),
            enabled: disableOrEnable,

            filled: filled,
            suffixIcon: suffixIcon != null
                ? GestureDetector(
              onTap: onSuffixIconPressed,
              child: suffixIcon,
            )
                : null,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.white)
                : null,
            hintText: hintText,
            labelText: labelText,
            labelStyle: TextStyle(color: Colors.yellow),
            //Color(0xFF3C3E52)
          ),
          style: TextStyle(color: Colors.white),
          maxLines: 1,
          minLines: 1,
          obscureText: obscureText,
        ),
      ),
    );
  }
}
