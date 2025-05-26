import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qwicky/models/service_model.dart';
import 'package:qwicky/screens/Main/bloc/cart_block_part/cart_bloc.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;

  const ServiceCard({super.key, required this.service});

  // Helper method to clean and parse description points
  List<String> getCleanDescriptionPoints() {
    // Split by various newline patterns and clean each point
    List<String> points = service.description
        .split(RegExp(r'\\\\n|\\n|\n'))
        .map((point) => point.trim())
        .where((point) => point.isNotEmpty)
        .toList();
    
    return points;
  }

  @override
  Widget build(BuildContext context) {
    final appColor = Theme.of(context).primaryColor;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cleanPoints = getCleanDescriptionPoints();
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left: Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              child: Image.network(
                service.image,
                width: screenWidth * 0.4,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, size: 120),
              ),
            ),
            // Right: Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
                  children: [
                    // Title
                    Text(
                      service.title,
                      style: TextStyle(
                        fontSize: screenHeight * 0.028,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Bullet points (side by side)
                    Wrap(
                      spacing: 12.0, // Horizontal gap between points
                      runSpacing: 4.0, // Vertical gap between lines
                      children: cleanPoints.map((point) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontSize: 16)),
                            Flexible(
                              child: Text(
                                point,
                                style: TextStyle(fontSize: screenHeight * 0.021),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    // Add to Cart Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            context.read<CartBloc>().add(AddServiceToCart(service));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Add to Cart',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}