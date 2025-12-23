import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/payment_methods_provider.dart';
import '../../data/models/payment_request_model.dart';

class AddPaymentMethodScreen extends ConsumerStatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  ConsumerState<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends ConsumerState<AddPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'fib'; // Default to FIB
  bool _setAsDefault = false;
  
  // FIB fields
  final _fibAccountController = TextEditingController();
  final _fibHolderNameController = TextEditingController();
  final _fibPhoneController = TextEditingController();
  final _fibBranchController = TextEditingController();
  final _fibIbanController = TextEditingController();
  
  // ZAIN CASH fields
  final _zainPhoneController = TextEditingController();
  final _zainPinController = TextEditingController();
  final _zainHolderNameController = TextEditingController();
  
  // VISA/MASTERCARD fields
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _cardExpMonthController = TextEditingController();
  final _cardExpYearController = TextEditingController();
  final _cardCvcController = TextEditingController();

  @override
  void dispose() {
    _fibAccountController.dispose();
    _fibHolderNameController.dispose();
    _fibPhoneController.dispose();
    _fibBranchController.dispose();
    _fibIbanController.dispose();
    _zainPhoneController.dispose();
    _zainPinController.dispose();
    _zainHolderNameController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _cardExpMonthController.dispose();
    _cardExpYearController.dispose();
    _cardCvcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paymentMethodsState = ref.watch(paymentMethodsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Payment Method'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment method type selector
              Text(
                'Select Payment Method',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildPaymentTypeSelector(),
              
              const SizedBox(height: 24),
              
              // Payment method form
              _buildPaymentMethodForm(),
              
              const SizedBox(height: 24),
              
              // Set as default checkbox
              CheckboxListTile(
                title: const Text('Set as default payment method'),
                value: _setAsDefault,
                onChanged: (value) {
                  setState(() {
                    _setAsDefault = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              
              const SizedBox(height: 32),
              
              // Add button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: paymentMethodsState.isLoading ? null : _addPaymentMethod,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: paymentMethodsState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Add Payment Method',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentTypeSelector() {
    final paymentTypes = [
      {'value': 'fib', 'label': 'FIB (First Iraqi Bank)', 'icon': '🏛️'},
      {'value': 'zain_cash', 'label': 'ZAIN CASH', 'icon': '📱'},
      {'value': 'visa', 'label': 'VISA Card', 'icon': '💳'},
      {'value': 'mastercard', 'label': 'MASTERCARD', 'icon': '💳'},
    ];

    return Column(
      children: paymentTypes.map((type) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: RadioListTile<String>(
            title: Row(
              children: [
                Text(
                  type['icon']!,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  type['label']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            value: type['value']!,
            groupValue: _selectedType,
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentMethodForm() {
    switch (_selectedType) {
      case 'fib':
        return _buildFibForm();
      case 'zain_cash':
        return _buildZainCashForm();
      case 'visa':
      case 'mastercard':
        return _buildCardForm();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFibForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FIB Account Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _fibAccountController,
          decoration: const InputDecoration(
            labelText: 'Account Number',
            hintText: 'Enter your FIB account number',
            prefixIcon: Icon(Icons.account_balance),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your account number';
            }
            if (value.length < 10) {
              return 'Account number must be at least 10 digits';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _fibHolderNameController,
          decoration: const InputDecoration(
            labelText: 'Account Holder Name',
            hintText: 'Enter the name on the account',
            prefixIcon: Icon(Icons.person),
          ),
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the account holder name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _fibPhoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            hintText: 'Enter your phone number for verification',
            prefixIcon: Icon(Icons.phone),
            prefixText: '+964 ',
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            if (value.length < 10) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _fibBranchController,
          decoration: const InputDecoration(
            labelText: 'Branch Code (Optional)',
            hintText: 'Enter branch code if known',
            prefixIcon: Icon(Icons.location_on),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _fibIbanController,
          decoration: const InputDecoration(
            labelText: 'IBAN (Optional)',
            hintText: 'Enter IBAN if available',
            prefixIcon: Icon(Icons.credit_card),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
      ],
    );
  }

  Widget _buildZainCashForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ZAIN CASH Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _zainPhoneController,
          decoration: const InputDecoration(
            labelText: 'ZAIN Mobile Number',
            hintText: 'Enter your ZAIN mobile number',
            prefixIcon: Icon(Icons.phone_android),
            prefixText: '+964 ',
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your ZAIN mobile number';
            }
            if (!value.startsWith('78') && !value.startsWith('79')) {
              return 'Please enter a valid ZAIN number (078x or 079x)';
            }
            if (value.length != 10) {
              return 'Please enter a valid 10-digit mobile number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _zainPinController,
          decoration: const InputDecoration(
            labelText: 'ZAIN CASH PIN',
            hintText: 'Enter your ZAIN CASH PIN',
            prefixIcon: Icon(Icons.lock),
          ),
          obscureText: true,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your ZAIN CASH PIN';
            }
            if (value.length != 4) {
              return 'PIN must be 4 digits';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _zainHolderNameController,
          decoration: const InputDecoration(
            labelText: 'Account Holder Name (Optional)',
            hintText: 'Enter your name',
            prefixIcon: Icon(Icons.person),
          ),
          textCapitalization: TextCapitalization.words,
        ),
      ],
    );
  }
