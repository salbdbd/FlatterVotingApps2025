import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:association/pages/phone_number_verification/send_otp.dart';
import 'Home/home_page.dart';
import 'indexing_page/indexing_page.dart';
import 'notification_page/notification_page.dart';
import 'profile_page/profile_page.dart';

class Dashboard extends StatefulWidget {
  final UserDetails? userDetails;

  const Dashboard({
    Key? key,
    this.userDetails,
  }) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {
  late PageController pageController;
  int indexSelected = 0;
  int unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: indexSelected);
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (indexSelected > 0) {
          pageController.animateToPage(indexSelected - 1, duration: const Duration(milliseconds: 100), curve: Curves.easeInOut);
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: const Color(0xff15212D),
          title: Text(
            _getAppBarTitle(),
            style: const TextStyle(color: Colors.white),
          ),
          leading: _buildLeadingIcon(),
        ),
        body: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! > 0 && indexSelected > 0) {
              pageController.previousPage(duration: const Duration(milliseconds: 100), curve: Curves.easeInOut);
            } else if (details.primaryVelocity! < 0 && indexSelected < 3) {
              pageController.nextPage(duration: const Duration(milliseconds: 100), curve: Curves.easeInOut);
            }
          },
          child: PageView(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                indexSelected = index;
              });
            },
            children: [
              HomePage(userDetails: widget.userDetails),
              SandOtpPage(userDetails: widget.userDetails),
              NotificationPage(onNewNotification: (count) {
                setState(() {
                  unreadNotificationCount = count;
                });
              },
                  userDetails: widget.userDetails),
              ProfilePage(userDetails: widget.userDetails),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            _buildNavItem(Icons.home, "Home", 0),
            _buildNavItem(Icons.fingerprint, "Voting", 1),
            _buildNavItem(Icons.notification_important_rounded, "Notification", 2, unreadNotificationCount),
            _buildNavItem(Icons.account_circle, "Profile", 3),
          ],
          elevation: 0,
          currentIndex: indexSelected,
          backgroundColor: const Color(0xff15212D),
          unselectedItemColor: Colors.grey,
          selectedItemColor: Colors.black,
          showSelectedLabels: true,
          selectedLabelStyle: const TextStyle(fontSize: 12),
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            pageController.animateToPage(index, duration: const Duration(milliseconds: 100), curve: Curves.easeInOut);
          },
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index, [int badgeCount = 0]) {
    return BottomNavigationBarItem(
      icon: Container(
        decoration: BoxDecoration(
          color: indexSelected == index ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Stack(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: indexSelected == index ? 18 : 25,
                ),
                if (indexSelected == index) const SizedBox(width: 2),
                if (indexSelected == index)
                  Text(
                    label,
                    style: const TextStyle(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
              ],
            ),
            if (badgeCount > 0)
              Positioned(
                right: 0,
                top: -2,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
      label: "",
    );
  }

  String _getAppBarTitle() {
    switch (indexSelected) {
      case 0:
        return '${widget.userDetails?.selectedCompanyData.name ?? ""}';
      case 1:
        return 'Executive Election';
      case 2:
        return 'Notification';
      case 3:
        return 'Profile';
      default:
        return '';
    }
  }

  Widget _buildLeadingIcon() {
    if (indexSelected == 0 && widget.userDetails?.selectedCompanyData.logo != null) {
      final decodedBytes = base64Decode(widget.userDetails!.selectedCompanyData.logo!);
      return Image.memory(decodedBytes, color: Colors.white,width: 50, height: 50,);
    } else {
      return IconButton(
        onPressed: () {
          if (indexSelected > 0) {
            pageController.animateToPage(indexSelected - 1, duration: const Duration(milliseconds: 100), curve: Curves.easeInOut);
          } else if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        },
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
      );
    }
  }
}
