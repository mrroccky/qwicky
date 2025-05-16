import 'package:flutter/material.dart';
import 'package:qwicky/screens/Main/cart_screen.dart';
import 'package:qwicky/screens/Main/history_screen.dart';
import 'package:qwicky/screens/Main/profile_screen.dart';
import 'package:qwicky/widgets/nav_bar.dart';

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
    const HomeContent(), 
    const HistoryScreen(),
    ProfileScreen(address: widget.address),
  ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false, // Disable default back arrow
        leading: null, // Ensure no leading widget
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.45, //45% from left to center
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.address,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true, // Allow text to wrap naturally
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const CartScreen(),
                ));
              },
              child: Image.asset(
                'assets/Cart.png', // Adjusted path as provided
                width: 35,
                height: 35,
              ),
            ),
          ],
        ),
      ),
      body: screens[_selectedIndex], // Display selected screen
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
// ----------------main home screen---------------------------------------------
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Welcome to Home Screen',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}