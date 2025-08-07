import 'package:association/pages/Home/homepage/widgets/contacts/controller/contact_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:association/pages/Home/homepage/widgets/utilis/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

class ContactsSection extends StatefulWidget {
  const ContactsSection({super.key});

  @override
  State<ContactsSection> createState() => _ContactsSectionState();
}

class _ContactsSectionState extends State<ContactsSection>
    with AutomaticKeepAliveClientMixin {
  // Keep the widget alive to prevent rebuilds when switching tabs
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final MemberController controller = Get.find<MemberController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(AppConstants.primaryPurple),
          ),
        );
      } else if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Text(
            controller.errorMessage.value,
            style: const TextStyle(color: Colors.white70),
          ),
        );
      } else {
        return Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ListView.builder(
                padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    MediaQuery.of(context).padding.bottom +
                        kBottomNavigationBarHeight +
                        16),
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: controller.memberList.length,
                // Remove fixed itemExtent for responsive height
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: true,
                cacheExtent: 200,
                itemBuilder: (context, index) {
                  final member = controller.memberList[index];
                  return OptimizedContactCard(
                    key: ValueKey('contact_${member.brandId}_$index'),
                    contact: ContactModel(
                      name: member.memberName,
                      role: member.detailsCaption,
                      phone: member.mobileNo,
                      email:
                          '${member.memberCode.replaceAll('/', '_')}@association.com',
                      brandId: member.brandId,
                    ),
                  );
                },
              );
            },
          ),
        );
      }
    });
  }
}

// Data model for better type safety and performance
class ContactModel {
  final String name;
  final String role;
  final String phone;
  final String email;
  final int brandId;

  const ContactModel({
    required this.name,
    required this.role,
    required this.phone,
    required this.email,
    required this.brandId,
  });
}

// Optimized ContactCard with performance improvements
class OptimizedContactCard extends StatelessWidget {
  final ContactModel contact;

  const OptimizedContactCard({
    required this.contact,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isSmallScreen = screenWidth < 360;
            final isMediumScreen = screenWidth < 600;

            return Container(
              constraints: const BoxConstraints(
                minHeight: 120,
                maxHeight: double.infinity,
              ),
              decoration: _buildCardDecoration(),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  splashColor: AppConstants.primaryPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  onTap: null,
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    child: _buildResponsiveLayout(
                        context, isSmallScreen, isMediumScreen),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResponsiveLayout(
      BuildContext context, bool isSmallScreen, bool isMediumScreen) {
    if (isSmallScreen) {
      // Stack layout for very small screens
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildOptimizedAvatar(isSmall: true),
              const SizedBox(width: 12),
              Expanded(child: _buildContactInfo(isCompact: true)),
            ],
          ),
          const SizedBox(height: 12),
          _buildHorizontalActionButtons(context),
        ],
      );
    } else {
      // Standard row layout for larger screens
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildOptimizedAvatar(),
            SizedBox(width: isMediumScreen ? 12 : 16),
            Expanded(child: _buildContactInfo()),
            _buildActionButtons(context, isCompact: isMediumScreen),
          ],
        ),
      );
    }
  }

  // Pre-computed decoration to avoid recreating on each build
  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppConstants.cardBackground.withOpacity(0.7),
          AppConstants.cardBackgroundSecondary.withOpacity(0.9),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppConstants.primaryPurple.withOpacity(0.3),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 6),
          spreadRadius: 1,
        ),
      ],
    );
  }

  Widget _buildOptimizedAvatar({bool isSmall = false}) {
    final size = isSmall ? 48.0 : 56.0;
    final iconSize = isSmall ? 24.0 : 28.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppConstants.primaryPurple, AppConstants.secondaryPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryPurple.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        Icons.person,
        color: Colors.white,
        size: iconSize,
      ),
    );
  }

  Widget _buildContactInfo({bool isCompact = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          contact.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: isCompact ? 16 : 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          contact.role,
          style: TextStyle(
            color: AppConstants.primaryPurple,
            fontSize: isCompact ? 12 : 14,
            fontWeight: FontWeight.w600,
          ),
          maxLines: isCompact ? 1 : 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        _buildContactDetail(Icons.phone, contact.phone, isCompact: isCompact),
        const SizedBox(height: 6),
        _buildContactDetail(Icons.email, contact.email, isCompact: isCompact),
      ],
    );
  }

  Widget _buildContactDetail(IconData icon, String text,
      {bool isCompact = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, color: Colors.white70, size: isCompact ? 12 : 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white70,
              fontSize: isCompact ? 11 : 13,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, {bool isCompact = false}) {
    final buttonSize = isCompact ? 40.0 : 44.0;
    final iconSize = isCompact ? 18.0 : 20.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton(
          Icon(Icons.phone, color: Colors.white, size: iconSize),
          AppConstants.primaryPurple,
          () => _makePhoneCall(contact.phone, context),
          size: buttonSize,
        ),
        const SizedBox(height: 8),
        _buildActionButton(
          Image.asset(
            'assets/Images/whatsapp.png',
            width: iconSize,
            height: iconSize,
            cacheWidth: (iconSize * 2).toInt(),
            cacheHeight: (iconSize * 2).toInt(),
          ),
          Colors.green.shade600,
          () => _openWhatsAppChat(context, contact.phone),
          size: buttonSize,
        ),
      ],
    );
  }

  Widget _buildHorizontalActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _buildHorizontalActionButton(
            Icons.phone,
            'Call',
            AppConstants.primaryPurple,
            () => _makePhoneCall(contact.phone, context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildHorizontalActionButton(
            null,
            'WhatsApp',
            Colors.green.shade600,
            () => _openWhatsAppChat(context, contact.phone),
            customIcon: Image.asset(
              'assets/Images/whatsapp.png',
              width: 18,
              height: 18,
              cacheWidth: 36,
              cacheHeight: 36,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalActionButton(
    IconData? icon,
    String label,
    Color color,
    VoidCallback onTap, {
    Widget? customIcon,
  }) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.8),
            color.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                customIcon ?? Icon(icon, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(Widget widget, Color color, VoidCallback onTap,
      {double size = 44.0}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.8),
            color.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(size / 2),
          onTap: onTap,
          child: Center(child: widget),
        ),
      ),
    );
  }

  void _showActionSnackBar(
      BuildContext context, String message, IconData icon) {
    if (!context.mounted) return; // Check if context is still valid

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppConstants.primaryPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2), // Shorter duration
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber, BuildContext context) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
        if (context.mounted) {
          _showActionSnackBar(
              context, 'Calling ${contact.name}...', Icons.phone);
        }
      } else {
        if (context.mounted) {
          _showActionSnackBar(
              context, 'Could not launch phone call', Icons.error);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showActionSnackBar(context, 'Error making call', Icons.error);
      }
    }
  }

  Future<void> _openWhatsAppChat(
      BuildContext context, String phoneNumber) async {
    // Clean the phone number by removing all non-digit characters except +
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    try {
      // Create proper WhatsApp URL
      final uri = Uri.parse('https://wa.me/88$cleanedNumber');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (context.mounted) {
          _showActionSnackBar(context, 'Opening WhatsApp...', Icons.chat);
        }
      } else {
        if (context.mounted) {
          _showActionSnackBar(
              context, 'Could not launch WhatsApp', Icons.error);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showActionSnackBar(context, 'Error opening WhatsApp', Icons.error);
      }
    }
  }
}
