import 'package:flutter/material.dart';
import 'package:qwicky/screens/Main/main_services_screen.dart';
import 'package:qwicky/widgets/carousel_slider.dart';
import 'package:qwicky/widgets/colors.dart';
import 'package:qwicky/widgets/service_item.dart';

class HomeContentPart extends StatefulWidget {
  final String address;
  final double screenWidth;
  final double screenHeight;
  final String city;

  const HomeContentPart({
    super.key,
    required this.address,
    required this.screenWidth,
    required this.screenHeight,
    required this.city,
  });

  @override
  State<HomeContentPart> createState() => _HomeContentPartState();
}

class _HomeContentPartState extends State<HomeContentPart> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Extended Services Section
        Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.screenHeight * 0.022),
          child: Text(
            'Extended Services',
            style: TextStyle(
              fontSize: widget.screenHeight * 0.03,
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
              width: widget.screenWidth / 3.5,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MainServicesScreen(
                    address: widget.address,
                    serviceType: 'Extended',
                    city: widget.city,
                  ),
                ),
              ),
            ),
            ServiceItem(
              image: 'assets/home_chef.png',
              text: 'Home Chef',
              width: widget.screenWidth / 3.5,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MainServicesScreen(
                    address: widget.address,
                    serviceType: 'Extended',
                    city: widget.city,
                  ),
                ),
              ),
            ),
            ServiceItem(
              image: 'assets/security.png',
              text: 'Security',
              width: widget.screenWidth / 3.5,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MainServicesScreen(
                    address: widget.address,
                    serviceType: 'Extended',
                    city: widget.city,
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
              width: widget.screenWidth / 3.5,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MainServicesScreen(
                    address: widget.address,
                    serviceType: 'Extended',
                    city: widget.city,
                  ),
                ),
              ),
            ),
            ServiceItem(
              image: 'assets/office_boy.png',
              text: 'Office Boy',
              width: widget.screenWidth / 3.5,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MainServicesScreen(
                    address: widget.address,
                    serviceType: 'Extended',
                    city: widget.city,
                  ),
                ),
              ),
            ),
            SizedBox(width: widget.screenWidth / 3.5), // Spacer for alignment
          ],
        ),
        SizedBox(height: 20),
        CarouselSliderMain(address: widget.address, city: widget.city,),
        SizedBox(height: widget.screenHeight * 0.02),
        // Services We Offer Section
        Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.screenHeight * 0.02),
          child: Text(
            'Services We Offer',
            style: TextStyle(
              fontSize: widget.screenHeight * 0.03,
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
              width: widget.screenWidth / 2.5,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MainServicesScreen(
                    address: widget.address,
                    serviceType: 'Domestic',
                    city: widget.city,
                  ),
                ),
              ),
            ),
            ServiceItem(
              image: 'assets/commercial_services.png',
              text: 'Commercial Services',
              width: widget.screenWidth / 2.5,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MainServicesScreen(
                    address: widget.address,
                    serviceType: 'Commercial',
                    city: widget.city,
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
          height: widget.screenHeight * 0.3,
          width: widget.screenWidth - 32,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MainServicesScreen(
                address: widget.address,
                serviceType: 'Corporate',
                city: widget.city,
              ),
            ),
          ),
          margin: EdgeInsets.symmetric(horizontal: widget.screenHeight * 0.04),
        ),
        SizedBox(height: 20),
        // Most Booked Services Section
        Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.screenHeight * 0.02),
          child: Text(
            'Most Booked Services',
            style: TextStyle(
              fontSize: widget.screenHeight * 0.03,
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
                width: widget.screenWidth / 2.5,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainServicesScreen(
                      address: widget.address,
                      serviceType: 'Domestic',
                      city: widget.city,
                    ),
                  ),
                ),
                margin: EdgeInsets.only(left: 16, right: 8),
              ),
              ServiceItem(
                image: 'assets/maid.png',
                text: 'Maid',
                width: widget.screenWidth / 2.5,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainServicesScreen(
                      address: widget.address,
                      serviceType: 'Domestic',
                      city: widget.city,
                    ),
                  ),
                ),
                margin: EdgeInsets.symmetric(horizontal: 8),
              ),
              ServiceItem(
                image: 'assets/security-1.png',
                text: 'Security',
                width: widget.screenWidth / 2.5,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainServicesScreen(
                      address: widget.address,
                      serviceType: 'Commercial',
                      city: widget.city,
                    ),
                  ),
                ),
                margin: EdgeInsets.symmetric(horizontal: 8),
              ),
              ServiceItem(
                image: 'assets/driver.png',
                text: 'Driver',
                width: widget.screenWidth / 2.5,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainServicesScreen(
                      address: widget.address,
                      city: widget.city,
                      serviceType: 'Commercial',
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
          padding: EdgeInsets.symmetric(horizontal: widget.screenHeight * 0.02),
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
            padding: EdgeInsets.all(widget.screenHeight * 0.03),
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
    );
  }
}