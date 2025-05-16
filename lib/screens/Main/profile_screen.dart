import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:qwicky/widgets/colors.dart';
import 'package:qwicky/widgets/main_button.dart';
import 'package:qwicky/widgets/field_boxes.dart';

class ProfileScreen extends StatefulWidget {
  final String address;

  const ProfileScreen({super.key, required this.address});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
  String? _selectedState;

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
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dob) {
      setState(() {
        _dob = picked;
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      if (_gender == null || _dob == null || _selectedState == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields')),
        );
        return;
      }
      // Save profile logic (e.g., API call or local storage)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(height * 0.02),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Image
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.borderColor,
                      border: Border.all(color: Colors.black, width: 2),
                      image: _profileImage != null
                          ? DecorationImage(
                              image: FileImage(_profileImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _profileImage == null
                        ? const Icon(Icons.camera_alt, color: Colors.black, size: 40)
                        : null,
                  ),
                ),
                SizedBox(height: height * 0.03),

                // First Name and Last Name
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
                ),
                SizedBox(height: height * 0.02),

                // Email
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
                ),
                SizedBox(height: height * 0.02),

                // Phone Number
                FieldBoxes(
                  controller1: _phoneController,
                  label1: 'Phone Number',
                  icon1: Icons.phone,
                  keyboardType1: TextInputType.phone,
                  validator1: (value) => value!.isEmpty ? 'Phone Number is required' : null,
                ),
                SizedBox(height: height * 0.02),

                // Password
                FieldBoxes(
                  controller1: _passwordController,
                  label1: 'Password',
                  icon1: Icons.lock,
                  obscureText1: _obscurePassword,
                  suffixIcon1: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator1: (value) => value!.isEmpty ? 'Password is required' : null,
                ),
                SizedBox(height: height * 0.02),

                // Gender and Date of Birth
                Row(
                  children: [
                    Expanded(
                      child: FieldBoxes(
                        label1: 'Gender',
                        icon1: Icons.person_outline,
                        isDropdown1: true,
                        dropdownItems1: _genders,
                        dropdownValue1: _gender,
                        onDropdownChanged1: (value) {
                          setState(() {
                            _gender = value;
                          });
                        },
                        dropdownValidator1: (value) => value == null ? 'Gender is required' : null,
                      ),
                    ),
                    SizedBox(width: height * 0.02),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context),
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

                // Address
                FieldBoxes(
                  controller1: _addressController,
                  label1: 'Address',
                  icon1: Icons.location_on,
                  maxLines1: 3,
                  validator1: (value) => value!.isEmpty ? 'Address is required' : null,
                ),
                SizedBox(height: height * 0.02),

                // City and Country
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
                ),
                SizedBox(height: height * 0.02),

                // State and Postal Code
                FieldBoxes(
                  isDoubleField: true,
                  label1: 'State',
                  icon1: Icons.map,
                  isDropdown1: true,
                  dropdownItems1: _indianStates,
                  dropdownValue1: _selectedState,
                  onDropdownChanged1: (value) {
                    setState(() {
                      _selectedState = value;
                    });
                  },
                  dropdownValidator1: (value) => value == null ? 'State is required' : null,
                  controller2: _postalCodeController,
                  label2: 'Postal Code',
                  icon2: Icons.local_post_office,
                  keyboardType2: TextInputType.number,
                  validator2: (value) => value!.isEmpty ? 'Postal Code is required' : null,
                ),
                SizedBox(height: height * 0.02),

                // Referral
                FieldBoxes(
                  controller1: _referralController,
                  label1: 'Referral (optional)',
                  icon1: Icons.card_giftcard,
                ),
                SizedBox(height: height * 0.03),

                // Save Button
                MainButton(
                  text: 'Save',
                  onPressed: _saveProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}