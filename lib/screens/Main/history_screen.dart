import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:qwicky/widgets/colors.dart';
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
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Dummy data
  final List<BookedService> bookedServices = [
    BookedService(
      image: 'assets/housekeeping.png',
      title: 'Housekeeping',
      quantity: 1,
      bookedOn: DateTime(2025, 5, 15),
    ),
    BookedService(
      image: 'assets/nurse.png',
      title: 'Nurse',
      quantity: 2,
      bookedOn: DateTime(2025, 5, 10),
    ),
    BookedService(
      image: 'assets/security.png',
      title: 'Security',
      quantity: 3,
      bookedOn: DateTime(2025, 5, 5),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: bookedServices.isEmpty
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
              child: Image.asset(
                service.image,
                width: screenWidth * 0.3,
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
                        color: AppColors.secondTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Booked On
                    Text(
                      'Booked on: ${DateFormat('yyyy-MM-dd').format(service.bookedOn)}',
                      style: TextStyle(
                        fontSize: screenHeight * 0.022,
                        color: AppColors.secondTextColor,
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