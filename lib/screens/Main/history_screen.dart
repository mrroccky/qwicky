import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:qwicky/widgets/comment_dialog.dart';
import 'package:qwicky/widgets/rating_widget.dart';

class BookedService {
  final String image;
  final String title;
  final int quantity;
  final DateTime bookedOn;
  final String status;
  final int serviceId;
  final int professionalId;
  final int bookingId;

  BookedService({
    required this.image,
    required this.title,
    required this.quantity,
    required this.bookedOn,
    required this.status,
    required this.serviceId,
    required this.professionalId,
    required this.bookingId,
  });

  factory BookedService.fromJson(Map<String, dynamic> json) {
    return BookedService(
      image: json['service_image'] ?? 'assets/placeholder.png',
      title: json['service_title'] ?? 'Unknown Service',
      quantity: 1,
      bookedOn: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'pending',
      serviceId: json['service_id'] ?? 0,
      professionalId: json['professional_id'] ?? 0,
      bookingId: json['booking_id'] ?? 0,
    );
  }
}

class HistoryScreen extends StatefulWidget {
  final int? userId;

  const HistoryScreen({super.key, required this.userId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<BookedService> bookedServices = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    try {
      final String apiUrl = dotenv.env['BACK_END_API'] ?? 'http://192.168.1.37:3000/api';
      final response = await http.get(
        Uri.parse('$apiUrl/bookings/user/${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          bookedServices = data.map((json) => BookedService.fromJson(json)).toList();
          isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          bookedServices = [];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load bookings: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 50, color: Colors.red),
                      const SizedBox(height: 20),
                      Text(
                        errorMessage!,
                        style: const TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ],
                  ),
                )
              : bookedServices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'assets/no-history.json',
                            width: 200,
                            height: 200,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'No Booking History',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              left: screenHeight * 0.03,
                              top: screenHeight * 0.03,
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/p-booked.png',
                                  width: screenHeight * 0.05,
                                  height: screenHeight * 0.05,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const SizedBox(),
                                ),
                                SizedBox(width: screenHeight * 0.01),
                                Text(
                                  'Previously Booked',
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.033,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: bookedServices.length,
                            itemBuilder: (context, index) {
                              final service = bookedServices[index];
                              return HistoryCard(service: service, userId: widget.userId!);
                            },
                          ),
                        ],
                      ),
                    ),
    );
  }
}

class HistoryCard extends StatefulWidget {
  final BookedService service;
  final int userId;

  const HistoryCard({super.key, required this.service, required this.userId});

  @override
  State<HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<HistoryCard> {
  String? _serviceReviewId;
  String? _professionalReviewId;
  int? _serviceRating;
  int? _professionalRating;
  bool _serviceRated = false;
  bool _professionalRated = false;

  void _onRatingSubmitted(String targetType, String reviewId, int rating) {
    setState(() {
      if (targetType == 'service') {
        _serviceReviewId = reviewId;
        _serviceRating = rating;
        _serviceRated = true;
      } else {
        _professionalReviewId = reviewId;
        _professionalRating = rating;
        _professionalRated = true;
      }
    });

    if (_serviceRated && _professionalRated &&
        _serviceReviewId != null && _professionalReviewId != null) {
      showDialog(
        context: context,
        builder: (context) => CommentDialog(
          serviceReviewId: _serviceReviewId!,
          professionalReviewId: _professionalReviewId!,
          serviceRating: _serviceRating!,
          professionalRating: _professionalRating!,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompleted = widget.service.status.toLowerCase() == 'completed';

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 16),
      child: IntrinsicHeight(
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                  child: Image.network(
                    widget.service.image,
                    width: screenWidth * 0.3,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset(
                          'assets/placeholder.png',
                          width: screenWidth * 0.3,
                          fit: BoxFit.cover,
                        ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          widget.service.title,
                          style: TextStyle(
                            fontSize: screenHeight * 0.03,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.service.quantity} ${widget.service.quantity == 1 ? 'service' : 'services'}',
                          style: TextStyle(
                            fontSize: screenHeight * 0.022,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Booked on: ${DateFormat('yyyy-MM-dd').format(widget.service.bookedOn)}',
                          style: TextStyle(
                            fontSize: screenHeight * 0.022,
                            color: Colors.grey,
                          ),
                        ),
                        if (isCompleted) ...[
                          const SizedBox(height: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Please give rating for:',
                                style: TextStyle(
                                  fontSize: screenHeight * 0.022,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Service:',
                                    style: TextStyle(fontSize: screenHeight * 0.02),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: RatingWidget(
                                      bookingId: widget.service.bookingId,
                                      userId: widget.userId,
                                      targetId: widget.service.serviceId,
                                      serviceId: widget.service.serviceId,
                                      targetType: 'service',
                                      onRatingSubmitted: (reviewId, rating) {
                                        _onRatingSubmitted('service', reviewId, rating);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Professional:',
                                    style: TextStyle(fontSize: screenHeight * 0.02),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: RatingWidget(
                                      bookingId: widget.service.bookingId,
                                      userId: widget.userId,
                                      targetId: widget.service.professionalId,
                                      serviceId: widget.service.serviceId,
                                      targetType: 'professional',
                                      onRatingSubmitted: (reviewId, rating) {
                                        _onRatingSubmitted('professional', reviewId, rating);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green : Colors.amber,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.service.status.capitalize(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringCapitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}