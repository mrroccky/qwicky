import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:qwicky/screens/Main/bloc/cart_block_part/cart_bloc.dart';
import 'package:qwicky/screens/Main/home_screen.dart';
import 'package:qwicky/widgets/cart_item.dart';
import 'package:qwicky/widgets/main_button.dart';
import 'package:qwicky/provider/user_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class PaymentScreen extends StatefulWidget {
  final List<MapEntry<String, CartItem>> cartItems;
  final List<DateTime> selectedDateTimes;
  final double totalAmount;

  const PaymentScreen({
    super.key,
    required this.cartItems,
    required this.selectedDateTimes,
    required this.totalAmount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isLoading = false;
  String? errorMessage;

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userIdString = prefs.getString('userId');
    return userIdString != null ? int.tryParse(userIdString) : null;
  }

  Future<int?> _getProfessionalId(int serviceId) async {
  try {
    final apiUrl = dotenv.env['BACK_END_API'] ?? 'http://192.168.1.37:3000';
    final response = await http.get(
      Uri.parse('$apiUrl/professionals/service/$serviceId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['professional_id'];
    } else if (response.statusCode == 404) {
      print('No professional found for service ID: $serviceId');
      return null;
    } else {
      print('Failed to fetch professional_id: ${response.statusCode} - ${response.body}');
      return null;
    }
  } catch (e) {
    print('Error fetching professional_id: $e');
    return null;
  }
}

  Future<void> _clearCart(int userId) async {
    try {
      final apiUrl = dotenv.env['BACK_END_API'] ?? 'http://192.168.1.37:3000';
      final response = await http.put(
        Uri.parse('$apiUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'service_items_id': '[]'}),
      );
      if (response.statusCode == 200) {
        print('Cleared service_items_id for user $userId');
        // Update CartBloc
        context.read<CartBloc>().add(const LoadCartFromBackend([]));
      } else {
        throw Exception('Failed to clear service_items_id: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error clearing service_items_id: $e');
      throw e;
    }
  }

  Map<String, dynamic> _getAddressData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userData = userProvider.userData;

    if (userData != null) {
      return {
        'address_line': userData['address_line'] ?? '',
        'city': userData['city'] ?? '',
        'state': userData['state'] ?? '',
        'country': userData['country'] ?? '',
        'postal_code': userData['postal_code'] ?? '',
        'latitude': userData['latitude']?.toString() ?? '',
        'longitude': userData['longitude']?.toString() ?? '',
      };
    }

    // Return empty data if no user data is available
    return {
      'address_line': '',
      'city': '',
      'state': '',
      'country': '',
      'postal_code': '',
      'latitude': '',
      'longitude': '',
    };
  }

  Future<void> _createBookings() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final userId = await _getUserId();
    if (userId == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'User not logged in';
      });
      return;
    }

    final addressData = _getAddressData();
    final apiUrl = dotenv.env['BACK_END_API'] ?? 'http://192.168.1.37:3000';
    final bookingsCreated = <int>[];

    try {
      for (int i = 0; i < widget.cartItems.length; i++) {
        final cartItem = widget.cartItems[i].value;
        final serviceId = cartItem.service.serviceId;
        final quantity = cartItem.quantity;
        final dateTime = widget.selectedDateTimes[i];
        final professionalId = await _getProfessionalId(serviceId!);

        if (professionalId == null) {
          throw Exception('No professional found for service ID: $serviceId');
        }

        final bookingAmount = (widget.totalAmount / widget.cartItems.fold(0, (sum, item) => sum + item.value.quantity)) * quantity;

        final payload = {
          'service_id': serviceId,
          'user_id': userId,
          'professional_id': professionalId,
          'scheduled_date': DateFormat('yyyy-MM-dd').format(dateTime),
          'scheduled_time': DateFormat('HH:mm:ss').format(dateTime),
          'payment_status': 'pending',
          'total_amount': bookingAmount,
          'address_line': addressData['address_line'],
          'city': addressData['city'],
          'state': addressData['state'],
          'country': addressData['country'],
          'postal_code': addressData['postal_code'],
          'latitude': addressData['latitude'],
          'longitude': addressData['longitude'],
          'created_at': DateTime.now().toUtc().toIso8601String().replaceAll('T', ' ').substring(0, 19),
        };

        print('Creating booking with payload: $payload');

        final response = await http.post(
          Uri.parse('$apiUrl/bookings'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        if (response.statusCode == 201) {
          final data = jsonDecode(response.body);
          bookingsCreated.add(data['booking_id']);
          print('Booking created successfully: ${data['booking_id']}');
        } else {
          throw Exception('Failed to create booking: ${response.statusCode} - ${response.body}');
        }
      }

      // Clear service_items_id in the backend
      await _clearCart(userId);

      setState(() {
        isLoading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bookings created successfully!')),
      );

      // Navigate to HomeScreen with user's address
      final userAddress = addressData['address_line'].isNotEmpty 
          ? addressData['address_line'] 
          : 'Address not available';
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => HomeScreen(address: userAddress),
        ),
        (route) => false,
      );
    } catch (e) {
      print('Error creating bookings: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Error creating bookings: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final userProvider = Provider.of<UserProvider>(context);
    final userData = userProvider.userData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Booking'),
        backgroundColor: Colors.transparent,
      ),
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
              : Padding(
                  padding: EdgeInsets.all(height * 0.03),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking Summary',
                        style: TextStyle(
                          fontSize: height * 0.034,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Display user address if available
                      if (userData != null && userData['address_line'] != null)
                        Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Service Address',
                                  style: TextStyle(
                                    fontSize: height * 0.025,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  userData['address_line'] ?? 'Address not available',
                                  style: TextStyle(fontSize: height * 0.02),
                                ),
                                if (userData['city'] != null || userData['state'] != null)
                                  Text(
                                    '${userData['city'] ?? ''}, ${userData['state'] ?? ''} ${userData['postal_code'] ?? ''}',
                                    style: TextStyle(fontSize: height * 0.02),
                                  ),
                              ],
                            ),
                          ),
                        ),

                      Expanded(
                        child: ListView.builder(
                          itemCount: widget.cartItems.length,
                          itemBuilder: (context, index) {
                            final cartItem = widget.cartItems[index].value;
                            final dateTime = widget.selectedDateTimes[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cartItem.service.title,
                                      style: TextStyle(
                                        fontSize: height * 0.03,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Quantity: ${cartItem.quantity}'),
                                    Text('Date: ${DateFormat('yyyy-MM-dd').format(dateTime)}'),
                                    Text('Time: ${DateFormat('HH:mm').format(dateTime)}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Text(
                        'Total Amount: ₹${widget.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: height * 0.03,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      MainButton(
                        text: 'Confirm',
                        onPressed: _createBookings,
                      ),
                    ],
                  ),
                ),
    );
  }
}