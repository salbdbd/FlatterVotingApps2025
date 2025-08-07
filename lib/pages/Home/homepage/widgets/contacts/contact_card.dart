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

class _ContactsSectionState extends State<ContactsSection> {
  @override
  Widget build(BuildContext context) {
    final MemberController controller = Get.find<MemberController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      } else if (controller.errorMessage.value.isNotEmpty) {
        return Center(child: Text(controller.errorMessage.value));
      } else {
        return Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            // physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: controller.memberList.length,
            itemBuilder: (context, index) => ContactCard(
              contact: {
                'name': controller.memberList[index].memberName,
                'role': controller.memberList[index].detailsCaption,
                'phone': controller.memberList[index].mobileNo,
                'email':
                    '${controller.memberList[index].memberCode.replaceAll('/', '_')}@association.com',
                'image': Icons.person,
                'brandId': controller.memberList[index].brandId,
              },
            ),
          ),
        );
      }
    });
  }
}

// Keep your existing ContactCard class exactly as is
class ContactCard extends StatelessWidget {
  final Map<String, dynamic> contact;

  const ContactCard({required this.contact, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
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
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: AppConstants.primaryPurple.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            onTap: null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildAvatar(),
                  const SizedBox(width: 16),
                  Expanded(child: _buildContactInfo(context)),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppConstants.primaryPurple, AppConstants.secondaryPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryPurple.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(contact['image'], color: Colors.white, size: 28),
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          contact['name'],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          contact['role'],
          style: const TextStyle(
            color: AppConstants.primaryPurple,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _buildContactDetail(Icons.phone, contact['phone']),
        const SizedBox(height: 6),
        _buildContactDetail(Icons.email, contact['email']),
      ],
    );
  }

  Widget _buildContactDetail(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, color: Colors.white70, size: 14),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          Icon(Icons.phone, color: Colors.white),
          AppConstants.primaryPurple,
          () => _makePhoneCall(contact['phone'], context),
        ),
        const SizedBox(height: 8),
        _buildActionButton(
          Image.asset('assets/Images/whatsapp.png', width: 20, height: 20),
          Colors.blueAccent.shade100, // WhatsApp green color
          () => _openWhatsAppChat(context, contact['phone']),
        ),
        const SizedBox(height: 8),
        // _buildActionButton(
        //   Icons.email,
        //   AppConstants.secondaryPurple,
        //   () => _sendEmail(context),
        // ),
      ],
    );
  }

  Widget _buildActionButton(Widget widget, Color? color, VoidCallback onTap) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color?.withOpacity(0.8) ?? Colors.transparent,
            color?.withOpacity(0.6) ?? Colors.transparent
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: color?.withOpacity(0.3) ?? Colors.transparent,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(5.8),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: widget,
          ),
        ),
      ),
    );
  }

  void _showActionSnackBar(
      BuildContext context, String message, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: AppConstants.primaryPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
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
        await launchUrl(launchUri);
      } else {
        throw 'Could not launch phone call';
      }
    } catch (e) {
      _showActionSnackBar(
          context, 'Calling ${contact['name']}...', Icons.phone);
    }
  }

  Future<void> _openWhatsAppChat(
      BuildContext context, String phoneNumber) async {
    // Clean the phone number by removing all non-digit characters
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    try {
      final link = WhatsAppUnilink(
        phoneNumber: cleanedNumber,
      );

      // Convert the WhatsAppUnilink to a Uri
      final uri = Uri.parse('https://wa.me/+88$cleanedNumber');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showActionSnackBar(context, 'Could not launch WhatsApp', Icons.error);
      }
    } catch (e) {
      _showActionSnackBar(context, 'Error opening WhatsApp: $e', Icons.error);
    }
  }
}
