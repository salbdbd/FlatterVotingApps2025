import 'package:flutter/material.dart';

class CustomTextFields extends StatelessWidget {
  const CustomTextFields({
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
      padding: EdgeInsetsDirectional.fromSTEB(30, 0, 30, 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(width: 2, color: Color(0xFF000000)),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 2, color: Color(borderColor)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
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
              ? Icon(prefixIcon, color: Colors.grey)
              : null,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.black26),
          labelText: labelText,
          fillColor: Color(0xffececec),
        ),
        style: TextStyle(color: Colors.black),
        maxLines: 1,
        minLines: 1,
        obscureText: obscureText,
      ),
    );
  }
}
