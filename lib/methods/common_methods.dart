
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CommonMethods
{
  /*checkConnectivity(BuildContext context) async
  {
    var connectionResult = await Connectivity().checkConnectivity();
    if (connectionResult != ConnectivityResult.mobile && connectionResult != ConnectivityResult.wifi)
    {
      if(!context.mounted) return;
      displaySnackBarRed("Your Internet is not Available. Check Your connection. Try Again.", context);
    }
  }

    Future<bool> checkConnectivity(BuildContext context) async {
    var connectionResult = await Connectivity().checkConnectivity();
    if (connectionResult != ConnectivityResult.mobile && connectionResult != ConnectivityResult.wifi) {
      if (!context.mounted) return false;
      displaySnackBarRed("Your Internet is not Available. Check Your connection. Try Again.", context);
      return false;
    }
    return true;
  }


  */



  Future<bool> checkConnectivity(BuildContext context) async {
    try {
      var connectionResult = await Connectivity().checkConnectivity();

      if (connectionResult[0] != ConnectivityResult.mobile && connectionResult[0] != ConnectivityResult.wifi) {
        displaySnackBarRed("Your Internet is not Available. Check Your connection. Try Again.", context);
       print("Connectivity result : ${connectionResult[0]}");
       print("wifi: ${ConnectivityResult.wifi}");
       return false;
      }
      else{
        return true;

      }
    } catch (e) {
      // Log and handle any errors
      print('Error checking connectivity: $e');
      // You can choose to show an error message or take other actions as needed
      return false;
    }
  }


  displaySnackBarGreen(String messageText, BuildContext context)
  {
    var snackBar = SnackBar(content: Text(messageText),backgroundColor: Colors.green,);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  displaySnackBarRed(String messageText, BuildContext context)
  {
    var snackBar = SnackBar(content: Text(messageText),backgroundColor: Colors.red,);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static sendRequestToAPI(String apiUrl) async
  {
    http.Response responseFromAPI = await http.get(Uri.parse(apiUrl));

    try{
      if(responseFromAPI.statusCode == 200)
        {
          String dataFromApi = responseFromAPI.body;
          var dataDecoded = jsonDecode(dataFromApi);
          return dataDecoded;
        }
      else
        {
          return "Error";
        }
    }
    catch(errorMsg)
    {
      return "Error";
    }
  }

}

//cMethods.displaySnackBar("Your are blocked. Contact admin: banglaCar@gmail.com", context);   //Implementation



//Implementation
/*
CommonMethods cMethods = CommonMethods();

  checkIfNetworkIsAvailable()
  {
    cMethods.checkConnectivity(context);

    signUpFromValidation();
  }
  */



