import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qwicky/models/service_model.dart';
import 'package:qwicky/provider/user_provider.dart';
import 'package:qwicky/screens/Main/bloc/cart_block_part/cart_bloc.dart';
import 'package:qwicky/widgets/profile_form.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

class ServiceReview {
  final String reviewId;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final int serviceId;
  final int userId;
  final int professionalId;

  ServiceReview({
    required this.reviewId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.serviceId,
    required this.userId,
    required this.professionalId,
  });

  factory ServiceReview.fromJson(Map<String, dynamic> json) {
    return ServiceReview(
      reviewId: json['service_review_id'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      serviceId: json['service_id'] as int,
      userId: json['user_id'] as int,
      professionalId: json['professional_id'] as int,
    );
  }
}

class ServiceReviewDialog extends StatelessWidget {
  final List<ServiceReview> reviews;

  const ServiceReviewDialog({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.6,
          maxWidth: 400,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'All Reviews',
                style: TextStyle(
                  fontSize: screenHeight * 0.025,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: reviews.isEmpty
                  ? const Center(child: Text('No reviews available'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final review = reviews[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.star, color: Colors.green, size: screenHeight * 0.02),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${review.rating}',
                                      style: TextStyle(
                                        fontSize: screenHeight * 0.02,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  review.comment,
                                  style: TextStyle(fontSize: screenHeight * 0.018),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Posted on: ${review.createdAt.toLocal().toString().split('.')[0]}',
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.016,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceCard extends StatefulWidget {
  final ServiceModel service;

  const ServiceCard({super.key, required this.service});

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool _showProfileForm = false;

  List<String> getCleanDescriptionPoints() {
    List<String> points = widget.service.description
        .split(RegExp(r'\\\\n|\\n|\n'))
        .map((point) => point.trim())
        .where((point) => point.isNotEmpty)
        .toList();
    return points;
  }

  Future<List<ServiceReview>> _fetchReviews() async {
    try {
      final String apiUrl = dotenv.env['BACK_END_API'] ?? 'http://192.168.1.37:3000/api';
      final response = await http.get(Uri.parse('$apiUrl/servicereview/service/${widget.service.serviceId}'));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => ServiceReview.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  String _calculateAverageRating(List<ServiceReview> reviews) {
    if (reviews.isEmpty) return 'No Ratings';
    final total = reviews.fold<double>(0, (sum, review) => sum + review.rating);
    final average = total / reviews.length;
    return average == average.roundToDouble() ? '${average.round()}' : average.toStringAsFixed(1);
  }

  void _showReviewsDialog(BuildContext context, List<ServiceReview> reviews) {
    showDialog(
      context: context,
      builder: (context) => ServiceReviewDialog(reviews: reviews),
    );
  }

  void _checkProfileAndAddToCart(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userData = userProvider.userData;

    // Check if the profile is incomplete (missing required fields)
    if (userData == null ||
        userData['first_name']?.toString().trim().isEmpty == true ||
        userData['last_name']?.toString().trim().isEmpty == true ||
        userData['address_line']?.toString().trim().isEmpty == true ||
        userData['phone_number']?.toString().trim().isEmpty == true) {
      print('Profile incomplete or no user data, showing profile form overlay');
      setState(() {
        _showProfileForm = true;
      });
    } else {
      // Profile is complete, check userId and add to cart
      final userId = userData['user_id']?.toString();
      if (userId == null || userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID not found. Please log in again.')),
        );
        return;
      }
      print('Profile complete, adding service to cart with userId: $userId');
      context.read<CartBloc>().add(AddServiceToCart(widget.service, userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColor = Theme.of(context).primaryColor;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cleanPoints = getCleanDescriptionPoints();

    return Stack(
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.only(bottom: 16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                      child: SizedBox(
                        width: screenWidth * 0.4,
                        height: double.infinity,
                        child: Image.network(
                          widget.service.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported, size: 120),
                              ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: FutureBuilder<List<ServiceReview>>(
                        future: _fetchReviews(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox.shrink();
                          }
                          
                          final reviews = snapshot.data ?? [];
                          final averageRating = _calculateAverageRating(reviews);
                          
                          if (reviews.isEmpty || averageRating == 'No Ratings') {
                            return const SizedBox.shrink();
                          }
                          
                          return GestureDetector(
                            onTap: () => _showReviewsDialog(context, reviews),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.star, color: Colors.green, size: 14),
                                      const SizedBox(width: 2),
                                      Text(
                                        averageRating,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'View All',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.service.title,
                          style: TextStyle(
                            fontSize: screenHeight * 0.028,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12.0,
                          runSpacing: 4.0,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _checkProfileAndAddToCart(context);
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
        ),
        if (_showProfileForm)
          Container(
            color: Colors.black54,
            child: Center(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ProfileFormWidget(
                  address: '',
                  isModal: true,
                  onSave: () {
                    final userProvider = Provider.of<UserProvider>(context, listen: false);
                    final userId = userProvider.userData?['user_id']?.toString();
                    if (userId == null || userId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User ID not found after saving profile. Please log in again.')),
                      );
                      return;
                    }
                    setState(() {
                      _showProfileForm = false;
                    });
                    context.read<CartBloc>().add(AddServiceToCart(widget.service, userId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${widget.service.title} added to cart!')),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}