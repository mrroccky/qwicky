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
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

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
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
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
        context.read<CartBloc>().add(const LoadCartFromBackend([]));
      } else {
        print('Failed to clear cart: ${response.statusCode} - ${response.body}');
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
        'address_line': userData['address_line']?.toString() ?? '',
        'city': userData['city']?.toString() ?? '',
        'state': userData['state']?.toString() ?? '',
        'country': userData['country']?.toString() ?? '',
        'postal_code': userData['postal_code']?.toString() ?? '',
        'latitude': userData['latitude']?.toString() ?? '',
        'longitude': userData['longitude']?.toString() ?? '',
      };
    }

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

  Future<void> _savePaymentToBackend(int userId, int bookingId, String transactionId, String paymentStatus) async {
    final apiUrl = dotenv.env['BACK_END_API'] ?? 'http://192.168.1.37:3000';
    final payload = {
      'booking_id': bookingId, // Integer
      'payment_method': 'Razorpay',
      'transaction_id': transactionId, // String
      'amount': widget.totalAmount,
      'status': paymentStatus,
      'user_id': userId,
    };

    print('Saving payment to backend with payload: $payload');

    final response = await http.post(
      Uri.parse('$apiUrl/payment'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 201) {
      print('Payment saved successfully: ${response.body}');
    } else {
      print('Failed to save payment: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to save payment: ${response.statusCode} - ${response.body}');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
  print('Payment Success: ${response.paymentId}');

  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final userIdString = userProvider.userData?['user_id']?.toString();
  final userId = userIdString != null ? int.tryParse(userIdString) : null;

  if (userId == null) {
    setState(() {
      isLoading = false;
      errorMessage = 'User not logged in';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User not logged in')),
    );
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

      final bookingAmount = (widget.totalAmount / widget.cartItems.fold(0, (sum, item) => sum + item.value.quantity)) * quantity;

      double? latitude;
      double? longitude;
      try {
        if (addressData['latitude'].isNotEmpty) {
          latitude = double.parse(addressData['latitude']);
        }
      } catch (e) {
        latitude = null;
      }
      try {
        if (addressData['longitude'].isNotEmpty) {
          longitude = double.parse(addressData['longitude']);
        }
      } catch (e) {
        longitude = null;
      }

      final payload = {
        'service_id': serviceId,
        'user_id': userId,
        'scheduled_date': DateFormat('yyyy-MM-dd').format(dateTime),
        'scheduled_time': DateFormat('HH:mm:ss').format(dateTime),
        'booking_type': null,
        'status': 'pending',
        'payment_status': 'completed',
        'total_amount': bookingAmount,
        'address_line': addressData['address_line'],
        'city': addressData['city'],
        'state': addressData['state'],
        'country': addressData['country'],
        'postal_code': addressData['postal_code'],
        'latitude': latitude,
        'longitude': longitude,
        'created_at': DateTime.now().toUtc().toIso8601String().replaceAll('T', ' ').substring(0, 19),
        // Remove professional_id from payload
      };

      print('Creating booking with payload: $payload');

      final bookingResponse = await http.post(
        Uri.parse('$apiUrl/bookings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (bookingResponse.statusCode == 201) {
        final data = jsonDecode(bookingResponse.body);
        final bookingId = int.parse(data['booking_id'].toString());
        bookingsCreated.add(bookingId);
        print('Booking created successfully: $bookingId');

        await _savePaymentToBackend(
          userId,
          bookingId,
          response.paymentId!,
          'Completed',
        );
      } else {
        print('Booking creation failed for service ID $serviceId: ${bookingResponse.statusCode} - ${bookingResponse.body}');
        throw Exception('Failed to create booking: ${bookingResponse.statusCode} - ${bookingResponse.body}');
      }
    }

    await _clearCart(userId);

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment and bookings created successfully!')),
    );

    final userAddress = addressData['address_line'].isNotEmpty
        ? addressData['address_line']
        : 'Address not available';
    final userCity = addressData['city'].isNotEmpty ? addressData['city'] : 'City not available';
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => HomeScreen(address: userAddress, city: userCity),
      ),
      (route) => false,
    );
  } catch (e, stackTrace) {
    print('Error creating bookings after payment: $e');
    print('Stack trace: $stackTrace');
    setState(() {
      isLoading = false;
      errorMessage = 'Error creating bookings: $e';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );

    // Rollback successful bookings
    for (var bookingId in bookingsCreated) {
      try {
        await http.delete(Uri.parse('$apiUrl/bookings/$bookingId'));
        print('Rolled back booking ID: $bookingId');
      } catch (rollbackError) {
        print('Error rolling back booking ID $bookingId: $rollbackError');
      }
    }

    // Only save failed payment if at least one booking was created
    if (bookingsCreated.isNotEmpty) {
      try {
        await _savePaymentToBackend(
          userId,
          bookingsCreated.first,
          response.paymentId!,
          'Failed',
        );
      } catch (e) {
        print('Error saving failed payment: $e');
      }
    } else {
      print('No bookings created, skipping payment save');
    }
  }
}

  void _handlePaymentError(PaymentFailureResponse response) async {
    final errorMessageText = response.error?['description'] ?? 'Unknown error';
    print('Payment Error: ${response.code} - $errorMessageText');
    print('Full error response: ${response.error}');
    setState(() {
      isLoading = false;
      errorMessage = 'Payment failed: $errorMessageText';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: $errorMessageText')),
    );

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userIdString = userProvider.userData?['user_id']?.toString();
    final userId = userIdString != null ? int.tryParse(userIdString) : null;

    if (userId != null) {
      try {
        await _savePaymentToBackend(
          userId,
          0, // Fallback booking_id for failed payment
          'error-${response.code}', // String
          'Failed',
        );
      } catch (e) {
        print('Error saving failed payment: $e');
      }
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
  }

 Future<void> _createBookings() async {
  setState(() {
    isLoading = true;
    errorMessage = null;
  });

  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final userIdString = userProvider.userData?['user_id']?.toString();
  final userId = userIdString != null ? int.tryParse(userIdString) : null;

  if (userId == null) {
    setState(() {
      isLoading = false;
      errorMessage = 'User not logged in';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User not logged in')),
    );
    return;
  }

  // Validate amount
  if (widget.totalAmount < 1.0) {
    setState(() {
      isLoading = false;
      errorMessage = 'Amount must be at least ₹1.00';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Amount must be at least ₹1.00')),
    );
    return;
  }

  final userData = userProvider.userData;
  final razorpayKey = dotenv.env['RAZORPAY_KEY_ID'];
  if (razorpayKey == null || razorpayKey.isEmpty) {
    setState(() {
      isLoading = false;
      errorMessage = 'Razorpay key not configured';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment configuration error')),
    );
    return;
  }

  final options = {
    'key': razorpayKey,
    'amount': (widget.totalAmount * 100).toInt(),
    'name': 'Qwicky',
    'description': 'Payment for booking services',
    'currency': 'INR',
    'prefill': {
      'contact': _validatePhoneNumber(userData?['phone_number']?.toString() ?? ''),
      'email': _validateEmail(userData?['email']?.toString() ?? ''),
    },
    'theme': {'color': '#3399cc'},
    'external': {'wallets': ['paytm']},
    'retry': {'enabled': true, 'max_count': 3},
    'timeout': 300,
  };

  try {
    _razorpay.open(options);
  } catch (e, stackTrace) {
    print('Error initiating payment: $e');
    print('Stack trace: $stackTrace');
    setState(() {
      isLoading = false;
      errorMessage = 'Error initiating payment: $e';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error initiating payment: $e')),
    );
  }
}
  String _validatePhoneNumber(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.length == 10) {
      return cleanPhone;
    } else if (cleanPhone.length == 12 && cleanPhone.startsWith('91')) {
      return cleanPhone.substring(2);
    } else if (cleanPhone.length == 13 && cleanPhone.startsWith('+91')) {
      return cleanPhone.substring(3);
    }
    return '9876543210';
  }

  String _validateEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (emailRegex.hasMatch(email)) {
      return email;
    }
    return 'user@example.com';
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
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            errorMessage = null;
                          });
                        },
                        child: const Text('Try Again'),
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