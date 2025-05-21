import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qwicky/screens/Main/bloc/cart_block_part/cart_bloc.dart';
import 'package:qwicky/screens/Main/cart_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String address;
  final bool isBackButtonVisible;
  const CustomAppBar({super.key, required this.address, this.isBackButtonVisible = false});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false, // Disable default back arrow
      leading: isBackButtonVisible
    ? IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Theme.of(context).primaryColor,
          size: width * 0.08,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      )
    : null,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          isBackButtonVisible
              ? const SizedBox()
              : Container(
                  width: MediaQuery.of(context).size.width * 0.45, // 45% from left to center
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          address.isEmpty ? 'Select Location' : address,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              int itemCount = 0;
              if (state is CartLoaded) {
                itemCount = state.items.fold(0, (sum, item) => sum + item.value);
              }
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartScreen(),
                    ),
                  );
                },
                child: badges.Badge(
                  badgeContent: Text(
                    itemCount.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  showBadge: itemCount > 0,
                  badgeStyle: badges.BadgeStyle(
                    badgeColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.all(6),
                  ),
                  child: Image.asset(
                    'assets/Cart.png',
                    width: 35,
                    height: 35,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}