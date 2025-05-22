import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class BookedService {
  final String image;
  final String title;
  final int quantity;
  final DateTime bookedOn;

  BookedService({
    required this.image,
    required this.title,
    required this.quantity,
    required this.bookedOn,
  });

  factory BookedService.fromJson(Map<String, dynamic> json) {
    return BookedService(
      image: json['service_image'] ?? 'assets/placeholder.png', // Fallback image
      title: json['service_title'] ?? 'Unknown Service',
      quantity: 1, // Hardcoded as per your UI, adjust if needed
      bookedOn: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
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
                          // Header
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
                          // Booked Services
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: bookedServices.length,
                            itemBuilder: (context, index) {
                              final service = bookedServices[index];
                              return HistoryCard(service: service);
                            },
                          ),
                        ],
                      ),
                    ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  final BookedService service;

  const HistoryCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Card(
      color: Colors.white,
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
            // Right: Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      service.title,
                      style: TextStyle(
                        fontSize: screenHeight * 0.03,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Quantity
                    Text(
                      '${service.quantity} ${service.quantity == 1 ? 'service' : 'services'}',
                      style: TextStyle(
                        fontSize: screenHeight * 0.022,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Booked On
                    Text(
                      'Booked on: ${DateFormat('yyyy-MM-dd').format(service.bookedOn)}',
                      style: TextStyle(
                        fontSize: screenHeight * 0.022,
                        color: Colors.grey,
                      ),
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