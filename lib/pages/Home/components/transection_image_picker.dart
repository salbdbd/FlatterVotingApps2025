import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';

class CustomImagePicker extends StatelessWidget {
  final String heading;
  final BorderRadius borderRadius;
  final String? Function(String?)? validator;
  final IconData? suffixIcon;
  final void Function(File?) onImagePicked;
  final File? selectedImage;

  CustomImagePicker({
    Key? key,
    required this.heading,
    this.borderRadius = const BorderRadius.all(Radius.circular(10.0)),
    this.validator,
    this.suffixIcon,
    required this.onImagePicked,
    this.selectedImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                heading,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.white
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          DottedBorder(
            dashPattern: [8, 4],
            strokeWidth: 2,
            color: const Color(0xff9CBEE5),
            child: GestureDetector(
              onTap: () {
                _showImageSourceActionSheet(context);
              },
              child: Container(
                width: double.infinity,
                height: 150,
                child: Center(
                  child: selectedImage == null
                      ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        color: Color(0xff1D71B8),
                        size: 24,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "Upload Image",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          height: 20 / 14,
                          color: Color(0xFF1D71B8),
                        ),
                      ),
                    ],
                  )
                      : Container(
                    height: 140,
                    width: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.only(top: 10),
                    child: Image.file(
                      selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          if (selectedImage != null && _getImageSizeInMB(selectedImage!) > 5)
            const Row(
              children: [
                Icon(
                  Icons.error,
                  color: Colors.red,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  "Max size 5MB",
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  _pickImage(context, ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(context, ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  double _getImageSizeInMB(File imageFile) {
    int bytes = imageFile.lengthSync();
    double megabytes = bytes / (1024 * 1024);
    return megabytes;
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        final file = File(image.path);
        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image size should be less than 5MB.'),
              backgroundColor: Colors.red,
            ),
          );
          onImagePicked(null);
        } else {
          onImagePicked(file);
        }
      } else {
        onImagePicked(null);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }
}
