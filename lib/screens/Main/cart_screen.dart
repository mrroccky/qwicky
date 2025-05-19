import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:qwicky/screens/Main/bloc/cart_block_part/cart_bloc.dart';
import 'package:qwicky/widgets/cart_card.dart';
import 'package:qwicky/widgets/colors.dart';
import 'package:qwicky/widgets/main_button.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Image.asset(
            'assets/back_arrow.png', // Custom back button image
            width: width * 0.13,
            height: height * 0.13,
          ),
          onPressed: () {
            Navigator.pop(context); // Go back to previous screen
          },
        ),
      ),
      body: SingleChildScrollView(
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
                // Empty cart UI
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
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.secondTextColor),
                        ),
                      ],
                    ),
                  );
                }
                // Cart with items
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.builder(
                      shrinkWrap: true, // Take only needed height
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: (state as CartLoaded).items.length,
                      itemBuilder: (context, index) {
                        final item = (state).items[index];
                        return CartItemCard(
                          service: item.key,
                          quantity: item.value,
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
                    // Total Amount Section
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
                                    (state).items.fold(0, (sum, item) => sum + item.value).toString(),
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
                                    "₹${(state).items.fold(0.0, (sum, item) => sum + item.key.price! * item.value).toStringAsFixed(2)}",
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
                    MainButton(text: "Checkout", onPressed: () {}),
                    SizedBox(height: height * 0.02),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Dashed Divider Widget
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