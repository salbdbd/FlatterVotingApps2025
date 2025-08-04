import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:association/pages/Home/components/event_card.dart';
import 'package:association/pages/Home/components/loan_pdf/pdf_page.dart';
import 'package:association/pages/Home/model/get_billreceipt_model.dart';
import 'package:association/pages/Home/model/get_w_memberAccountTransaction_model.dart';
import 'package:association/pages/Home/pdf_viewer_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../services/api_service.dart';
import '../indexing_page/indexing_page.dart';
import 'components/CountDownAnimation.dart';
import 'components/booking_page.dart';
import 'model/get_newsor_event_model.dart';

class HomePage extends StatefulWidget {
  final UserDetails? userDetails;

  const HomePage({
    Key? key,
    this.userDetails,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  TextEditingController nameController = TextEditingController();
  PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    print('NumberAnimation Widget Initialized');
    String userName = widget.userDetails?.selectedCompanyData.name ?? '';
    nameController.text = userName;

    // Initialize tab controller
    _tabController = TabController(length: 3, vsync: this);

    // Initialize animations
    _fadeAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _fadeAnimationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _slideAnimationController, curve: Curves.elasticOut));

    _pageController.addListener(() {
      if (mounted) {
        setState(() {
          _currentPage = _pageController.page!.toInt();
        });
      }
    });

    loadDataSerially();
  }

  Future<void> loadDataSerially() async {
    await fetchGetNewsorEvent();
    await fetchGetWMemberAccountTransaction();
    isLoading = List<bool>.filled(EventsDetails.length, false);

    // Start animations after data is loaded
    _fadeAnimationController.forward();
    Future.delayed(Duration(milliseconds: 200), () {
      _slideAnimationController.forward();
    });
  }

  List<GetNewsorEventModel> newsOrEvents = [];

  Future<void> fetchGetNewsorEvent() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      int compId = widget.userDetails?.selectedCompanyData.compId ?? 0;
      int userId = widget.userDetails?.selectedCompanyData.userId ?? 0;
      int memberId = widget.userDetails?.selectedCompanyData.memberId ?? 0;
      String url = '${BaseUrl.baseUrl}/api/v1/GetNewsorEvent/$compId/2';

      http.Response response = await http.get(Uri.parse(url), headers: {
        'accept': '*/*',
        'Authorization': '${BaseUrl.authorization}'
      });
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        newsOrEvents = jsonResponse
            .map((data) => GetNewsorEventModel.fromJson(data))
            .toList();
        if (mounted) {
          setState(() {});
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<GetWMemberAccountTransactionModel> EventsDetails = [];

  Future<void> fetchGetWMemberAccountTransaction() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      int compId = widget.userDetails?.selectedCompanyData.compId ?? 0;
      int userId = widget.userDetails?.selectedCompanyData.userId ?? 0;
      int memberId = widget.userDetails?.selectedCompanyData.memberId ?? 0;
      print("memberId = ${memberId}");
      print("Company id = ${compId}");
      String url =
          '${BaseUrl.baseUrl}/api/v1/W_MemberAccountTransaction/$compId/$memberId';

      print('Request URL: $url');

      http.Response response = await http.get(Uri.parse(url), headers: {
        'accept': '*/*',
        'Authorization': '${BaseUrl.authorization}'
      });

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);

        print('Response Data: $jsonResponse');

        if (mounted) {
          setState(() {
            EventsDetails = jsonResponse
                .map((data) => GetWMemberAccountTransactionModel.fromJson(data))
                .toList();
          });
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<bool> isLoading = [];

  Future<void> printProduct(
    BuildContext context,
    int serviceId,
    String transactionId,
    int index,
  ) async {
    if (mounted) {
      setState(() {
        isLoading[index] = true;
      });
    }

    print("Is loading list : $isLoading");

    var parameter = {
      'ReportId': '6594',
      'ExportType': 'pdf',
      'servceId': serviceId.toString() ?? '',
      'MemberId': widget.userDetails!.selectedCompanyData.memberId.toString(),
      'TransId': transactionId.toString() ?? '',
      'CompId': widget.userDetails!.selectedCompanyData.compId.toString() ?? '',
    };

    print("Parameter : ${parameter}");
    var responsType = 'blob';

    final uri =
        Uri.http('103.125.253.59:2003', '/api/erp/commercialRpt/', parameter);
    print("Before get request");
    try {
      print("URI: $uri");
      http.Response response = await http.get(uri, headers: {
        'Accept': 'application/pdf',
        'Content-Type': 'application/json',
      }).timeout(const Duration(seconds: 30));
      print("After get request");
      print(
          "Response's status code: ${response.statusCode}, response type : ${response.body}");

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        print("\n\n\nSuccess and byte's leanth : ${bytes.length}");
        final tempDir = await getApplicationCacheDirectory();
        final file = File('${tempDir.path}/report.pdf');
        await file.writeAsBytes(bytes, flush: true);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerScreen(pdfFile: file),
          ),
        );
      } else {
        print("Failed");
      }
    } catch (error) {
      print("Exception : $error");
    } finally {
      if (mounted) {
        setState(() {
          isLoading[index] = false;
        });
      }
    }
  }

  Uint8List? _pdfData;
  Future<List<GetBillReceiptModel>> fetchGetBillReceipt(int billId) async {
    try {
      print("Company ID : ${widget.userDetails!.selectedCompanyData.compId}");
      print("Bill ID : ${billId}");
      final response = await http.get(
        Uri.parse(
            '${BaseUrl.baseUrl}/api/v1/GetBillReceipt/${widget.userDetails!.selectedCompanyData.compId}/$billId'),
        headers: {
          'accept': '*/*',
          'Authorization': '${BaseUrl.authorization}',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        print("Json data : ${jsonResponse}");
        List<GetBillReceiptModel> billReceipts = jsonResponse
            .map((data) => GetBillReceiptModel.fromJson(data))
            .toList();

        print("List leangth : ${billReceipts.length}");

        return billReceipts;
      } else {
        print('Request failed with status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }

  void navigateToPdfPage(List<GetBillReceiptModel> billReceipts) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LPdfPage(
          userDetails: widget.userDetails,
          serialNumber: 'TKTS021739',
          customerName: 'ENGR. KHAN ATAUR RAHMAN SANTU',
          phoneNumber: '1234567890',
          eventName: 'RABINDRA-NAZRUL JAYANTI 2024',
          eventDateTime: '03-June-2024 @ 7.00',
          numberOfTickets: "1",
          ticketRate: "100.0",
          totalAmount: "100.0",
          billReceipts: billReceipts,
        ),
      ),
    );
  }

  // Mock data for contacts
  List<Map<String, dynamic>> contacts = [
    {
      'name': 'John Doe',
      'role': 'President',
      'phone': '+1 234 567 8901',
      'email': 'john.doe@association.com',
      'image': Icons.person,
    },
    {
      'name': 'Jane Smith',
      'role': 'Vice President',
      'phone': '+1 234 567 8902',
      'email': 'jane.smith@association.com',
      'image': Icons.person,
    },
    {
      'name': 'Mike Johnson',
      'role': 'Secretary',
      'phone': '+1 234 567 8903',
      'email': 'mike.johnson@association.com',
      'image': Icons.person,
    },
    {
      'name': 'Sarah Wilson',
      'role': 'Treasurer',
      'phone': '+1 234 567 8904',
      'email': 'sarah.wilson@association.com',
      'image': Icons.person,
    },
  ];

  // Mock data for alerts
  List<Map<String, dynamic>> alerts = [
    {
      'title': 'Payment Due Reminder',
      'message': 'Your monthly membership fee is due in 3 days.',
      'time': '2 hours ago',
      'type': 'payment',
      'isRead': false,
    },
    {
      'title': 'New Event Announcement',
      'message': 'Annual General Meeting scheduled for next month.',
      'time': '1 day ago',
      'type': 'event',
      'isRead': false,
    },
    {
      'title': 'System Maintenance',
      'message': 'Scheduled maintenance on Sunday from 2 AM to 4 AM.',
      'time': '2 days ago',
      'type': 'system',
      'isRead': true,
    },
    {
      'title': 'Document Update',
      'message': 'New membership guidelines have been published.',
      'time': '3 days ago',
      'type': 'document',
      'isRead': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    double containerHeight = 420.0;

    return Scaffold(
      extendBody: true,
      backgroundColor: Color(0xFF0A0E1A),
      body: _isLoading
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0A0E1A), Color(0xFF1A1F2E)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                        ),
                      ),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Loading amazing events...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0A0E1A),
                    Color(0xFF1A1F2E),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: NestedScrollView(
                physics: NeverScrollableScrollPhysics(),
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      expandedHeight: 80.0, // Reduced from 120.0
                      floating: true,
                      pinned: false,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: SafeArea(
                            child: Padding(
                              padding: EdgeInsets.all(16), // Reduced from 20
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        // Reduced from 50
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                              20), // Reduced from 25
                                        ),
                                        child: Icon(
                                          Icons.account_circle,
                                          color: Colors.white,
                                          size: 24, // Reduced from 30
                                        ),
                                      ),
                                      SizedBox(width: 10), // Reduced from 12
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Welcome back,',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12, // Reduced from 14
                                              ),
                                            ),
                                            Text(
                                              nameController.text.isNotEmpty
                                                  ? nameController.text
                                                  : 'Member',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16, // Reduced from 18
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.notifications_outlined,
                                        color: Colors.white,
                                        size: 22, // Reduced from 26
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 12), // Reduced from 20
                            // News Headlines
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 16), // Reduced from 20
                              padding: EdgeInsets.all(12), // Reduced from 16
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF2D3748).withOpacity(0.8),
                                    Color(0xFF1A202C).withOpacity(0.9),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(
                                    12), // Reduced from 16
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8, // Reduced from 10
                                    offset: Offset(
                                        0, 4), // Reduced from Offset(0, 5)
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 3, // Reduced from 4
                                    height: 32, // Reduced from 40
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF6C5CE7),
                                          Color(0xFFA29BFE)
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  SizedBox(width: 10), // Reduced from 12
                                  Expanded(
                                    child: Text(
                                      newsOrEvents.isNotEmpty
                                          ? newsOrEvents[_currentPage]
                                                  .headLine ??
                                              'Latest News'
                                          : 'Stay tuned for updates',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14, // Reduced from 16
                                        fontWeight: FontWeight.w600,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.trending_up,
                                    color: Color(0xFF6C5CE7),
                                    size: 20, // Reduced from 24
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12), // Reduced from 20
                            // Image Carousel
                            Container(
                              height: 180, // Reduced from 250
                              child: Stack(
                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 16), // Reduced from 20
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          16), // Reduced from 20
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(
                                              0.3), // Reduced opacity from 0.4
                                          blurRadius: 10, // Reduced from 15
                                          offset: Offset(0,
                                              6), // Reduced from Offset(0, 8)
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          16), // Reduced from 20
                                      child: newsOrEvents.isNotEmpty
                                          ? CarouselSlider(
                                              options: CarouselOptions(
                                                height:
                                                    180.0, // Reduced from 250.0
                                                enlargeCenterPage: true,
                                                autoPlay: true,
                                                aspectRatio: 16 / 9,
                                                autoPlayCurve:
                                                    Curves.fastOutSlowIn,
                                                enableInfiniteScroll: true,
                                                autoPlayAnimationDuration:
                                                    Duration(
                                                        milliseconds: 1200),
                                                viewportFraction: 1.0,
                                                onPageChanged: (index, reason) {
                                                  setState(() {
                                                    _currentPage =
                                                        index.toInt();
                                                  });
                                                },
                                              ),
                                              items: newsOrEvents
                                                  .map((newsOrEvent) {
                                                Uint8List bytes = base64Decode(
                                                    newsOrEvent.imageBase64 ??
                                                        '');
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16), // Reduced from 20
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Colors.transparent,
                                                        Colors.black
                                                            .withOpacity(0.3),
                                                      ],
                                                      begin:
                                                          Alignment.topCenter,
                                                      end: Alignment
                                                          .bottomCenter,
                                                    ),
                                                  ),
                                                  child: Image.memory(
                                                    bytes,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                  ),
                                                );
                                              }).toList(),
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Color(0xFF2D3748)
                                                        .withOpacity(0.8),
                                                    Color(0xFF1A202C)
                                                        .withOpacity(0.9),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        16), // Reduced from 20
                                              ),
                                              child: Center(
                                                child: Text(
                                                  'No images available',
                                                  style: TextStyle(
                                                    color: Colors.white60,
                                                    fontSize:
                                                        14, // Reduced from 16
                                                  ),
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                  if (newsOrEvents.isNotEmpty)
                                    Positioned(
                                      bottom: 10, // Reduced from 15
                                      left: 0,
                                      right: 0,
                                      child: DotsIndicator(
                                        dotsCount: newsOrEvents.length,
                                        position: _currentPage.toDouble(),
                                        decorator: DotsDecorator(
                                          color: Colors.white.withOpacity(0.5),
                                          activeColor: Color(0xFF6C5CE7),
                                          size: Size.square(
                                              6.0), // Reduced from 8.0
                                          activeSize: Size(20.0,
                                              6.0), // Reduced from Size(24.0, 8.0)
                                          activeShape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                3), // Reduced from 4
                                          ),
                                          spacing: EdgeInsets.symmetric(
                                              horizontal:
                                                  3.0), // Reduced from 4.0
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16), // Reduced from 30
                            // Number Animation Section
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16), // Reduced from 20
                              child: NumberAnimation(
                                  userDetails: widget.userDetails),
                            ),
                            SizedBox(height: 16), // Reduced from 30
                          ],
                        ),
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        TabBar(
                          controller: _tabController,
                          indicatorColor: Color(0xFF6C5CE7),
                          indicatorWeight: 2, // Reduced from 3
                          indicatorSize: TabBarIndicatorSize.label,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white60,
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14, // Reduced from 16
                          ),
                          unselectedLabelStyle: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 12, // Reduced from 14
                          ),
                          tabs: [
                            Tab(
                              icon: Icon(Icons.event,
                                  size: 18), // Reduced from 20
                              text: 'Events & Payments',
                            ),
                            Tab(
                              icon: Icon(Icons.contacts,
                                  size: 18), // Reduced from 20
                              text: 'Contacts',
                            ),
                            Tab(
                              icon: Icon(Icons.notifications,
                                  size: 18), // Reduced from 20
                              text: 'Alerts',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    // Events & Payments Tab
                    _buildEventsTab(containerHeight),
                    // Contacts Tab
                    _buildContactsTab(),
                    // Alerts Tab
                    _buildAlertsTab(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEventsTab(double containerHeight) {
    return ListView.builder(
      padding:
          EdgeInsets.only(top: 16, bottom: 100), // Reduced top padding from 20
      physics: BouncingScrollPhysics(),
      itemCount: EventsDetails.length,
      itemBuilder: (BuildContext context, int index) {
        final transaction = EventsDetails[index];

        Uint8List? eventPicture = transaction.evenPicture != null
            ? base64Decode(transaction.evenPicture!)
            : null;

        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, 0.3),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _slideAnimationController,
            curve: Interval(
              (index * 0.1).clamp(0.0, 1.0),
              ((index * 0.1) + 0.3).clamp(0.0, 1.0),
              curve: Curves.easeOutCubic,
            ),
          )),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _fadeAnimationController,
                curve: Interval(
                  (index * 0.1).clamp(0.0, 1.0),
                  ((index * 0.1) + 0.5).clamp(0.0, 1.0),
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6), // Reduced horizontal from 20, vertical from 8
              child: Container(
                height: containerHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF2D3748).withOpacity(0.6),
                      Color(0xFF1A202C).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16), // Reduced from 20
                  border: Border.all(
                    color: Color(0xFF6C5CE7).withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.25), // Reduced opacity from 0.3
                      blurRadius: 12, // Reduced from 15
                      offset: Offset(0, 6), // Reduced from Offset(0, 8)
                    ),
                  ],
                ),
                child: CustomEventCard(
                  onPressed: () async {
                    print("Pressed");
                    if (transaction.approved == -1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingPage(
                            userDetails: widget.userDetails,
                            eventId: transaction.accountId ?? 0,
                            eventDate: transaction.evenDate ?? '',
                            eventName: transaction.serviceName ?? '',
                            eventDetails: transaction.description ?? '',
                            eventPrice: transaction.amount ?? '',
                            groupID: transaction.groupId ?? 0,
                            accountID: transaction.accountId ?? 0,
                          ),
                        ),
                      );
                    } else if (transaction.approved == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('This event is pending approval.'),
                          backgroundColor: Color(0xFF6C5CE7),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    } else if (transaction.approved == 2) {
                      List<GetBillReceiptModel> billReceipts =
                          await fetchGetBillReceipt(transaction.billId ?? 0);
                      print(
                          'transaction id : ${billReceipts[0].transactionId}');
                      await printProduct(context, transaction.accountId ?? 0,
                          billReceipts[0].transactionId.toString(), index);
                    }
                  },
                  index: index,
                  isLoading: isLoading,
                  elevatedText: _getElevatedText(transaction.approved),
                  bytesImage: eventPicture,
                  dotsCount: (transaction.evenPicture != null &&
                          transaction.evenPicture!.isNotEmpty)
                      ? 1
                      : 1,
                  items: transaction.evenPicture != null
                      ? [transaction.evenPicture!]
                      : [],
                  eventDate: transaction.evenDate ?? '',
                  eventName: transaction.serviceName ?? '',
                  eventDetails: transaction.description ?? '',
                  eventPrice: transaction.amount ?? '',
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactsTab() {
    return ListView.builder(
      padding:
          EdgeInsets.only(top: 16, bottom: 100), // Reduced top padding from 20
      physics: BouncingScrollPhysics(),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6), // Reduced horizontal from 20, vertical from 8
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2D3748).withOpacity(0.6),
                  Color(0xFF1A202C).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12), // Reduced from 16
              border: Border.all(
                color: Color(0xFF6C5CE7).withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.25), // Reduced opacity from 0.3
                  blurRadius: 8, // Reduced from 10
                  offset: Offset(0, 4), // Reduced from Offset(0, 5)
                ),
              ],
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(12), // Reduced from 16
              leading: Container(
                width: 50, // Reduced from 60
                height: 50, // Reduced from 60
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                  ),
                  borderRadius: BorderRadius.circular(25), // Reduced from 30
                ),
                child: Icon(
                  contact['image'],
                  color: Colors.white,
                  size: 26, // Reduced from 30
                ),
              ),
              title: Text(
                contact['name'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16, // Reduced from 18
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 3), // Reduced from 4
                  Text(
                    contact['role'],
                    style: TextStyle(
                      color: Color(0xFF6C5CE7),
                      fontSize: 13, // Reduced from 14
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6), // Reduced from 8
                  Row(
                    children: [
                      Icon(Icons.phone,
                          color: Colors.white60, size: 14), // Reduced from 16
                      SizedBox(width: 5), // Reduced from 6
                      Text(
                        contact['phone'],
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12, // Reduced from 13
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3), // Reduced from 4
                  Row(
                    children: [
                      Icon(Icons.email,
                          color: Colors.white60, size: 14), // Reduced from 16
                      SizedBox(width: 5), // Reduced from 6
                      Expanded(
                        child: Text(
                          contact['email'],
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12, // Reduced from 13
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF6C5CE7).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6), // Reduced from 8
                    ),
                    child: IconButton(
                      onPressed: () {
                        // Handle phone call
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Calling ${contact['name']}...'),
                            backgroundColor: Color(0xFF6C5CE7),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.phone, color: Color(0xFF6C5CE7)),
                      iconSize: 18, // Reduced from 20
                    ),
                  ),
                  SizedBox(width: 6), // Reduced from 8
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFA29BFE).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6), // Reduced from 8
                    ),
                    child: IconButton(
                      onPressed: () {
                        // Handle email
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Emailing ${contact['name']}...'),
                            backgroundColor: Color(0xFFA29BFE),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.email, color: Color(0xFFA29BFE)),
                      iconSize: 18, // Reduced from 20
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlertsTab() {
    return ListView.builder(
      padding:
          EdgeInsets.only(top: 16, bottom: 100), // Reduced top padding from 20
      physics: BouncingScrollPhysics(),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6), // Reduced horizontal from 20, vertical from 8
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2D3748).withOpacity(0.6),
                  Color(0xFF1A202C).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12), // Reduced from 16
              border: Border.all(
                color: alert['isRead']
                    ? Colors.transparent
                    : Color(0xFF6C5CE7).withOpacity(0.4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.25), // Reduced opacity from 0.3
                  blurRadius: 8, // Reduced from 10
                  offset: Offset(0, 4), // Reduced from Offset(0, 5)
                ),
              ],
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(12), // Reduced from 16
              leading: Container(
                width: 42, // Reduced from 50
                height: 42, // Reduced from 50
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getAlertColors(alert['type']),
                  ),
                  borderRadius: BorderRadius.circular(21), // Reduced from 25
                ),
                child: Icon(
                  _getAlertIcon(alert['type']),
                  color: Colors.white,
                  size: 20, // Reduced from 24
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      alert['title'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14, // Reduced from 16
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (!alert['isRead'])
                    Container(
                      width: 6, // Reduced from 8
                      height: 6, // Reduced from 8
                      decoration: BoxDecoration(
                        color: Color(0xFF6C5CE7),
                        borderRadius:
                            BorderRadius.circular(3), // Reduced from 4
                      ),
                    ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4), // Reduced from 6
                  Text(
                    alert['message'],
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12, // Reduced from 14
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 6), // Reduced from 8
                  Text(
                    alert['time'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11, // Reduced from 12
                    ),
                  ),
                ],
              ),
              trailing: PopupMenuButton(
                icon: Icon(Icons.more_vert,
                    color: Colors.white60, size: 20), // Reduced size
                color: Color(0xFF2D3748),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(
                          alert['isRead']
                              ? Icons.mark_as_unread
                              : Icons.mark_email_read,
                          color: Colors.white70,
                          size: 16, // Reduced from 18
                        ),
                        SizedBox(width: 6), // Reduced from 8
                        Text(
                          alert['isRead'] ? 'Mark as unread' : 'Mark as read',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        alerts[index]['isRead'] = !alert['isRead'];
                      });
                    },
                  ),
                  PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(Icons.delete,
                            color: Colors.red, size: 16), // Reduced from 18
                        SizedBox(width: 6), // Reduced from 8
                        Text(
                          'Delete',
                          style: TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        alerts.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Color> _getAlertColors(String type) {
    switch (type) {
      case 'payment':
        return [Color(0xFFE74C3C), Color(0xFFFF6B6B)];
      case 'event':
        return [Color(0xFF6C5CE7), Color(0xFFA29BFE)];
      case 'system':
        return [Color(0xFF17A2B8), Color(0xFF20C997)];
      case 'document':
        return [Color(0xFF28A745), Color(0xFF40E0D0)];
      default:
        return [Color(0xFF6C5CE7), Color(0xFFA29BFE)];
    }
  }

  String _getElevatedText(int? approved) {
    switch (approved) {
      case -1:
        return 'Book Now';
      case 0:
        return 'Pending';
      case 2:
        return 'Download Ticket';
      default:
        return 'Unknown';
    }
  }

  IconData _getAlertIcon(String type) {
    switch (type) {
      case 'payment':
        return Icons.payment;
      case 'event':
        return Icons.event;
      case 'system':
        return Icons.settings;
      case 'document':
        return Icons.description;
      default:
        return Icons.notifications;
    }
  }
}

// Add this class to fix the delegate error
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.transparent,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
