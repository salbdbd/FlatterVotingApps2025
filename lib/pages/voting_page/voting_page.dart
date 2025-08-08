import 'dart:async';
import 'dart:convert';
import 'dart:math';

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

class _VotingPageState extends State<VotingPage> with TickerProviderStateMixin {
  late List<AnimationController> _arrowAnimationControllers;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  List<bool> isDesignationVisibleList = [];
  List<Map<String, dynamic>> designations = [];
  List<VotingCandidate> votingCandidates = [];
  int selectedDesignationID = 0;
  int selectedDesignationIndex = -1;
  bool isLoading = false;
  bool isVotingInProgress = false;
  DateTime? lastBackPressed;

  @override
  void initState() {
    super.initState();
    _initializeAnimationControllers();
    fetchGetDesignation();
  }

  void _initializeAnimationControllers() {
    _arrowAnimationControllers = [];

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeController.forward();
  }

  void _updateAnimationControllers() {
    // Dispose existing controllers
    for (var controller in _arrowAnimationControllers) {
      controller.dispose();
    }

    // Create new controllers for each designation
    _arrowAnimationControllers = List.generate(
      designations.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );
  }

  Future<void> fetchGetDesignation() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      int compId = widget.userDetails?.selectedCompanyData.compId ?? 0;
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/v1/Get_Designation/$compId'),
        headers: {
          'accept': '*/*',
          'Authorization': '${BaseUrl.authorization}',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Designation> parsedDesignations = List<Designation>.from(data
            .map((designationData) => Designation.fromJson(designationData)));

        if (mounted) {
          setState(() {
            designations = parsedDesignations
                .map((designation) => {
                      'designationID': designation.designationID,
                      'description': designation.description,
                    })
                .toList();
            isDesignationVisibleList =
                List.generate(parsedDesignations.length, (index) => false);
          });
          _updateAnimationControllers();
        }

        print('Fetched ${parsedDesignations.length} designations successfully');
      } else {
        _showErrorSnackBar(
            'Failed to load designations: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching designations: $e');
      _showErrorSnackBar('Network error. Please check your connection.');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> fetchGetVotingCandidateList(int designationID) async {
    try {
      int compId = widget.userDetails?.selectedCompanyData.compId ?? 0;
      int memberId = widget.userDetails?.selectedCompanyData.memberId ?? 0;

      final response = await http.get(
        Uri.parse(
            '${BaseUrl.baseUrl}/api/v1/Get_VotingCandidateList/$compId/$designationID/$memberId'),
        headers: {
          'accept': '*/*',
          'Authorization': '${BaseUrl.authorization}',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<VotingCandidate> parsedVotingCandidates =
            List<VotingCandidate>.from(data.map(
                (candidateData) => VotingCandidate.fromJson(candidateData)));

        if (mounted) {
          setState(() {
            votingCandidates = parsedVotingCandidates;
          });
        }

        print(
            'Fetched ${parsedVotingCandidates.length} candidates for designation $designationID');
      } else {
        _showErrorSnackBar('Failed to load candidates: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching candidates: $e');
      _showErrorSnackBar('Failed to load candidates. Please try again.');
    }
  }

  Future<bool> _handleBackPress() async {
    if (lastBackPressed == null ||
        DateTime.now().difference(lastBackPressed!) >
            const Duration(seconds: 2)) {
      lastBackPressed = DateTime.now();
      _showInfoSnackBar('Press back again to exit');
      return false;
    }
    return true;
  }

  void _toggleDesignationVisibility(int index) {
    if (isVotingInProgress) return;

    setState(() {
      // Close other open designations
      for (int i = 0; i < isDesignationVisibleList.length; i++) {
        if (i != index && isDesignationVisibleList[i]) {
          isDesignationVisibleList[i] = false;
          if (i < _arrowAnimationControllers.length) {
            _arrowAnimationControllers[i].reverse();
          }
        }
      }

      // Toggle current designation
      isDesignationVisibleList[index] = !isDesignationVisibleList[index];

      if (index < _arrowAnimationControllers.length) {
        if (isDesignationVisibleList[index]) {
          _arrowAnimationControllers[index].forward();
          selectedDesignationID = designations[index]['designationID'];
          selectedDesignationIndex = index;
          fetchGetVotingCandidateList(selectedDesignationID);
        } else {
          _arrowAnimationControllers[index].reverse();
          selectedDesignationIndex = -1;
        }
      }
    });
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            double animationValue = _floatingController.value + (index * 0.2);
            double screenWidth = MediaQuery.of(context).size.width;
            double screenHeight = MediaQuery.of(context).size.height;

            double x = screenWidth *
                (0.1 + 0.8 * sin(animationValue * 2 * pi + index));
            double y = screenHeight *
                (0.1 + 0.8 * cos(animationValue * pi + index * 0.7));

            return Positioned(
              left: x,
              top: y,
              child: Container(
                width: 4 + (index % 3) * 2,
                height: 4 + (index % 3) * 2,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.blue.withOpacity(0.6),
                      Colors.purple.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildDesignationCard(int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: _fadeController,
              curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
            ),
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.5),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _fadeController,
                curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
              ),
            ),
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 16,
                vertical: 8,
              ),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(20),
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xff667eea).withOpacity(0.8),
                        const Color(0xff764ba2).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff667eea).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _toggleDesignationVisibility(index),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 28 : 20,
                        vertical: isTablet ? 20 : 16,
                      ),
                      child: Row(
                        children: [
                          // Icon
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.how_to_vote_rounded,
                              color: Colors.white,
                              size: isTablet ? 28 : 24,
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Text(
                              designations[index]['description'],
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 20 : 18,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Animated arrow
                          index < _arrowAnimationControllers.length
                              ? AnimatedBuilder(
                                  animation: _arrowAnimationControllers[index],
                                  builder: (context, child) {
                                    return Transform.rotate(
                                      angle: _arrowAnimationControllers[index]
                                              .value *
                                          pi,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: Colors.white,
                                          size: isTablet ? 32 : 28,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Colors.white,
                                    size: isTablet ? 32 : 28,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCandidatesList(int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      height: isDesignationVisibleList[index] ? null : 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: isDesignationVisibleList[index] ? 1.0 : 0.0,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              if (votingCandidates.isEmpty && isDesignationVisibleList[index])
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey.withOpacity(0.1),
                        Colors.grey.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_off_rounded,
                        size: isTablet ? 64 : 48,
                        color: Colors.white38,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No candidates available for this designation',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ...votingCandidates.asMap().entries.map((entry) {
                int candidateIndex = entry.key;
                VotingCandidate candidate = entry.value;

                return AnimatedContainer(
                  duration:
                      Duration(milliseconds: 300 + (candidateIndex * 100)),
                  curve: Curves.easeOutBack,
                  child: GestureDetector(
                    onTap: () => _showVotingBottomSheet(candidate),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.transparent,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: CustomCart(
                            imageUrl: 'assets/Images/TigerHRMSwhite.png',
                            title: candidate.memberName,
                            subtitle: candidate.description,
                            description: candidate.candidateID.toString(),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showVotingBottomSheet(VotingCandidate candidate) {
    if (isVotingInProgress) {
      _showInfoSnackBar('Please wait, voting in progress...');
      return;
    }

    Get.bottomSheet(
      ModernVotingBottomSheet(
        candidate: candidate,
        onVote: () => _handleVoting(candidate),
        isLoading: isVotingInProgress,
      ),
      isScrollControlled: true,
      enableDrag: !isVotingInProgress,
      isDismissible: !isVotingInProgress,
    );
  }

  Future<void> _handleVoting(VotingCandidate candidate) async {
    if (isVotingInProgress) return;

    setState(() {
      isVotingInProgress = true;
    });

    try {
      bool authenticated = await _authenticateWithBiometric();

      if (authenticated) {
        bool votePosted = await _postVote(candidate);

        if (votePosted) {
          _showSuccessSnackBar('Vote cast successfully!');
          await fetchGetVotingCandidateList(selectedDesignationID);
          Get.back(); // Close bottom sheet
        } else {
          _showErrorSnackBar('Failed to cast vote. Please try again.');
        }
      } else {
        _showErrorSnackBar('Authentication failed. Vote not cast.');
      }
    } catch (e) {
      print('Voting error: $e');
      _showErrorSnackBar('An error occurred while voting.');
    } finally {
      setState(() {
        isVotingInProgress = false;
      });
    }
  }

  Future<bool> _authenticateWithBiometric() async {
    final auth = LocalAuthentication();

    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        _showErrorSnackBar('Biometric authentication not available');
        return false;
      }

      List<BiometricType> availableBiometrics =
          await auth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        _showErrorSnackBar('No biometric methods available');
        return false;
      }

      bool authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to cast your vote',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      return authenticated;
    } on PlatformException catch (e) {
      print('Biometric authentication error: $e');
      _showErrorSnackBar('Authentication error: ${e.message}');
      return false;
    }
  }

  Future<bool> _postVote(VotingCandidate candidate) async {
    try {
      int voterIdInt = widget.userDetails?.userData.memberId ?? 0;
      int compIdInt = widget.userDetails?.selectedCompanyData.compId ?? 0;

      final response = await http.post(
        Uri.parse('${BaseUrl.baseUrl}/api/v1/SaveVote'),
        headers: {
          'accept': 'application/json',
          'content-type': 'application/json',
          'Authorization': '${BaseUrl.authorization}',
        },
        body: jsonEncode({
          'periodID': candidate.periodId,
          'voterID': voterIdInt,
          'designationID': candidate.designationID,
          'candidateID': candidate.candidateID,
          'compID': compIdInt,
          'voting': true,
        }),
      );

      if (response.statusCode == 200) {
        print('Vote posted successfully');
        return true;
      } else {
        print('Failed to post vote. Status code: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error posting vote: $e');
      return false;
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showInfoSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isSmallScreen = screenHeight < 700;

    return WillPopScope(
      onWillPop: _handleBackPress,
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xff667eea).withOpacity(0.9),
                  const Color(0xff764ba2).withOpacity(0.9),
                ],
              ),
            ),
          ),
          leading: IconButton(
            onPressed: () async {
              bool shouldPop = await _handleBackPress();
              if (shouldPop) {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),
          title: Text(
            "Select Candidates",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 24 : 20,
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: true,
          actions: [
            if (isLoading || isVotingInProgress)
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: Center(
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_pulseController.value * 0.3),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                            value: null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.5,
              colors: [
                const Color(0xFF0f0f23),
                const Color(0xFF1a1a2e),
                const Color(0xFF16213e),
                Colors.black,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Floating particles background
              _buildFloatingParticles(),

              // Main content
              SafeArea(
                child: isLoading && designations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 1.0 + (_pulseController.value * 0.3),
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue.withOpacity(0.3),
                                          Colors.purple.withOpacity(0.3),
                                        ],
                                      ),
                                    ),
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Loading designations...',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: isTablet ? 18 : 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : designations.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.grey.withOpacity(0.2),
                                        Colors.grey.withOpacity(0.1),
                                      ],
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.how_to_vote_rounded,
                                    size: isTablet ? 80 : 64,
                                    color: Colors.white54,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'No voting designations available',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: isTablet ? 20 : 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Pull down to refresh or try again later',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: isTablet ? 16 : 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),
                                ElevatedButton.icon(
                                  onPressed:
                                      isLoading ? null : fetchGetDesignation,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Refresh'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff667eea),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isTablet ? 32 : 24,
                                      vertical: isTablet ? 16 : 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: fetchGetDesignation,
                            color: const Color(0xff667eea),
                            backgroundColor: Colors.white,
                            child: CustomScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              slivers: [
                                const SliverToBoxAdapter(
                                    child: SizedBox(height: 8)),
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      return Column(
                                        children: [
                                          _buildDesignationCard(index),
                                          _buildCandidatesList(index),
                                        ],
                                      );
                                    },
                                    childCount: designations.length,
                                  ),
                                ),
                                const SliverToBoxAdapter(
                                    child: SizedBox(height: 32)),
                              ],
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _arrowAnimationControllers) {
      controller.dispose();
    }
    _floatingController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
}

class ModernVotingBottomSheet extends StatefulWidget {
  final VotingCandidate candidate;
  final VoidCallback onVote;
  final bool isLoading;

  const ModernVotingBottomSheet({
    Key? key,
    required this.candidate,
    required this.onVote,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<ModernVotingBottomSheet> createState() =>
      _ModernVotingBottomSheetState();
}

class _ModernVotingBottomSheetState extends State<ModernVotingBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return Container(
      height: screenHeight * 0.9,
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          // Background with gradient
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.2,
                    colors: [
                      const Color(0xFF0f0f23),
                      const Color(0xFF1a1a2e),
                      const Color(0xFF16213e),
                      Colors.black,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Animated background (optional lottie)
          if (!widget.isLoading)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                child: Opacity(
                  opacity: 0.3,
                  child: Lottie.asset(
                    'assets/Images/login_page_animation.json',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

          // Content
          SafeArea(
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _slideController,
                curve: Curves.easeOutCubic,
              )),
              child: Column(
                children: [
                  // Modern handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 60,
                    height: 5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.6),
                          Colors.white.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Vote title with animation
                        ScaleTransition(
                          scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _scaleController,
                              curve: Curves.elasticOut,
                            ),
                          ),
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: isTablet ? 48 : 24,
                            ),
                            child: ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Colors.white,
                                  Color(0xFF667eea),
                                  Color(0xFF764ba2),
                                  Colors.white,
                                ],
                                stops: [0.0, 0.3, 0.7, 1.0],
                              ).createShader(bounds),
                              child: Text(
                                "Cast Your Vote",
                                style: TextStyle(
                                  fontSize: isTablet ? 42 : 32,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Enhanced candidate info card
                        FadeTransition(
                          opacity: _slideController,
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: isTablet ? 64 : 32,
                            ),
                            padding: EdgeInsets.all(isTablet ? 32 : 24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.15),
                                  Colors.white.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Profile avatar
                                Container(
                                  width: isTablet ? 80 : 60,
                                  height: isTablet ? 80 : 60,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF667eea),
                                        Color(0xFF764ba2),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.5),
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: isTablet ? 40 : 30,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Candidate name
                                Text(
                                  widget.candidate.memberName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isTablet ? 24 : 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 12),

                                // Position
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.blue.withOpacity(0.5),
                                    ),
                                  ),
                                  child: Text(
                                    widget.candidate.description,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: isTablet ? 18 : 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Candidate ID
                                Text(
                                  'ID: ${widget.candidate.candidateID}',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: isTablet ? 16 : 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Enhanced biometric button
                        GestureDetector(
                          onTap: widget.isLoading ? null : widget.onVote,
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: widget.isLoading
                                    ? 1.0
                                    : 1.0 + (_pulseController.value * 0.1),
                                child: Container(
                                  width: isTablet ? 140 : 120,
                                  height: isTablet ? 140 : 120,
                                  decoration: BoxDecoration(
                                    gradient: widget.isLoading
                                        ? LinearGradient(
                                            colors: [
                                              Colors.grey.withOpacity(0.3),
                                              Colors.grey.withOpacity(0.1),
                                            ],
                                          )
                                        : const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFF00c851),
                                              Color(0xFF007e33),
                                            ],
                                          ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: widget.isLoading
                                          ? Colors.grey.withOpacity(0.5)
                                          : Colors.green.withOpacity(0.8),
                                      width: 3,
                                    ),
                                    boxShadow: widget.isLoading
                                        ? []
                                        : [
                                            BoxShadow(
                                              color:
                                                  Colors.green.withOpacity(0.4),
                                              blurRadius: 20,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                  ),
                                  child: Center(
                                    child: widget.isLoading
                                        ? SizedBox(
                                            width: isTablet ? 60 : 50,
                                            height: isTablet ? 60 : 50,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 4,
                                            ),
                                          )
                                        : Icon(
                                            Icons.fingerprint_outlined,
                                            size: isTablet ? 80 : 64,
                                            color: Colors.white,
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Enhanced instructions
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: isTablet ? 48 : 24,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Text(
                            widget.isLoading
                                ? "🔄 Processing your vote...\nPlease wait"
                                : "👆 Tap to authenticate and cast your vote\n🔒 Your vote is secure and anonymous",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Enhanced bottom typing animation
                  Container(
                    margin: EdgeInsets.all(isTablet ? 32 : 20),
                    child: ModernTypingTextAnimation(
                      isTablet: isTablet,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced model classes (unchanged structure, just keeping them)
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
      id: json['id'] ?? 0,
      compId: json['compId'] ?? 0,
      memberCode: json['memberCode'] ?? '',
      memberId: json['memberId'],
      panelID: json['panelID'] ?? 0,
      periodId: json['periodId'] ?? 0,
      candidateID: json['candidateID'] ?? 0,
      organization: json['organization'],
      description: json['description'] ?? '',
      memberName: json['memberName'] ?? '',
      fathersName: json['fathersName'],
      mothersName: json['mothersName'],
      spousName: json['spousName'],
      genderID: json['genderID'] ?? 0,
      bloodGroupID: json['bloodGroupID'] ?? 0,
      religionID: json['religionID'] ?? 0,
      maritialStatusID: json['maritialStatusID'] ?? 0,
      email: json['email'],
      countryID: json['countryID'] ?? 0,
      nationalityID: json['nationalityID'] ?? 0,
      thanaID: json['thanaID'] ?? 0,
      permanentThanaID: json['permanentThanaID'] ?? 0,
      unionId: json['unionId'] ?? 0,
      villageId: json['villageId'] ?? 0,
      postOffice: json['postOffice'],
      presentAddress: json['presentAddress'],
      permanentAddress: json['permanentAddress'],
      location: json['location'],
      lastEducation: json['lastEducation'],
      mobileNo: json['mobileNo'],
      moduleID: json['moduleID'] ?? 0,
      userID: json['userID'] ?? 0,
      designationID: json['designationID'] ?? 0,
    );
  }
}

class ModernTypingTextAnimation extends StatefulWidget {
  final bool isTablet;

  const ModernTypingTextAnimation({
    Key? key,
    this.isTablet = false,
  }) : super(key: key);

  @override
  State<ModernTypingTextAnimation> createState() =>
      _ModernTypingTextAnimationState();
}

class _ModernTypingTextAnimationState extends State<ModernTypingTextAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _restartTimer;
  String displayedText = "";

  static const String text =
      "🔐 Authenticate using your fingerprint to secure your vote";

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
          int charCount = (_controller.value * text.length).floor();
          displayedText = text.substring(0, charCount);
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
      padding: EdgeInsets.symmetric(
        horizontal: widget.isTablet ? 32 : 20,
        vertical: widget.isTablet ? 20 : 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.purple.withOpacity(0.1),
          ],
        ),
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
                fontSize: widget.isTablet ? 18 : 16,
                height: 1.5,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          if (_controller.value < 1.0)
            Container(
              width: 3,
              height: widget.isTablet ? 22 : 20,
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}
