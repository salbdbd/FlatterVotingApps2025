import 'package:association/pages/Home/homepage/widgets/contacts/controller/contact_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MemberListScreen extends StatelessWidget {
  final MemberController controller = Get.put(MemberController());

  MemberListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Member List'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.errorMessage.value.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        } else {
          return ListView.builder(
            itemCount: controller.memberList.length,
            itemBuilder: (context, index) {
              final member = controller.memberList[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(member.memberName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.memberCode),
                      Text(member.mobileNo),
                      Text(member.detailsCaption),
                    ],
                  ),
                  trailing: Text('Brand ID: ${member.brandId}'),
                ),
              );
            },
          );
        }
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.fetchMembers(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
