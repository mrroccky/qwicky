
import 'package:flutter/material.dart';

class ServiceItem extends StatelessWidget {
  final String image;
  final String text;
  final double width;
  final double? height;
  final VoidCallback onTap;
  final EdgeInsets margin;

  const ServiceItem({
    super.key,
    required this.image,
    required this.text,
    required this.width,
    this.height,
    required this.onTap,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        width: width,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                image,
                width: width,
                height: height ?? width,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, size: width),
              ),
            ),
            SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}