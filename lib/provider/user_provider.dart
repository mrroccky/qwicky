import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserProvider with ChangeNotifier {
  Map<String, dynamic>? _userData;
  bool _isEditing = false;
  String? _lastVerifiedPhoneNumber;

  Map<String, dynamic>? get userData => _userData;
  bool get isEditing => _isEditing;
  String? get lastVerifiedPhoneNumber => _lastVerifiedPhoneNumber;

  void setUserData(Map<String, dynamic>? data) {
    _userData = data;
    notifyListeners();
  }

  void setEditing(bool value) {
    _isEditing = value;
    notifyListeners();
  }

  Future<void> checkUserByPhone(String phoneNumber) async {
  try {
    // Store the verified phone number
    _lastVerifiedPhoneNumber = phoneNumber.trim().replaceAll(RegExp(r'\s+'), '');
    
    print('Checking user with phone number: $_lastVerifiedPhoneNumber');
    final String apiUrl = dotenv.env['BACK_END_API'] ?? 'http://192.168.1.37:3000/api';
    
    final response = await http.post(
      Uri.parse('$apiUrl/check-phone'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone_number': _lastVerifiedPhoneNumber}),
    );

    print('Check user response status: ${response.statusCode}');
    print('Check user response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['exists'] == true && data['user'] != null) {
        _userData = Map<String, dynamic>.from(data['user']);
        print('User exists, userData set: $_userData');
      } else {
        _userData = null;
        print('User does not exist');
      }
      notifyListeners();
    } else {
      print('Failed to check user by phone: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to check user by phone: ${response.statusCode}');
    }
  } catch (e) {
    print('Error checking user by phone: $e');
    notifyListeners();
  }
}
  
  // Add a method to get user data by phone number - can be used to refresh data
  Future<void> fetchUserByPhone(String phoneNumber) async {
    try {
      if (phoneNumber.isEmpty) {
        print('Cannot fetch user: phone number is empty');
        return;
      }
      
      final String apiUrl = dotenv.env['BACK_END_API'] ?? 'http://192.168.1.37:3000/api';
      final String formattedPhone = phoneNumber.trim().replaceAll(RegExp(r'\s+'), '');
      
      print('Fetching user data for phone: $formattedPhone');
      final response = await http.get(
        Uri.parse('$apiUrl/users/phone/$formattedPhone'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _userData = data;
        print('User data fetched successfully: $_userData');
        notifyListeners();
      } else {
        print('Failed to fetch user data: ${response.statusCode} - ${response.body}');
        if (response.statusCode == 404) {
          // User not found, but don't clear existing data
          print('User not found in database');
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }
}