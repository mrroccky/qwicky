import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:qwicky/provider/user_provider.dart';
import 'package:qwicky/widgets/colors.dart';
import 'package:qwicky/widgets/main_button.dart';
import 'package:qwicky/widgets/field_boxes.dart';

class ProfileFormWidget extends StatefulWidget {
  final String address;
  final bool isModal; // To determine if shown as modal or full screen
  final VoidCallback? onSave; // Callback for modal save action

  const ProfileFormWidget({
    super.key,
    required this.address,
    this.isModal = false,
    this.onSave,
  });

  @override
  State<ProfileFormWidget> createState() => _ProfileFormWidgetState();
}

class _ProfileFormWidgetState extends State<ProfileFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _referralController = TextEditingController();
  String? _gender;
  DateTime? _dob;
  File? _profileImage;
  bool _obscurePassword = true;
  String? _selectedState;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _indianStates = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
    'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana',
    'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal', 'Andaman and Nicobar Islands',
    'Chandigarh', 'Dadra and Nagar Haveli and Daman and Diu', 'Delhi', 'Jammu and Kashmir',
    'Ladakh', 'Lakshadweep', 'Puducherry'
  ];

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.address;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dob) {
      setState(() {
        _dob = picked;
      });
    }
  }

  bool _validateForm() {
    if (_formKey.currentState!.validate()) {
      if (_gender == null || _dob == null || _selectedState == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields')),
        );
        return false;
      }
      return true;
    }
    return false;
  }

  Future<void> _saveProfile(UserProvider userProvider) async {
    if (!_validateForm()) {
      return;
    }

    try {
      final String apiUrl = dotenv.env['BACK_END_API'] ?? 'http://192.168.1.37:3000/api';

      String? profileImageBase64;
      if (_profileImage != null) {
        if (!await _profileImage!.exists()) {
          throw Exception('Profile image file does not exist');
        }

        final bytes = await _profileImage!.readAsBytes();
        if (bytes.isEmpty) {
          throw Exception('Profile image data is empty');
        }

        profileImageBase64 = base64Encode(bytes);
        print('Profile image Base64 length: ${profileImageBase64.length}');
        print('Profile image Base64 preview: ${profileImageBase64.substring(0, 100)}...');
      }

      Map<String, dynamic> existingUserData = userProvider.userData ?? {};

      final Map<String, dynamic> userData = {
        'first_name': _firstNameController.text.isNotEmpty ? _firstNameController.text : existingUserData['first_name'] ?? '',
        'last_name': _lastNameController.text.isNotEmpty ? _lastNameController.text : existingUserData['last_name'] ?? '',
        'email': _emailController.text.isNotEmpty ? _emailController.text : existingUserData['email'] ?? '',
        'phone_number': _phoneController.text.isNotEmpty ? _phoneController.text : existingUserData['phone_number'] ?? userProvider.lastVerifiedPhoneNumber ?? '',
        'password': _passwordController.text.isNotEmpty ? _passwordController.text : null,
        'profile_image_url': profileImageBase64 ?? existingUserData['profile_image_url'] ?? '',
        'gender': _gender ?? existingUserData['gender'] ?? '',
        'date_of_birth': _dob?.toIso8601String() ?? existingUserData['date_of_birth'] ?? '',
        'address_line': _addressController.text.isNotEmpty ? _addressController.text : existingUserData['address_line'] ?? '',
        'city': _cityController.text.isNotEmpty ? _cityController.text : existingUserData['city'] ?? '',
        'state': _selectedState ?? existingUserData['state'] ?? '',
        'country': _countryController.text.isNotEmpty ? _countryController.text : existingUserData['country'] ?? '',
        'postal_code': _postalCodeController.text.isNotEmpty ? _postalCodeController.text : existingUserData['postal_code'] ?? '',
        'is_email_verified': existingUserData['is_email_verified'] ?? false,
        'is_phone_number_verified': existingUserData['is_phone_number_verified'] ?? true,
        'created_at': existingUserData['created_at'] ?? null,
        'last_login_at': existingUserData['last_login_at'] ?? null,
        'account_status': existingUserData['account_status'] ?? 'active',
        'preferred_language': existingUserData['preferred_language'] ?? 'en',
        'is_premium_user': existingUserData['is_premium_user'] ?? false,
        'referral_code': _referralController.text.isNotEmpty ? _referralController.text : existingUserData['referral_code'] ?? null,
        'referred_by': existingUserData['referred_by'] ?? null,
      };

      http.Response response;
      if (userProvider.userData != null) {
        final userId = userProvider.userData!['user_id'];
        if (userId == null) {
          throw Exception('User ID not found');
        }

        print('Updating user with ID: $userId with data: $userData');
        response = await http.put(
          Uri.parse('$apiUrl/users/$userId'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(userData),
        );
      } else {
        print('Creating new user with data: $userData');
        response = await http.post(
          Uri.parse('$apiUrl/users'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(userData),
        );
      }

      print('API Response status: ${response.statusCode}');
      print('API Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> updatedUserData = {...userData};
        if (userProvider.userData != null) {
          updatedUserData['user_id'] = userProvider.userData!['user_id'];
        } else {
          final responseData = json.decode(response.body);
          updatedUserData['user_id'] = responseData['user_id'].toString();
        }

        userProvider.setUserData(updatedUserData);
        userProvider.setEditing(false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userProvider.userData != null
                ? 'Profile updated successfully!'
                : 'Profile created successfully!'),
          ),
        );

        // Handle navigation based on context
        if (widget.isModal) {
          // If shown as a modal (e.g., in "Add to Cart" flow), call the onSave callback
          widget.onSave?.call();
        }
        // Remove the else block with Navigator.pop()
        // When isModal = false (e.g., in ProfileScreen via navbar), do nothing here
        // The form will automatically toggle back to non-editable mode because we called userProvider.setEditing(false)
      } else {
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final bool userExists = userProvider.userData != null;
        final bool isEditing = userExists ? userProvider.isEditing : true;

        if (userExists) {
          if (_firstNameController.text.isEmpty) {
            _firstNameController.text = userProvider.userData!['first_name']?.trim() ?? '';
          }
          if (_lastNameController.text.isEmpty) {
            _lastNameController.text = userProvider.userData!['last_name']?.trim() ?? '';
          }
          if (_emailController.text.isEmpty) {
            _emailController.text = userProvider.userData!['email'] ?? '';
          }
          if (_addressController.text.isEmpty) {
            _addressController.text = userProvider.userData!['address_line'] ?? widget.address;
          }
          if (_cityController.text.isEmpty) {
            _cityController.text = userProvider.userData!['city'] ?? '';
          }
          if (_countryController.text.isEmpty) {
            _countryController.text = userProvider.userData!['country'] ?? '';
          }
          if (_postalCodeController.text.isEmpty) {
            _postalCodeController.text = userProvider.userData!['postal_code'] ?? '';
          }
          if (_referralController.text.isEmpty) {
            _referralController.text = userProvider.userData!['referral_code'] ?? '';
          }
          if (_gender == null) {
            _gender = userProvider.userData!['gender'];
          }
          if (_selectedState == null) {
            _selectedState = userProvider.userData!['state'];
          }
          if (_dob == null && userProvider.userData!['date_of_birth'] != null) {
            _dob = DateTime.tryParse(userProvider.userData!['date_of_birth']);
          }
        }

        if (_phoneController.text.isEmpty && userProvider.lastVerifiedPhoneNumber != null) {
          _phoneController.text = userProvider.lastVerifiedPhoneNumber!;
        }

        Widget profileImageWidget;
        if (_profileImage != null) {
          profileImageWidget = CircleAvatar(
            radius: 50,
            backgroundImage: FileImage(_profileImage!),
          );
        } else if (userProvider.userData?['profile_image_url'] != null &&
                   userProvider.userData!['profile_image_url'].isNotEmpty) {
          try {
            String base64String = userProvider.userData!['profile_image_url'];
            base64String = base64String.trim().replaceAll(RegExp(r'\s+'), '');
            if (base64String.contains(',')) {
              base64String = base64String.split(',')[1];
            }
            if (!RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(base64String)) {
              throw Exception('Invalid Base64 string format');
            }
            int padding = base64String.length % 4;
            if (padding != 0) {
              base64String += '=' * (4 - padding);
            }
            print('Processing Base64 string of length: ${base64String.length}');
            Uint8List imageBytes = base64Decode(base64String);
            if (imageBytes.isEmpty) {
              throw Exception('Decoded image data is empty');
            }
            profileImageWidget = CircleAvatar(
              radius: 50,
              backgroundImage: MemoryImage(imageBytes),
            );
          } catch (e) {
            print('Error processing profile image: $e');
            profileImageWidget = CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 40, color: Colors.black),
              backgroundColor: AppColors.borderColor,
            );
          }
        } else {
          profileImageWidget = CircleAvatar(
            radius: 50,
            child: Icon(Icons.camera_alt, size: 40, color: Colors.black),
            backgroundColor: AppColors.borderColor,
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(height * 0.02),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: isEditing ? _pickImage : null,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.borderColor,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: ClipOval(child: profileImageWidget),
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  FieldBoxes(
                    isDoubleField: true,
                    controller1: _firstNameController,
                    controller2: _lastNameController,
                    label1: 'First Name',
                    label2: 'Last Name',
                    icon1: Icons.person,
                    icon2: Icons.person,
                    validator1: (value) => value!.isEmpty ? 'First Name is required' : null,
                    validator2: (value) => value!.isEmpty ? 'Last Name is required' : null,
                    readOnly1: !isEditing,
                    readOnly2: !isEditing,
                  ),
                  SizedBox(height: height * 0.02),
                  FieldBoxes(
                    controller1: _emailController,
                    label1: 'Email',
                    icon1: Icons.email,
                    keyboardType1: TextInputType.emailAddress,
                    validator1: (value) {
                      if (value!.isEmpty) return 'Email is required';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                    readOnly1: !isEditing,
                  ),
                  SizedBox(height: height * 0.02),
                  FieldBoxes(
                    controller1: _phoneController,
                    label1: 'Phone Number',
                    icon1: Icons.phone,
                    keyboardType1: TextInputType.phone,
                    validator1: (value) => value!.isEmpty ? 'Phone Number is required' : null,
                    readOnly1: true,
                  ),
                  SizedBox(height: height * 0.02),
                  FieldBoxes(
                    controller1: _passwordController,
                    label1: userExists ? 'New Password (optional)' : 'Password',
                    icon1: Icons.lock,
                    obscureText1: _obscurePassword,
                    suffixIcon1: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: isEditing
                          ? () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            }
                          : null,
                    ),
                    validator1: (value) => !userExists && value!.isEmpty ? 'Password is required' : null,
                    readOnly1: !isEditing,
                  ),
                  SizedBox(height: height * 0.02),
                  Row(
                    children: [
                      Expanded(
                        child: FieldBoxes(
                          label1: 'Gender',
                          icon1: Icons.person_outline,
                          isDropdown1: true,
                          dropdownItems1: _genders,
                          dropdownValue1: _gender,
                          onDropdownChanged1: isEditing
                              ? (value) {
                                  setState(() {
                                    _gender = value;
                                  });
                                }
                              : null,
                          dropdownValidator1: (value) => value == null ? 'Gender is required' : null,
                          readOnly1: !isEditing,
                        ),
                      ),
                      SizedBox(width: height * 0.02),
                      Expanded(
                        child: GestureDetector(
                          onTap: isEditing ? () => _selectDate(context) : null,
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: _dob == null
                                    ? 'Date of Birth'
                                    : '${_dob!.day}/${_dob!.month}/${_dob!.year}',
                                prefixIcon: const Icon(Icons.calendar_today, color: Colors.black),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppColors.borderColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppColors.borderColor),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              validator: (value) => _dob == null ? 'Date of Birth is required' : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.02),
                  FieldBoxes(
                    controller1: _addressController,
                    label1: 'Address',
                    icon1: Icons.location_on,
                    maxLines1: 3,
                    validator1: (value) => value!.isEmpty ? 'Address is required' : null,
                    readOnly1: !isEditing,
                  ),
                  SizedBox(height: height * 0.02),
                  FieldBoxes(
                    isDoubleField: true,
                    controller1: _cityController,
                    controller2: _countryController,
                    label1: 'City',
                    label2: 'Country',
                    icon1: Icons.location_city,
                    icon2: Icons.public,
                    validator1: (value) => value!.isEmpty ? 'City is required' : null,
                    validator2: (value) => value!.isEmpty ? 'Country is required' : null,
                    readOnly1: !isEditing,
                    readOnly2: !isEditing,
                  ),
                  SizedBox(height: height * 0.02),
                  FieldBoxes(
                    isDoubleField: true,
                    label1: 'State',
                    icon1: Icons.map,
                    isDropdown1: true,
                    dropdownItems1: _indianStates,
                    dropdownValue1: _selectedState,
                    onDropdownChanged1: isEditing
                        ? (value) {
                            setState(() {
                              _selectedState = value;
                            });
                          }
                        : null,
                    dropdownValidator1: (value) => value == null ? 'State is required' : null,
                    controller2: _postalCodeController,
                    label2: 'Postal Code',
                    icon2: Icons.local_post_office,
                    keyboardType2: TextInputType.number,
                    validator2: (value) => value!.isEmpty ? 'Postal Code is required' : null,
                    readOnly1: !isEditing,
                    readOnly2: !isEditing,
                  ),
                  SizedBox(height: height * 0.02),
                  FieldBoxes(
                    controller1: _referralController,
                    label1: 'Referral (optional)',
                    icon1: Icons.card_giftcard,
                    readOnly1: !isEditing,
                  ),
                  SizedBox(height: height * 0.03),
                  MainButton(
                    text: userExists && !isEditing ? 'Edit' : 'Save',
                    onPressed: userExists && !isEditing
                        ? () {
                            userProvider.setEditing(true);
                          }
                        : () => _saveProfile(userProvider),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}