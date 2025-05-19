import 'package:flutter/material.dart';
import 'package:qwicky/screens/Main/history_screen.dart';
import 'package:qwicky/screens/Main/main_services_screen.dart';
import 'package:qwicky/screens/Main/profile_screen.dart';
import 'package:qwicky/widgets/app_bart.dart';
import 'package:qwicky/widgets/colors.dart';
import 'package:qwicky/widgets/nav_bar.dart';
import 'package:qwicky/widgets/service_item.dart';

class HomeScreen extends StatefulWidget {
  final String address;
  const HomeScreen({super.key, required this.address});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Default: Home

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // List of screens for navigation
    final List<Widget> screens = [
      HomeContent(address: widget.address),
      const HistoryScreen(),
      ProfileScreen(address: widget.address),
    ];
    return Scaffold(
      appBar: CustomAppBar(address: widget.address), 
      body: screens[_selectedIndex], // Display selected screen
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final String address;
  const HomeContent({super.key, required this.address});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Box
          Padding(
            padding: EdgeInsets.all(screenHeight * 0.013),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderColor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search something',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          // Quick Services Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
            child: Text(
              'Quick Services',
              style: TextStyle(
                fontSize: screenHeight * 0.03,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 10),
          // First Row (3 items)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ServiceItem(
                image: 'assets/housekeeping.png',
                text: 'Housekeeping',
                width: screenWidth / 3.5,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainServicesScreen(
                      address: widget.address,
                      serviceType: 'Domestic',
                    ),
                  ),
                ),
              ),
              ServiceItem(
                image: 'assets/patient_care.png',
                text: 'Patient Care',
                width: screenWidth / 3.5,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainServicesScreen(
                      address: widget.address,
                      serviceType: 'Domestic',
                    ),
                  ),
                ),
              ),
              ServiceItem(
                image: 'assets/babysitter.png',
                text: 'Babysitter',
                width: screenWidth / 3.5,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainServicesScreen(
                      address: widget.address,
                      serviceType: 'Domestic',
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          // Second Row (3 items)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ServiceItem(
                image: 'assets/japamaid.png',
                text: 'Japamaid',
                width: screenWidth / 3.5,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainServicesScreen(
                      address: widget.address,
                      serviceType: 'Domestic',
                    ),
                  ),
                ),
              ),
              ServiceItem(
                image: 'assets/elderly_care.png',
                text: 'Elderly Care',
                width: screenWidth / 3.5,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainServicesScreen(
                      address: widget.address,
                      serviceType: 'Domestic',
                    ),
                  ),
                ),
              ),
              ServiceItem(
                image: 'assets/nurse.png',
                text: 'Nurse',
                width: screenWidth / 3.5,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainServicesScreen(
                      address: widget.address,
                      serviceType: 'Domestic',
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Extended Services Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
            child: Text(
              'Extended Services',
              style: TextStyle(
                fontSize: screenHeight * 0.03,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 10),
          // First Row (3 items)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ServiceItem(
                image: 'assets/home_maid.png',
                text: 'Home Maid',
                width: screenWidth / 3.5,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainServicesScreen(
                      address: widget.address,
                      serviceType: 'Domestic',
                    ),
                  ),
                ),
              ),
              ServiceItem(
                image: 'assets/home_chef.png',
                text: 'Home Chef',
                width: screenWidth / 3.5,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainServicesScreen(
                      address: widget.address,
                      serviceType: 'Domestic',
                    ),
                  ),
                ),
              ),
              ServiceItem(
                image: 'assets/security.png',
                text: 'Security',
                width: screenWidth / 3.5,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainServicesScreen(
                      address: widget.address,
                      serviceType: 'Domestic',
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          // Second Row (2 items)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ServiceItem(
                image: 'assets/driver.png',
                text: 'Driver',
                width: screenWidth / 3.5,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainServicesScreen(
                      address: widget.address,
                      serviceType: 'Domestic',
                    ),
                  ),
                ),
              ),
              ServiceItem(
                image: 'assets/office_boy.png',
                text: 'Office Boy',
                width: screenWidth / 3.5,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainServicesScreen(
                      address: widget.address,
                      serviceType: 'Domestic',
                    ),
                  ),
                ),
              ),
              SizedBox(width: screenWidth / 3.5), // Spacer for alignment
            ],
          ),
          SizedBox(height: 20),
          // Services We Offer Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
            child: Text(
              'Services We Offer',
              style: TextStyle(
                fontSize: screenHeight * 0.03,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 10),
          // First Row (2 items)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ServiceItem(
                image: 'assets/domestic_services.png',
                text: 'Domestic Services',
                width: screenWidth / 2.5,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainServicesScreen(
                      address: widget.address,
                      serviceType: 'Domestic',
                    ),
                  ),
                ),
              ),
              ServiceItem(
                image: 'assets/commercial_services.png',
                text: 'Commercial Services',
                width: screenWidth / 2.5,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainServicesScreen(
                      address: widget.address,
                      serviceType: 'Commercial',
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          // Second Row (1 item, full-width)
          ServiceItem(
            image: 'assets/corporate_services.png',
            text: 'Corporate Services',
            height: screenHeight * 0.3,
            width: screenWidth - 32,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MainServicesScreen(
                  address: widget.address,
                  serviceType: 'Corporate',
                ),
              ),
            ),
            margin: EdgeInsets.symmetric(horizontal: screenHeight * 0.04),
          ),
          SizedBox(height: 20),
          // Most Booked Services Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
            child: Text(
              'Most Booked Services',
              style: TextStyle(
                fontSize: screenHeight * 0.03,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 10),
          Container(
            height: 200, // Larger images
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ServiceItem(
                  image: 'assets/housekeeping.png',
                  text: 'House Keeping',
                  width: screenWidth / 2.5,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainServicesScreen(
                        address: widget.address,
                        serviceType: 'Domestic',
                      ),
                    ),
                  ),
                  margin: EdgeInsets.only(left: 16, right: 8),
                ),
                ServiceItem(
                  image: 'assets/maid.png',
                  text: 'Maid',
                  width: screenWidth / 2.5,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainServicesScreen(
                        address: widget.address,
                        serviceType: 'Domestic',
                      ),
                    ),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 8),
                ),
                ServiceItem(
                  image: 'assets/security-1.png',
                  text: 'Security',
                  width: screenWidth / 2.5,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainServicesScreen(
                        address: widget.address,
                        serviceType: 'Domestic',
                      ),
                    ),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 8),
                ),
                ServiceItem(
                  image: 'assets/driver.png',
                  text: 'Driver',
                  width: screenWidth / 2.5,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainServicesScreen(
                        address: widget.address,
                        serviceType: 'Domestic',
                      ),
                    ),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 8),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          // Refer and Get Discounts Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 10,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
                border: Border.all(color: AppColors.borderColor),
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Theme.of(context).primaryColor,
                  ],
                ),
              ),
              padding: EdgeInsets.all(screenHeight * 0.03),
              child: Row(
                children: [
                  Image.asset(
                    'assets/refer_discount.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, size: 80),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Refer and get discounts',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Invite and get offers and free services',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
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
          SizedBox(height: 20),
        ],
      ),
    );
  }
}