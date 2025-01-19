import 'package:flutter/material.dart';

class CustomCart extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String description;

  const CustomCart({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0,right: 10, bottom: 10),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Color(0xff15212D),

          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              CircularImage(imageUrl: imageUrl),
              SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      description,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CircularImage extends StatelessWidget {
  final String imageUrl;

  const CircularImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: Colors.white),
        borderRadius: BorderRadius.circular(100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Image.asset(
          imageUrl,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
