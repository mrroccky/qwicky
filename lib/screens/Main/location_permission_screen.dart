// ignore_for_file: avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'package:qwicky/screens/Main/home_screen.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> with SingleTickerProviderStateMixin {
  String _status = 'Fetching your location.';
  String? _address;
  late AnimationController _dotsController;

  // LocationIQ API key
  final String? _locationIqApiKey = dotenv.env['LOCATION_API_KEY'];

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  print("Location service enabled: $serviceEnabled");

  if (!serviceEnabled) {
    // Show dialog to enable location
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Enable Location Services'),
        content: const Text('Location services are disabled. Please enable them to continue.'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await Geolocator.openLocationSettings();

              // Wait and check again after coming back from settings
              Future.delayed(const Duration(seconds: 2), () async {
                bool serviceEnabledAfter = await Geolocator.isLocationServiceEnabled();
                print("Service enabled after returning from settings: $serviceEnabledAfter");

                if (serviceEnabledAfter) {
                  // Proceed to permission check
                  _requestLocationPermission();
                } else {
                  // Still disabled, show the dialog again
                  _requestLocationPermission();
                }
              });
            },
            child: const Text('Enable'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    return;
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    print("Requested permission status: $permission");
    if (permission == LocationPermission.denied) {
      _showPermissionDialog('Location permission is required to proceed.');
      return;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    print("Permission permanently denied");
    _showPermissionDialog(
      'Location permissions are permanently denied. Please enable them in settings.',
      openSettings: true,
    );
    return;
  }

  // Permission granted, fetch location
  print("Permission granted. Fetching location...");
  _fetchLocation();
}



  Future<void> _fetchLocation() async {
    try {
      print("Calling Geolocator.getCurrentPosition...");
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print("Position received: ${position.latitude}, ${position.longitude}");

      double lat = position.latitude;
      double lon = position.longitude;

      // LocationIQ reverse geocoding API
      final url = 'https://api.locationiq.com/v1/reverse?key=$_locationIqApiKey&lat=$lat&lon=$lon&format=json';

      final response = await http.get(
        Uri.parse(url),
      );
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Construct address from components
        final addressComponents = data['address'] ?? {};
        List addressParts = [
          addressComponents['house_number'] ?? '',
          addressComponents['road'] ?? '',
          addressComponents['neighbourhood'] ?? '',
          addressComponents['suburb'] ?? '',
          addressComponents['city'] ?? addressComponents['town'] ?? addressComponents['village'] ?? '',
          addressComponents['state'] ?? '',
          addressComponents['postcode'] ?? '',
          addressComponents['country'] ?? '',
        ].where((part) => part.isNotEmpty).toList();

        String address = addressParts.join(', ');
        if (address.isEmpty) {
          address = 'Unknown address';
        }
        print("Fetched address: $address");

        setState(() {
          _address = address;
          _status = address;
        });

        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>HomeScreen(address: address,),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        }
      } else {
        print("Failed to fetch address from API: ${response.statusCode}");
        setState(() {
          _status = 'Failed to fetch address';
        });
      }
    } catch (e) {
      print("Error fetching location: $e");
      setState(() {
        _status = 'Error: $e';
      });
      _showPermissionDialog('Failed to fetch location. Please try again.');
    }
  }

  void _showPermissionDialog(String message, {bool openSettings = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (openSettings) {
                Geolocator.openAppSettings();
              } else {
                _requestLocationPermission();
              }
            },
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/locationpin.json',
              width: height * 0.4,
              height: height * 0.4,
              fit: BoxFit.contain,
            ),
            SizedBox(height: height * 0.03),
            AnimatedBuilder(
              animation: _dotsController,
              builder: (context, child) {
                int dots = (_dotsController.value * 4).floor() % 4;
                return Text(
                  _address == null ? '$_status${'.' * dots}' : _status,
                  style: TextStyle(
                    fontSize: height * 0.025,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}