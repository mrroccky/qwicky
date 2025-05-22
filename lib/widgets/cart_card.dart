import 'package:flutter/material.dart';
import 'package:qwicky/widgets/cart_item.dart';
import 'package:qwicky/widgets/colors.dart';

class CartItemCard extends StatelessWidget {
  final CartItem cartItem;
  final String uniqueKey;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.cartItem,
    required this.uniqueKey,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final service = cartItem.service;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: AppColors.borderColor),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image (full height)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  service.image,
                  width: width * 0.3,
                  height: height * 0.13,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 80),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title (centered)
                    Text(
                      service.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${cartItem.quantity} Service${cartItem.quantity > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.secondTextColor,
                          ),
                        ),
                        // Delete icon
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: AppColors.primaryColor,
                            size: 24,
                          ),
                          onPressed: onRemove,
                        ),
                      ],
                    ),
                    Text(
                      '₹${(service.price! * cartItem.quantity).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: height * 0.025,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
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