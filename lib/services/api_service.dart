class BaseUrl {
  //static const String baseUrl = 'http://175.29.186.86:7022';
  static const String baseUrl = 'http://103.125.253.59:2026';
  static const String authorization =
      'Basic YWRtaW5pc3RyYXRvcjpBQyFAIyQxMjQzdXNlcg==';
  static const String TOKEN = 'Token';
  static const ChangePassword = "${baseUrl}ChangePassword";
}







/*
Future<void> signIn() async {
  var headers = {
    'Content-Type': 'application/json',
    'Authorization': '${BaseUrl.authorization}',
  };

  var request = http.Request('POST', Uri.parse('${BaseUrl.baseUrl}/api/v1/SignIn'));
  request.body = json.encode({
    "userName": userNameController.text,
    "password": passwordController.text,
  });
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(await response.stream.bytesToString());

    if (responseData.isNotEmpty) {
      // Login successful, check the number of items in the response
      if (responseData.length > 1) {
        // If data list has more than one item, navigate to IndexingPage
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => IndexingPage()));
      } else {
        // If data list has only one item, navigate to HomePage
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
      }
    } else {
      // Handle the case when the response data is empty
      print("Login successful, but response data is empty");
    }
  } else {
    // Handle the case when the login request fails
    print(response.reasonPhrase);
  }
}


void fetchAuthLogin() async {
  var headers = {
    'Content-Type': 'application/json',
    'Authorization': '${BaseUrl.authorization}',
  };

  var request = http.Request('POST', Uri.parse('${BaseUrl.baseUrl}/api/v1/SignIn'));
  request.body = json.encode({
   // "userName": userName,
    // "password": password,

  });
  request.headers.addAll(headers);

  try {
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print('Error: ${response.statusCode}');
      print('Response: ${await response.stream.bytesToString()}');
    }
  } catch (error) {
    print('Error: $error');
  }
}*/
