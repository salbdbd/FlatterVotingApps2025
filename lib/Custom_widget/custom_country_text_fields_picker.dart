import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

class CustomTextFieldsCountrycode extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final bool disableOrEnable;
  final int borderColor;
  final bool filled;
  final IconData? prefixIcon;
  final ValueChanged<PhoneNumber> onPhoneNumberChanged; // Change the type

  CustomTextFieldsCountrycode({
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.disableOrEnable,
    required this.borderColor,
    required this.filled,
    this.prefixIcon,
    required this.onPhoneNumberChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(30, 0, 30, 10),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            IntlPhoneField(
              decoration: InputDecoration(
                labelText: labelText,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: Colors.black, // Set the border color to white
                  ),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: Colors.black, // Set the border color to white
                  ),
                ),
                labelStyle: const TextStyle(color: Colors.black), // Set the label text color to white
                prefixStyle: const TextStyle(color: Colors.black), // Set the prefix (e.g., '+') text color to white
                hintStyle: const TextStyle(color: Colors.black), // Set the hint text color to white
                prefixIconColor: Colors.grey,
              ),
              languageCode: "en",
              onChanged: onPhoneNumberChanged,
              controller: controller,
              onCountryChanged: (country) {
                print('Country changed to: ' + country.name);
              },
              initialCountryCode: "BD", // Set the initial country code to Bangladesh
            ),
          ],
        ),
      ),
    );
  }
}



/*import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

class CustomTextFieldsCountrycode extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final bool disableOrEnable;
  final int borderColor;
  final bool filled;
  final IconData prefixIcon;
  final ValueChanged<PhoneNumber> onPhoneNumberChanged; // Change the type

  CustomTextFieldsCountrycode({
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.disableOrEnable,
    required this.borderColor,
    required this.filled,
    required this.prefixIcon,
    required this.onPhoneNumberChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(30, 0, 30, 10),
      child: IntlPhoneField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 2, color: Color(0xFFFFFFFF)),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 2, color: Color(borderColor)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 2, color: Colors.blueAccent),
          ),
          filled: filled,
          prefixIcon: Icon(prefixIcon, color: Colors.white),
          hintText: hintText,
          labelText: labelText,
          fillColor: Color(0xffececec),
          // Add errorText to handle invalid mobile number
          errorText: _validatePhoneNumber(controller.text)
              ? null
              : 'Invalid mobile number',
        ),
        controller: controller,
        initialCountryCode: 'BD', // Initial country code, change as needed
        onChanged: onPhoneNumberChanged,
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  // Validate the entered phone number
  bool _validatePhoneNumber(String phoneNumber) {
    // Add your custom validation logic here
    // For example, you can use a regular expression to check for a valid phone number
    // In this example, it checks if the length is greater than 6
    return phoneNumber.length > 6;
  }
}
*/