import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:qwicky/provider/user_provider.dart';
import 'package:qwicky/screens/Main/bloc/cart_block_part/cart_bloc.dart';
import 'package:qwicky/screens/Main/payment_screen.dart';
import 'package:qwicky/widgets/profile_form.dart';
import 'package:qwicky/widgets/cart_card.dart';
import 'package:qwicky/widgets/cart_item.dart';
import 'package:qwicky/widgets/colors.dart';
import 'package:qwicky/widgets/datetime_picker.dart';
import 'package:qwicky/widgets/main_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _showProfileForm = false;
  List<MapEntry<String, CartItem>>? _pendingCartItems;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userData?['user_id']?.toString();

    if (userId == null || userId.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID not found. Please log in again.')),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).primaryColor,
            size: width * 0.08,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: height * 0.03),
                  child: Row(
                    children: [
                      Image.asset('assets/Cart.png', width: width * 0.08, height: height * 0.08),
                      SizedBox(width: width * 0.02),
                      Text(
                        'Your Cart',
                        style: TextStyle(fontSize: height * 0.034, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                BlocBuilder<CartBloc, CartState>(
                  builder: (context, state) {
                    if (state is CartError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              'assets/empty_cart.json',
                              width: width * 0.5,
                              height: height * 0.4,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                state.message,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondTextColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    if (state is CartInitial || (state is CartLoaded && state.items.isEmpty)) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              'assets/empty_cart.json',
                              width: width * 0.5,
                              height: height * 0.4,
                            ),
                            Text(
                              'Please add services to see',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondTextColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    final cartItems = (state as CartLoaded).items;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cartItems[index];
                            return CartItemCard(
                              cartItem: item.value,
                              uniqueKey: item.key,
                              onRemove: () {
                                if (userId != null && userId.isNotEmpty) {
                                  context.read<CartBloc>().add(RemoveServiceFromCart(item.key, userId));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('User ID not found. Please log in again.')),
                                  );
                                }
                              },
                            );
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: height * 0.03),
                          child: Text(
                            "Cancellation Policy",
                            style: TextStyle(fontSize: height * 0.03, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: height * 0.02),
                        Padding(
                          padding: EdgeInsets.only(left: height * 0.03, right: height * 0.03),
                          child: Text(
                            "Cancellations made at least one day before the booked date are free. A fee applies for cancellations made later.",
                            style: TextStyle(fontSize: height * 0.02),
                          ),
                        ),
                        SizedBox(height: height * 0.02),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: height * 0.03, vertical: height * 0.02),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DashedDivider(color: AppColors.borderColor),
                              SizedBox(height: height * 0.01),
                              Text(
                                "Total Amount",
                                style: TextStyle(fontSize: height * 0.03, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: height * 0.015),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Total Items",
                                        style: TextStyle(fontSize: height * 0.02),
                                      ),
                                      Text(
                                        cartItems.fold(0, (sum, item) => sum + item.value.quantity).toString(),
                                        style: TextStyle(fontSize: height * 0.02),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: height * 0.01),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Total Cost",
                                        style: TextStyle(fontSize: height * 0.02),
                                      ),
                                      Text(
                                        "₹${cartItems.fold(0.0, (sum, item) => sum + (item.value.service.price! * item.value.quantity)).toStringAsFixed(2)}",
                                        style: TextStyle(fontSize: height * 0.02),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: height * 0.01),
                              DashedDivider(color: AppColors.borderColor),
                            ],
                          ),
                        ),
                        SizedBox(height: height * 0.02),
                        MainButton(
                          text: "Checkout",
                          onPressed: () {
                            if (cartItems.isNotEmpty) {
                              _checkProfileAndProceed(context, cartItems);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Cart is empty')),
                              );
                            }
                          },
                        ),
                        SizedBox(height: height * 0.02),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          if (_showProfileForm)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ProfileFormWidget(
                    address: '',
                    isModal: true,
                    onSave: () {
                      setState(() {
                        _showProfileForm = false;
                      });
                      if (_pendingCartItems != null) {
                        _showDateTimePicker(context, _pendingCartItems!);
                        _pendingCartItems = null;
                      }
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _checkProfileAndProceed(BuildContext context, List<MapEntry<String, CartItem>> cartItems) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userData = userProvider.userData;

    if (userData == null ||
        userData['first_name']?.toString().trim().isEmpty == true ||
        userData['last_name']?.toString().trim().isEmpty == true ||
        userData['address_line']?.toString().trim().isEmpty == true ||
        userData['phone_number']?.toString().trim().isEmpty == true) {
      print('Profile incomplete, showing profile form overlay');
      setState(() {
        _showProfileForm = true;
        _pendingCartItems = cartItems;
      });
    } else {
      print('Profile complete, proceeding to date-time picker');
      _showDateTimePicker(context, cartItems);
    }
  }

  void _showDateTimePicker(BuildContext context, List<MapEntry<String, CartItem>> cartItems) {
    final scaffoldContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return DateTimePickerWidget<MapEntry<String, CartItem>>(
          items: cartItems,
          itemNameGetter: (item) => item.value.service.title,
          onConfirm: (List<DateTime?> selectedDateTimes) {
            try {
              if (selectedDateTimes.any((dt) => dt == null)) {
                ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                  const SnackBar(content: Text('Please select a date and time for all items')),
                );
                return;
              }

              double totalAmount = cartItems.fold(
                  0.0, (sum, item) => sum + (item.value.service.price! * item.value.quantity));

              print('Checkout Details:');
              for (int i = 0; i < cartItems.length; i++) {
                final cartItem = cartItems[i].value;
                print('Service ID: ${cartItem.service.serviceId}');
                print('Service Name: ${cartItem.service.title}');
                print('Quantity: ${cartItem.quantity}');
                print('Unique Key: ${cartItems[i].key}');
                print('Date and Time: ${DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTimes[i]!)}');
              }
              print('Total Amount: ₹${totalAmount.toStringAsFixed(2)}');

              Navigator.of(dialogContext).pop();

              Navigator.of(scaffoldContext).push(
                MaterialPageRoute(
                  builder: (context) => PaymentScreen(
                    cartItems: cartItems,
                    selectedDateTimes: selectedDateTimes.cast<DateTime>(),
                    totalAmount: totalAmount,
                  ),
                ),
              );
            } catch (e) {
              print('Error in onConfirm: $e');
              ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                SnackBar(content: Text('Error during checkout: $e')),
              );
            }
          },
        );
      },
    );
  }
}

class DashedDivider extends StatelessWidget {
  final Color color;
  final double height;
  final double dashWidth;
  final double dashGap;

  const DashedDivider({
    super.key,
    this.color = Colors.grey,
    this.height = 1.0,
    this.dashWidth = 4.0,
    this.dashGap = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashCount = (boxWidth / (dashWidth + dashGap)).floor();
        return Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}