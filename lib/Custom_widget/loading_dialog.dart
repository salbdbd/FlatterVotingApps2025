import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget
{
  String messageText;

  LoadingDialog({super.key, required this.messageText,});

  @override
  Widget build(BuildContext context)
  {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)
      ),
      backgroundColor: Colors.black87,
      child: Container(
        margin:  const EdgeInsets.all(10),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white60,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(width: 8,),

              Text(
                messageText,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



//LoadingDialog(messageText: "Register your account..."),  //Implementation