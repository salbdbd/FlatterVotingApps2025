import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';
import '../../Custom_widget/custom_cart.dart';
import '../../services/api_service.dart';
import '../indexing_page/indexing_page.dart';

class VotingPage extends StatefulWidget {
  final UserDetails? userDetails;
  const VotingPage({Key? key, this.userDetails}) : super(key: key);

  @override
  State<VotingPage> createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _arrowAnimationController;
  List<bool> isPresidentVisibleList = [];
  List<Map<String, dynamic>> designations = [];
  List<VotingCandidate> votingCandidates = [];
  int selectedChairmanDesignationID = 0;
  int selectedDesignationIndex = -1;

  Future<void> fetchGetDesignation() async {
    try {
      int compId = widget.userDetails?.selectedCompanyData.compId ?? 0;
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/v1/Get_Designation/$compId'),
        headers: {
          'accept': '*/*',
          'Authorization': '${BaseUrl.authorization}',
        },
      );

      print("fetchGetDesignation: ${response}");

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Designation> parsedDesignations = List<Designation>.from(data
            .map((designationData) => Designation.fromJson(designationData)));

        setState(() {
          designations = parsedDesignations
              .map((designation) => {
                    'designationID': designation.designationID,
                    'description': designation.description,
                  })
              .toList();
          isPresidentVisibleList =
              List.generate(parsedDesignations.length, (index) => false);
        });

        // Print all fetched data
        print('Fetched Designations:');
        parsedDesignations.forEach((designation) {
          print(
              'Designation ID: ${designation.designationID}, Description: ${designation.description}');
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchGetVotingCandidateList(int designationID) async {
    try {
      int compId = widget.userDetails?.selectedCompanyData.compId ??
          0; //String memberId = widget.userDetails?.selectedCompanyData['memberId'] ?? '0';
      int memberId = widget.userDetails?.selectedCompanyData.memberId ?? 0;
      print('memberIdmemberId: ${widget.userDetails?.userData.memberId ?? 0}');

      final response = await http.get(
        Uri.parse(
            '${BaseUrl.baseUrl}/api/v1/Get_VotingCandidateList/$compId/$designationID/$memberId'),
        headers: {
          'accept': '*/*',
          'Authorization': '${BaseUrl.authorization}',
        },
      );

      print("fetchGetVotingCandidateList: ${response}");

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<VotingCandidate> parsedVotingCandidates =
            List<VotingCandidate>.from(data.map(
                (candidateData) => VotingCandidate.fromJson(candidateData)));

        setState(() {
          votingCandidates = parsedVotingCandidates;
        });

        // Print all fetched data
        print('Fetched Voting Candidates:');
        parsedVotingCandidates.forEach((candidate) {
          print(
              'Candidate ID: ${candidate.candidateID}, Name: ${candidate.memberName}');
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchGetDesignation();
    _arrowAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
  }

  DateTime? lastBackPressed;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (lastBackPressed == null ||
            DateTime.now().difference(lastBackPressed!) >
                Duration(seconds: 2)) {
          // If it's the first back press or more than 2 seconds passed since the last press,
          // show a message or perform any other logic
          lastBackPressed = DateTime.now();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
            ),
          );
          return false; // Do not pop the page
        } else {
          // If it's the second back press within 2 seconds, allow the page to be popped
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: const Color(0xff15212D),
          leading: IconButton(
            onPressed: () {
              // Same logic as the WillPopScope callback
              if (lastBackPressed == null ||
                  DateTime.now().difference(lastBackPressed!) >
                      Duration(seconds: 2)) {
                lastBackPressed = DateTime.now();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Press back again to exit'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                Navigator.pop(context);
              }
            },
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),
          title: Text(
            "Candidel Select",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: List.generate(designations.length, (index) {
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        // Toggle the visibility state for the selected President
                        isPresidentVisibleList[index] =
                            !isPresidentVisibleList[index];

                        // Close the AnimatedContainer if it's already open
                        if (selectedDesignationIndex != -1 &&
                            selectedDesignationIndex != index) {
                          isPresidentVisibleList[selectedDesignationIndex] =
                              false;
                        }

                        if (isPresidentVisibleList[index]) {
                          _arrowAnimationController.forward();
                          // Set the selected chairman's designationID
                          selectedChairmanDesignationID =
                              designations[index]['designationID'];
                          fetchGetVotingCandidateList(
                              selectedChairmanDesignationID);
                        } else {
                          _arrowAnimationController.reverse();
                        }

                        // Update the selected index
                        selectedDesignationIndex =
                            isPresidentVisibleList[index] ? index : -1;
                      });
                    },
                    child: Container(
                      height: 50,
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            designations[index]['description'],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          RotationTransition(
                            turns: Tween(
                                    begin: 0.0,
                                    end: isPresidentVisibleList[index]
                                        ? 0.5
                                        : 0.0)
                                .animate(_arrowAnimationController),
                            child: Icon(Icons.keyboard_arrow_down,
                                color: Colors.white, size: 30),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    height: isPresidentVisibleList[index]
                        ? _calculateTotalHeight()
                        : 0,
                    child: Visibility(
                      visible: isPresidentVisibleList[index],
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: votingCandidates.length,
                        itemBuilder: (context, innerIndex) {
                          if (innerIndex < votingCandidates.length) {
                            return GestureDetector(
                              onTap: () {
                                showBottomSheet(
                                  context,
                                  userDetails: widget.userDetails!,
                                  candidate: votingCandidates[innerIndex],
                                );
                              },
                              child: CustomCart(
                                imageUrl: 'assets/Images/TigerHRMSwhite.png',
                                title: votingCandidates[innerIndex].memberName,
                                subtitle:
                                    votingCandidates[innerIndex].description,
                                description:
                                    (votingCandidates[innerIndex].candidateID ??
                                            0)
                                        .toString(),
                              ),
                            );
                          } else {
                            return SizedBox.shrink();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  void showBottomSheet(BuildContext context,
      {required UserDetails userDetails, required VotingCandidate candidate}) {
    Get.bottomSheet(
      SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height, // Full screen height
          width: MediaQuery.of(context).size.width, // Full screen width
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
            ),
          ),
          child: Stack(
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
                              fontSize: 70.0,
                              fontWeight: FontWeight.bold,
                            ),
                            child: Text("Vote"),
                          ),
                          SizedBox(
                            height: 50,
                          ),
                          GestureDetector(
                            onTap: () async {
                              print(
                                  'Candidate ID: ${candidate.candidateID}, Nameii: ${candidate.memberName}');
                              bool authenticated =
                                  await authenticateWithFingerprint(
                                      context, widget.userDetails!, candidate);

                              if (authenticated) {
                                // Fingerprint authentication successful, add your logic here
                                // For example, close the bottom sheet or navigate to another screen
                                Get.back(); // Close the bottom sheet
                              }
                            },
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
        ),
      ),
      isScrollControlled: true,
    );
  }

// Function to perform fingerprint authentication
  // Inside your authenticateWithFingerprint function
  Future<bool> authenticateWithFingerprint(BuildContext context,
      UserDetails userDetails, VotingCandidate candidate) async {
    print(
        "Candidate ID: ${candidate.candidateID}, Name: ${candidate.memberName}, UserDetails: ${userDetails}");
    final auth = LocalAuthentication();
    bool authenticated = false;

    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Authenticate with Fingerprint',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (e) {
      print(e);
    }

    if (authenticated) {
      // If authentication is successful, you can perform further actions here
      // For example, you can close the bottom sheet or navigate to another screen
      final snackBar = SnackBar(
        content: Text('Fingerprint authentication successful'),
        backgroundColor: Colors.green,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      // Call the function to post the vote after successful fingerprint authentication
      bool votePosted = await fetchPostVote(
        periodID: candidate.periodId,
        voterID: (widget.userDetails?.userData.memberId ?? '')
            .toString(), // Remove the extra semicolon here
        //voterID: widget.userDetails?.userData.memberId ?? 0, // Remove the extra semicolon here
        designationID: candidate.designationID,
        candidateID: candidate.candidateID,
        compID:
            (widget.userDetails?.selectedCompanyData.compId ?? '').toString(),
      );

      if (votePosted) {
        await fetchGetVotingCandidateList(selectedChairmanDesignationID);

        // Handle success after posting the vote
        final snackBar = SnackBar(
          content: Text('Vote posted successfully'),
          backgroundColor: Colors.green,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        // Handle failure after posting the vote
        final snackBar = SnackBar(
          content: Text('Failed to post vote'),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }

      // Close the bottom sheet after successful fingerprint authentication and vote posting
      //Get.back();
    } else {
      final snackBar = SnackBar(
        content: Text('Failed to authenticate with fingerprint'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    return authenticated;
  }

  Future<bool> fetchPostVote({
    required int periodID,
    required String? voterID,
    required int designationID,
    required int candidateID,
    required String? compID,
  }) async {
    try {
      // Explicitly convert to the required types
      int voterIdInt = int.tryParse(voterID ?? '') ?? 0;
      print("objectvote = $voterIdInt");
      int compIdInt = int.tryParse(compID ?? '') ?? 0;

      final response = await http.post(
        Uri.parse('${BaseUrl.baseUrl}/api/v1/SaveVote'),
        headers: {
          'accept': 'application/json',
          'content-type': 'application/json',
          'Authorization': '${BaseUrl.authorization}',
        },
        body: jsonEncode({
          'periodID': periodID,
          'voterID': voterIdInt,
          'designationID': designationID,
          'candidateID': candidateID,
          'compID': compIdInt,
          'voting': true,
        }),
      );

      if (response.statusCode == 200) {
        // Handle successful vote posting
        print('Vote posted successfully');
        print('Response Data: ${response.body}');
        return true;
      } else {
        // Handle failure to post the vote
        print('Failed to post vote. Status code: ${response.statusCode}');
        print('Response Data: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error posting vote: $e');
      return false;
    }
  }

  double _calculateTotalHeight() {
    // Height of each CustomCart item
    double itemHeight = 120;
    // Total height based on the number of items
    return itemHeight * votingCandidates.length;
  }

  @override
  void dispose() {
    _arrowAnimationController.dispose();
    super.dispose();
  }
}

class Designation {
  final int designationID;
  final String description;

  Designation({required this.designationID, required this.description});

  factory Designation.fromJson(Map<String, dynamic> json) {
    return Designation(
      designationID: json['designationID'],
      description: json['description'],
    );
  }
}

class VotingCandidate {
  final int id;
  final int compId;
  final String memberCode;
  final int? memberId;
  final int panelID;
  final int periodId;
  final int candidateID;
  final String? organization;
  final String description;
  final String memberName;
  final String? fathersName;
  final String? mothersName;
  final String? spousName;
  final int genderID;
  final int bloodGroupID;
  final int religionID;
  final int maritialStatusID;
  final String? email;
  final int countryID;
  final int nationalityID;
  final int thanaID;
  final int permanentThanaID;
  final int unionId;
  final int villageId;
  final String? postOffice;
  final String? presentAddress;
  final String? permanentAddress;
  final String? location;
  final String? lastEducation;
  final String? mobileNo;
  final int moduleID;
  final int userID;
  final int designationID;

  VotingCandidate({
    required this.id,
    required this.compId,
    required this.memberCode,
    this.memberId,
    required this.panelID,
    required this.periodId,
    required this.candidateID,
    this.organization,
    required this.description,
    required this.memberName,
    this.fathersName,
    this.mothersName,
    this.spousName,
    required this.genderID,
    required this.bloodGroupID,
    required this.religionID,
    required this.maritialStatusID,
    this.email,
    required this.countryID,
    required this.nationalityID,
    required this.thanaID,
    required this.permanentThanaID,
    required this.unionId,
    required this.villageId,
    this.postOffice,
    this.presentAddress,
    this.permanentAddress,
    this.location,
    this.lastEducation,
    this.mobileNo,
    required this.moduleID,
    required this.userID,
    required this.designationID,
  });

  factory VotingCandidate.fromJson(Map<String, dynamic> json) {
    return VotingCandidate(
      id: json['id'],
      compId: json['compId'],
      memberCode: json['memberCode'],
      memberId: json['memberId'],
      panelID: json['panelID'],
      periodId: json['periodId'],
      candidateID: json['candidateID'],
      organization: json['organization'],
      description: json['description'],
      memberName: json['memberName'],
      fathersName: json['fathersName'],
      mothersName: json['mothersName'],
      spousName: json['spousName'],
      genderID: json['genderID'],
      bloodGroupID: json['bloodGroupID'],
      religionID: json['religionID'],
      maritialStatusID: json['maritialStatusID'],
      email: json['email'],
      countryID: json['countryID'],
      nationalityID: json['nationalityID'],
      thanaID: json['thanaID'],
      permanentThanaID: json['permanentThanaID'],
      unionId: json['unionId'],
      villageId: json['villageId'],
      postOffice: json['postOffice'],
      presentAddress: json['presentAddress'],
      permanentAddress: json['permanentAddress'],
      location: json['location'],
      lastEducation: json['lastEducation'],
      mobileNo: json['mobileNo'],
      moduleID: json['moduleID'],
      userID: json['userID'],
      designationID: json['designationID'],
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
