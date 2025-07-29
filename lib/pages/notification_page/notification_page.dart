import 'dart:typed_data';

import 'package:association/pages/notification_page/componets/get_WMessage_Model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/api_service.dart';
import '../indexing_page/indexing_page.dart';

class NotificationPage extends StatefulWidget {
  final UserDetails? userDetails;
  final Function(int)? onNewNotification; // Define the callback

  NotificationPage({Key? key, this.onNewNotification, this.userDetails})
      : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<GetWMessageModel> notifications = [];
  List<String> archivedNotifications = [];
  int unreadNotificationCount = 0;

  DateTime? parseApiDate(String dateString) {
    if (dateString == "0001-01-01T00:00:00") {
      return null; // Return null for the special case
    }
    return DateTime.parse(dateString);
  }

  void fetchNotification() async {
    int compId = widget.userDetails?.selectedCompanyData.compId ?? 0;
    int userId = widget.userDetails?.selectedCompanyData.userId ?? 0;
    int memberId = widget.userDetails?.selectedCompanyData.memberId ?? 0;

    var headers = {'Authorization': '${BaseUrl.authorization}'};
    var request = http.Request('GET',
        Uri.parse('${BaseUrl.baseUrl}/api/v1/WMessage/$compId/$memberId'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      

      // Parse the JSON and create a List<NotificationModel>
      List<dynamic> decodedJsonList = json.decode(responseBody);

      // Update the class-level variable notifications
      notifications = decodedJsonList
          .map((dynamic json) => GetWMessageModel.fromJson(json))
          .toList();

      // Now you have a list of NotificationModel objects
      // Do whatever you need with the list
      unreadNotificationCount = 0; // Reset the count before updating
      for (var notification in notifications) {
        print("Notification Heading: ${notification.headLine}");
        if (!archivedNotifications.contains(notification.headLine)) {
          // Check if the notification is not archived
          unreadNotificationCount++;
        }
      }

      widget.onNewNotification?.call(unreadNotificationCount);
      // Call setState to trigger a rebuild of the UI with the updated data
      setState(() {});
    } else {
      print("Failed to fetch notification: ${response.reasonPhrase}");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final GetWMessageModel notification = notifications[index];
          return Card(
            color: Color(0xff15212D),
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: CircleAvatar(
                maxRadius: 30,
                backgroundColor: Colors.greenAccent,
                child: FutureBuilder<Uint8List>(
                  future: _decodeImage(notification.attaachment),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      return Image.asset(
                        'assets/Images/TigerHRMS.png', // Default image
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      );
                    } else {
                      return Image.memory(
                        snapshot.data!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      );
                    }
                  },
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.headLine ?? '',
                    style: TextStyle(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.messagInfo ?? '',
                    style: TextStyle(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    notification.readed != null
                        ? DateFormat('yMMMd H:mm').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                notification.readed!))
                        : '', // Format the date and time as per your requirement
                    style: TextStyle(color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              onTap: () {
                // Handle notification tap event
                _showMessageDialog(
                  context,
                  notification.headLine ?? '',
                  notification.messagInfo ?? '',
                  notification.attaachment ?? '',
                );
              },
              trailing: IconButton(
                icon: Icon(Icons.more_vert,
                    color: Colors.white), // Three-dot icon
                onPressed: () {
                  _showOptionsBottomSheet(context, index);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<Uint8List> _decodeImage(String? base64Image) async {
    if (base64Image == null || base64Image.isEmpty) {
      return Uint8List(0);
    }
    return base64Decode(base64Image);
  }

  void _showMessageDialog(
    BuildContext context,
    String title,
    String subtitle,
    String base64Image,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double screenWidth = MediaQuery.of(context).size.width;
        double dialogHeight =
            250; // Set a default height, you can adjust it based on your content

        return AlertDialog(
          backgroundColor: Color(0xff15212D),
          title: Center(
              child: Text('$title', style: TextStyle(color: Colors.white))),
          content: Container(
            height: dialogHeight,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(),
                    ),
                    child: FutureBuilder<Uint8List>(
                      future: _decodeImage(
                          base64Image.isNotEmpty ? base64Image : ''),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError || !snapshot.hasData) {
                          return Image.asset(
                            'assets/Images/TigerHRMS.png', // Default image
                            height: 50,
                            width: screenWidth,
                            fit: BoxFit.cover,
                          );
                        } else {
                          return Image.memory(
                            snapshot.data!,
                            height: 50,
                            width: screenWidth,
                            fit: BoxFit.cover,
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(subtitle, style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                widget.onNewNotification
                    ?.call(0); // Set count to 0 for seen notification
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showOptionsBottomSheet(BuildContext context, int notificationIndex) {
    showModalBottomSheet(
      backgroundColor: Color(0xff15212D),
      context: context,
      builder: (context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _OptionItem(
                icon: Icons.delete,
                text: 'Delete',
                onPressed: () {
                  _deleteNotification(notificationIndex);
                  Navigator.pop(
                      context); // Close the bottom sheet after selection
                },
              ),
              _OptionItem(
                icon: Icons.archive,
                text: 'Archive',
                onPressed: () {
                  _archiveNotification(notificationIndex);
                  Navigator.pop(
                      context); // Close the bottom sheet after selection
                },
              ),
              _OptionItem(
                icon: Icons.share,
                text: 'Share',
                onPressed: () {
                  _shareNotification(
                      notifications[notificationIndex].headLine ?? '');
                  Navigator.pop(
                      context); // Close the bottom sheet after selection
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
  }

  void _archiveNotification(int index) {
    setState(() {
      GetWMessageModel archivedNotification = notifications.removeAt(index);
      archivedNotifications.add(archivedNotification.headLine ?? '');
    });
  }

  void _shareNotification(String notificationText) {
    Share.share(notificationText);
  }
}

class _OptionItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  _OptionItem(
      {required this.icon, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(text, style: TextStyle(color: Colors.white)),
      onTap: onPressed,
    );
  }
}
