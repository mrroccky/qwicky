import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:qwicky/screens/Main/main_services_screen.dart';
import 'package:qwicky/widgets/colors.dart';

class CarouselSliderMain extends StatefulWidget {
  final String address;

  const CarouselSliderMain({super.key, required this.address});

  @override
  State<CarouselSliderMain> createState() => _CarouselSliderMainState();
}

class _CarouselSliderMainState extends State<CarouselSliderMain> {
  int _currentIndex = 0;

  // carousel items
  final List<Map<String, dynamic>> _carouselItems = [
    {
      'image': 'assets/banner1.png',
      'text': 'Book Housekeeping Now!',
      'serviceType': 'Domestic',
    },
    {
      'image': 'assets/banner2.png',
      'text': 'Hire a Nurse Today!',
      'serviceType': 'Domestic',
    },
    {
      'image': 'assets/banner3.png',
      'text': 'Secure Your Home!',
      'serviceType': 'Domestic',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: screenHeight * 0.3,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            viewportFraction: 0.9,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: _carouselItems.map((item) {
            return Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainServicesScreen(
                          address: widget.address,
                          serviceType: item['serviceType'],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: screenWidth * 0.9,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        children: [
                          // Image
                          Image.asset(
                            item['image'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey,
                              child: const Icon(Icons.image_not_supported, size: 50),
                            ),
                          ),
                          // Gradient overlay for text readability
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: screenHeight * 0.1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.9),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Text
                          Positioned(
                            bottom: 10,
                            left: 10,
                            right: 10,
                            child: Text(
                              item['text'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenHeight * 0.03,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    blurRadius: 5.0,
                                    color: Colors.black54,
                                    offset: Offset(2.0, 2.0),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _carouselItems.asMap().entries.map((entry) {
            return Container(
              width: _currentIndex == entry.key ? 12.0 : 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == entry.key
                    ? Theme.of(context).primaryColor
                    : AppColors.borderColor,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}