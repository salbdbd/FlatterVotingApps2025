import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:association/models/loger_item_model.dart';
import 'package:association/pages/Home/components/event_card.dart';
import 'package:association/pages/Home/components/loan_pdf/pdf_page.dart';
import 'package:association/pages/Home/homepage/widgets/accounts/accounts_content_view.dart';
import 'package:association/pages/Home/homepage/widgets/accounts/accounts_loading_view.dart';
import 'package:association/pages/Home/homepage/widgets/accounts/empty_accounts_view.dart';
import 'package:association/pages/Home/homepage/widgets/alerts/alert_card.dart';
import 'package:association/pages/Home/homepage/widgets/contacts/contact_card.dart';

import 'package:association/pages/Home/homepage/widgets/controller/ledger_controller.dart';
import 'package:association/pages/Home/homepage/widgets/utilis/constants.dart';
import 'package:association/pages/Home/model/get_billreceipt_model.dart';
import 'package:association/pages/Home/model/get_w_memberAccountTransaction_model.dart';
import 'package:association/pages/Home/pdf_viewer_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';

import '../../services/api_service.dart';
import '../indexing_page/indexing_page.dart';
import 'components/CountDownAnimation.dart';
import 'components/booking_page.dart';
import 'model/get_newsor_event_model.dart';

class HomePage extends StatefulWidget {
  final UserDetails? userDetails;

  const HomePage({Key? key, this.userDetails}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final TextEditingController _nameController;
  late final PageController _pageController;
  late final TabController _tabController;
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final LedgerController _ledgerController;

  int _currentPage = 0;
  bool _isLoading = false;
  List<bool> _loadingStates = [];
  List<GetNewsorEventModel> _newsOrEvents = [];
  List<GetWMemberAccountTransactionModel> _eventsDetails = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _loadInitialData();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(
      text: widget.userDetails?.selectedCompanyData.name ?? 'Member',
    );
    _pageController = PageController()..addListener(_onPageChanged);
    _tabController = TabController(length: 4, vsync: this);
    _ledgerController = Get.put(
      LedgerController(
        compId: widget.userDetails?.selectedCompanyData.compId ?? 0,
        memberId: widget.userDetails?.selectedCompanyData.memberId ?? 0,
      ),
    );
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
        duration: AppConstants.animationDuration, vsync: this);
    _slideController = AnimationController(
        duration: AppConstants.slideAnimationDuration, vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );
  }

  void _onPageChanged() {
    if (mounted) {
      setState(() {
        _currentPage = _pageController.page?.toInt() ?? 0;
      });
    }
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _fetchNewsOrEvents(),
      _fetchMemberAccountTransactions(),
    ]);

    _loadingStates = List<bool>.filled(_eventsDetails.length, false);
    _fadeController.forward();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });
  }

  Future<void> _fetchNewsOrEvents() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final compId = widget.userDetails?.selectedCompanyData.compId ?? 0;
      final url = '${BaseUrl.baseUrl}/api/v1/GetNewsorEvent/$compId/2';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          'Authorization': BaseUrl.authorization,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _newsOrEvents = jsonResponse
                .map((data) => GetNewsorEventModel.fromJson(data))
                .toList();
          });
        }
      } else {
        throw Exception('Failed to fetch news/events: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching news/events: $e');
      _showErrorSnackBar('Failed to load news and events');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchMemberAccountTransactions() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final compId = widget.userDetails?.selectedCompanyData.compId ?? 0;
      final memberId = widget.userDetails?.selectedCompanyData.memberId ?? 0;
      final url =
          '${BaseUrl.baseUrl}/api/v1/W_MemberAccountTransaction/$compId/$memberId';

      log('Fetching transactions from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          'Authorization': BaseUrl.authorization,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _eventsDetails = jsonResponse
                .map((data) => GetWMemberAccountTransactionModel.fromJson(data))
                .toList();
          });
        }
      } else {
        throw Exception('Failed to fetch transactions: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching transactions: $e');
      _showErrorSnackBar('Failed to load transaction data');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppConstants.errorRed,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pageController.dispose();
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: AppConstants.darkBlue,
      body: _buildMainContent(),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppConstants.darkBlue, AppConstants.lightDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingIndicator(),
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
    );
  }

  Widget _buildMainContent() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppConstants.darkBlue, AppConstants.lightDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: NestedScrollView(
        physics: const NeverScrollableScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(),
          _buildHeaderContent(),
          _buildTabBarHeader(),
        ],
        body: _buildTabBarView(),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 60.0,
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppConstants.primaryPurple,
                AppConstants.secondaryPurple
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.account_circle,
                        color: Colors.white, size: 40),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _nameController.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderContent() {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildNewsHeadline(),
            const SizedBox(height: 12),
            _buildImageCarousel(),
            const SizedBox(height: 16),
            _buildNumberAnimation(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBarHeader() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        TabBar(
          controller: _tabController,
          isScrollable: false,
          indicatorColor: AppConstants.primaryPurple,
          indicatorWeight: 2,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          tabs: const [
            Tab(icon: Icon(Icons.event, size: 14), text: 'Events'),
            Tab(
                icon: Icon(Icons.account_balance_wallet, size: 14),
                text: 'Accounts'),
            Tab(icon: Icon(Icons.contacts, size: 14), text: 'Contacts'),
            Tab(icon: Icon(Icons.notifications, size: 14), text: 'Alerts'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildEventsTab(),
        _buildAccountsTab(),
        const ContactsSection(),
        const AlertsSection(),
      ],
    );
  }

  Widget _buildEventsTab() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 5, bottom: 100),
      physics: const BouncingScrollPhysics(),
      itemCount: _eventsDetails.length,
      itemBuilder: (context, index) => _buildEventCard(index),
    );
  }

  Widget _buildAccountsTab() {
    return Obx(() {
      if (_ledgerController.isLoading) {
        return const AccountsLoadingView();
      }

      if (_ledgerController.ledgerList.isEmpty) {
        return const EmptyAccountsView();
      }

      return AccountsContentView(ledgerController: _ledgerController);
    });
  }

  Widget _buildNewsHeadline() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: _buildCardDecoration(),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppConstants.primaryPurple,
                  AppConstants.secondaryPurple
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _newsOrEvents.isNotEmpty
                  ? _newsOrEvents[_currentPage].headLine ?? 'Latest News'
                  : 'Stay tuned for updates',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
          const Icon(Icons.trending_up,
              color: AppConstants.primaryPurple, size: 20),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _newsOrEvents.isNotEmpty
                  ? _buildCarouselSlider()
                  : _buildEmptyCarousel(),
            ),
          ),
          if (_newsOrEvents.isNotEmpty) _buildCarouselIndicators(),
        ],
      ),
    );
  }

  Widget _buildNumberAnimation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: NumberAnimation(userDetails: widget.userDetails),
    );
  }

  BoxDecoration _buildCardDecoration({Color? borderColor}) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppConstants.cardBackground.withOpacity(0.8),
          AppConstants.cardBackgroundSecondary.withOpacity(0.9),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: borderColor ?? Colors.transparent,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildEventCard(int index) {
    final transaction = _eventsDetails[index];
    final eventPicture = transaction.evenPicture != null
        ? base64Decode(transaction.evenPicture!)
        : null;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Interval(
          (index * 0.1).clamp(0.0, 1.0),
          ((index * 0.1) + 0.3).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      )),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _fadeController,
            curve: Interval(
              (index * 0.1).clamp(0.0, 1.0),
              ((index * 0.1) + 0.5).clamp(0.0, 1.0),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: Container(
            padding: const EdgeInsets.all(10),
            height: 420,
            decoration: _buildCardDecoration(
              borderColor: AppConstants.primaryPurple.withOpacity(0.2),
            ),
            child: CustomEventCard(
              onPressed: () => _handleEventCardPress(transaction, index),
              index: index,
              isLoading: _loadingStates,
              elevatedText: _getElevatedText(transaction.approved),
              bytesImage: eventPicture,
              dotsCount: 1,
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
  }

  Future<void> _handleEventCardPress(
      GetWMemberAccountTransactionModel transaction, int index) async {
    switch (transaction.approved) {
      case -1:
        _navigateToBookingPage(transaction);
        break;
      case 0:
        _showSnackBar('This event is pending approval.');
        break;
      case 2:
        await _downloadTicket(transaction, index);
        break;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.primaryPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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

  Widget _buildCarouselSlider() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 180.0,
        enlargeCenterPage: true,
        autoPlay: true,
        aspectRatio: 16 / 9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: const Duration(milliseconds: 1200),
        viewportFraction: 1.0,
        onPageChanged: (index, reason) => setState(() => _currentPage = index),
      ),
      items: _newsOrEvents.map((newsOrEvent) {
        final bytes = base64Decode(newsOrEvent.imageBase64 ?? '');
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Image.memory(bytes, fit: BoxFit.cover, width: double.infinity),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyCarousel() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.cardBackground.withOpacity(0.8),
            AppConstants.cardBackgroundSecondary.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text(
          'No images available',
          style: TextStyle(color: Colors.white60, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildCarouselIndicators() {
    return Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: DotsIndicator(
        dotsCount: _newsOrEvents.length,
        position: _currentPage.toDouble(),
        decorator: DotsDecorator(
          color: Colors.white.withOpacity(0.5),
          activeColor: AppConstants.primaryPurple,
          size: const Size.square(6.0),
          activeSize: const Size(20.0, 6.0),
          activeShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
          spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        ),
      ),
    );
  }

  void _navigateToBookingPage(GetWMemberAccountTransactionModel transaction) {
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
  }

  Future<void> _downloadTicket(
      GetWMemberAccountTransactionModel transaction, int index) async {
    try {
      final billReceipts = await _fetchBillReceipt(transaction.billId ?? 0);
      if (billReceipts.isNotEmpty) {
        await _printProduct(
          context,
          transaction.accountId ?? 0,
          billReceipts.first.transactionId.toString(),
          index,
        );
      }
    } catch (e) {
      log('Error downloading ticket: $e');
      _showErrorSnackBar('Failed to download ticket');
    }
  }

  Future<List<GetBillReceiptModel>> _fetchBillReceipt(int billId) async {
    try {
      final compId = widget.userDetails?.selectedCompanyData.compId ?? 0;
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/v1/GetBillReceipt/$compId/$billId'),
        headers: {
          'accept': '*/*',
          'Authorization': BaseUrl.authorization,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse
            .map((data) => GetBillReceiptModel.fromJson(data))
            .toList();
      } else {
        throw Exception('Failed to fetch bill receipt: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching bill receipt: $e');
      return [];
    }
  }

  Future<void> _printProduct(
    BuildContext context,
    int serviceId,
    String transactionId,
    int index,
  ) async {
    if (!mounted) return;

    setState(() => _loadingStates[index] = true);

    try {
      final parameters = {
        'ReportId': '6594',
        'ExportType': 'pdf',
        'servceId': serviceId.toString(),
        'MemberId':
            widget.userDetails?.selectedCompanyData.memberId.toString() ?? '',
        'TransId': transactionId,
        'CompId':
            widget.userDetails?.selectedCompanyData.compId.toString() ?? '',
      };

      final uri = Uri.http(
          '103.125.253.59:2003', '/api/erp/commercialRpt/', parameters);

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/pdf',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final tempDir = await getApplicationCacheDirectory();
        final file = File('${tempDir.path}/report.pdf');
        await file.writeAsBytes(bytes, flush: true);

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfViewerScreen(pdfFile: file),
            ),
          );
        }
      } else {
        throw Exception('Failed to generate PDF: ${response.statusCode}');
      }
    } catch (e) {
      log('Error printing product: $e');
      _showErrorSnackBar('Failed to generate PDF');
    } finally {
      if (mounted) setState(() => _loadingStates[index] = false);
    }
  }
}

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
    return Container(color: Colors.transparent, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

extension WidgetExtensions on Widget {
  Widget fadeIn(AnimationController controller,
      {double begin = 0.0, double end = 1.0}) {
    return FadeTransition(
      opacity: Tween<double>(begin: begin, end: end).animate(controller),
      child: this,
    );
  }

  Widget slideUp(AnimationController controller,
      {Offset begin = const Offset(0, 0.3)}) {
    return SlideTransition(
      position:
          Tween<Offset>(begin: begin, end: Offset.zero).animate(controller),
      child: this,
    );
  }
}
