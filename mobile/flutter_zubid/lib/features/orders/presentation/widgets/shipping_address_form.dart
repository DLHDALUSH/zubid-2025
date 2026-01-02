import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/custom_text_field.dart';
import '../../data/models/order_model.dart';
import '../providers/buy_now_provider.dart';

class ShippingAddressForm extends ConsumerStatefulWidget {
  const ShippingAddressForm({super.key});

  @override
  ConsumerState<ShippingAddressForm> createState() => _ShippingAddressFormState();
}

class _ShippingAddressFormState extends ConsumerState<ShippingAddressForm> {
  final _fullNameController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _countryController.text = 'United States'; // Default country
    
    // Listen to changes and update provider
    _fullNameController.addListener(_updateAddress);
    _addressLine1Controller.addListener(_updateAddress);
    _addressLine2Controller.addListener(_updateAddress);
    _cityController.addListener(_updateAddress);
    _stateController.addListener(_updateAddress);
    _postalCodeController.addListener(_updateAddress);
    _countryController.addListener(_updateAddress);
    _phoneController.addListener(_updateAddress);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _updateAddress() {
    if (_isFormValid()) {
      final address = ShippingAddress(
        fullName: _fullNameController.text.trim(),
        addressLine1: _addressLine1Controller.text.trim(),
        addressLine2: _addressLine2Controller.text.trim().isEmpty 
            ? null 
            : _addressLine2Controller.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        country: _countryController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty 
            ? null 
            : _phoneController.text.trim(),
      );
      
      ref.read(buyNowProvider.notifier).setShippingAddress(address);
    }
  }

  bool _isFormValid() {
    return _fullNameController.text.trim().isNotEmpty &&
           _addressLine1Controller.text.trim().isNotEmpty &&
           _cityController.text.trim().isNotEmpty &&
           _stateController.text.trim().isNotEmpty &&
           _postalCodeController.text.trim().isNotEmpty &&
           _countryController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full Name
            CustomTextField(
              controller: _fullNameController,
              label: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Full name is required';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Address Line 1
            CustomTextField(
              controller: _addressLine1Controller,
              label: 'Address Line 1',
              hintText: 'Street address, P.O. box, company name',
              prefixIcon: Icons.home_outlined,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Address is required';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Address Line 2 (Optional)
            CustomTextField(
              controller: _addressLine2Controller,
              label: 'Address Line 2 (Optional)',
              hintText: 'Apartment, suite, unit, building, floor, etc.',
              prefixIcon: Icons.home_outlined,
            ),
            
            const SizedBox(height: 16),
            
            // City and State Row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    controller: _cityController,
                    label: 'City',
                    hintText: 'Enter city',
                    prefixIcon: Icons.location_city_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'City is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _stateController,
                    label: 'State',
                    hintText: 'State',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'State is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Postal Code and Country Row
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _postalCodeController,
                    label: 'Postal Code',
                    hintText: 'ZIP/Postal code',
                    prefixIcon: Icons.markunread_mailbox_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Postal code is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    controller: _countryController,
                    label: 'Country',
                    hintText: 'Select country',
                    prefixIcon: Icons.public_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Country is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Phone Number (Optional)
            CustomTextField(
              controller: _phoneController,
              label: 'Phone Number (Optional)',
              hintText: 'Enter phone number',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }
}
