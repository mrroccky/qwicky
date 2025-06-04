import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qwicky/provider/user_provider.dart';
import 'package:qwicky/screens/Main/history_screen.dart';
import 'package:qwicky/screens/Main/main_services_screen.dart';
import 'package:qwicky/screens/Main/profile_screen.dart';
import 'package:qwicky/widgets/app_bart.dart';
import 'package:qwicky/widgets/colors.dart';
import 'package:qwicky/widgets/home_content_part.dart';
import 'package:qwicky/widgets/nav_bar.dart';
import 'package:qwicky/widgets/service_item.dart';

class HomeScreen extends StatefulWidget {
  final String address;
  final String city;
  const HomeScreen({super.key, required this.address, required this.city});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // Fetch userId from UserProvider
  Future<void> _loadUserId() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userIdString = userProvider.userData?['user_id']?.toString();
    final userId = userIdString != null ? int.tryParse(userIdString) : null;

    setState(() {
      _userId = userId;
    });

    print('Loaded userId from UserProvider: $_userId');

    if (_userId == null) {
      print('No userId found in UserProvider, redirecting to login');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID not found. Please log in again.')),
        );
        Navigator.of(context).pushReplacementNamed('/login');
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeContent(address: widget.address, city: widget.city),
      _userId == null
          ? const Center(child: CircularProgressIndicator())
          : HistoryScreen(userId: _userId!),
      ProfileScreen(address: widget.address),
    ];

    return Scaffold(
      appBar: CustomAppBar(address: widget.address),
      body: screens[_selectedIndex],
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final String address;
  final String city;
  const HomeContent({super.key, required this.address, required this.city});

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
                      serviceType: 'Quick', city: widget.city,
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
                      serviceType: 'Quick',city: widget.city,
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
                      serviceType: 'Quick',city: widget.city,
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
                      serviceType: 'Quick',city: widget.city,
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
                      serviceType: 'Quick',city: widget.city,
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
                      serviceType: 'Quick',city: widget.city,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Include second half
          HomeContentPart(
            address: widget.address,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            city: widget.city,
          ),
        ],
      ),
    );
  }
}