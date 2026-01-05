import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/payment_methods_provider.dart';
import '../../data/models/add_payment_method_request.dart';

class AddPaymentMethodScreen extends ConsumerStatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  ConsumerState<AddPaymentMethodScreen> createState() =>
      _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState
    extends ConsumerState<AddPaymentMethodScreen> {
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

  // Additional controllers for compatibility
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderNameController = TextEditingController();

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
                  onPressed:
                      paymentMethodsState.isLoading ? null : _addPaymentMethod,
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

    return RadioGroup<String>(
      groupValue: _selectedType,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedType = value;
          });
        }
      },
      child: Column(
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
              // groupValue and onChanged are managed by RadioGroup ancestor
            ),
          );
        }).toList(),
      ),
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

  Widget _buildCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_selectedType.toUpperCase()} Card Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _cardNumberController,
          decoration: const InputDecoration(
            labelText: 'Card Number',
            hintText: '1234 5678 9012 3456',
            prefixIcon: Icon(Icons.credit_card),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your card number';
            }
            if (value.length < 13 || value.length > 16) {
              return 'Please enter a valid card number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryController,
                decoration: const InputDecoration(
                  labelText: 'Expiry Date',
                  hintText: 'MM/YY',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter expiry date';
                  }
                  if (value.length != 4) {
                    return 'Please enter valid expiry (MMYY)';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  hintText: '123',
                  prefixIcon: Icon(Icons.security),
                ),
                obscureText: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter CVV';
                  }
                  if (value.length < 3 || value.length > 4) {
                    return 'Please enter valid CVV';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _cardHolderNameController,
          decoration: const InputDecoration(
            labelText: 'Cardholder Name',
            hintText: 'Enter name as shown on card',
            prefixIcon: Icon(Icons.person),
          ),
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter cardholder name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Future<void> _addPaymentMethod() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      AddPaymentMethodRequest request;

      switch (_selectedType) {
        case 'fib':
          request = AddPaymentMethodRequest.fib(
            fibAccountNumber: _fibAccountController.text,
            fibHolderName: _fibHolderNameController.text,
            fibPhoneNumber: '+964${_fibPhoneController.text}',
            fibBranch: _fibBranchController.text.isNotEmpty
                ? _fibBranchController.text
                : '',
            fibIban: _fibIbanController.text.isNotEmpty
                ? _fibIbanController.text
                : '',
            isDefault: _setAsDefault,
          );
          break;
        case 'zain_cash':
          request = AddPaymentMethodRequest.zainCash(
            zainPhoneNumber: '+964${_zainPhoneController.text}',
            zainPin: _zainPinController.text,
            zainHolderName: _zainHolderNameController.text.isNotEmpty
                ? _zainHolderNameController.text
                : '',
            isDefault: _setAsDefault,
          );
          break;
        case 'visa':
          request = AddPaymentMethodRequest.visa(
            cardNumber: _cardNumberController.text,
            cardHolderName: _cardHolderNameController.text,
            expiryMonth: _cardExpMonthController.text,
            expiryYear: _cardExpYearController.text,
            cvv: _cardCvcController.text,
            isDefault: _setAsDefault,
          );
          break;
        case 'mastercard':
          request = AddPaymentMethodRequest.mastercard(
            cardNumber: _cardNumberController.text,
            cardHolderName: _cardHolderNameController.text,
            expiryMonth: _cardExpMonthController.text,
            expiryYear: _cardExpYearController.text,
            cvv: _cardCvcController.text,
            isDefault: _setAsDefault,
          );
          break;
        default:
          throw Exception('Invalid payment method type');
      }

      await ref.read(paymentMethodsProvider.notifier).addPaymentMethod(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment method added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add payment method: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
