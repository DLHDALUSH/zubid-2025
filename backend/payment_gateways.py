"""
Payment Gateway Integration Module
This module provides a unified interface for different payment gateways.

Supported Gateways:
- Stripe
- PayPal
- FIB (simulated)
- Cash on Delivery

To add a new payment gateway:
1. Create a new class inheriting from PaymentGateway
2. Implement the required methods
3. Register it in the PAYMENT_GATEWAYS dictionary
"""

import os
from typing import Dict, Optional
from datetime import datetime

class PaymentGateway:
    """Base class for payment gateways"""
    
    def __init__(self, config: Dict):
        self.config = config
        self.name = self.__class__.__name__
    
    def process_payment(self, amount: float, currency: str, invoice_id: int, 
                       user_data: Dict) -> Dict:
        """
        Process a payment
        
        Args:
            amount: Payment amount
            currency: Currency code (e.g., 'USD', 'IQD')
            invoice_id: Invoice ID
            user_data: User information (email, name, etc.)
        
        Returns:
            Dict with keys:
                - success: bool
                - transaction_id: str (if successful)
                - error: str (if failed)
        """
        raise NotImplementedError("Subclasses must implement process_payment")
    
    def verify_payment(self, transaction_id: str) -> Dict:
        """
        Verify a payment transaction
        
        Args:
            transaction_id: Transaction ID from payment gateway
        
        Returns:
            Dict with payment status
        """
        raise NotImplementedError("Subclasses must implement verify_payment")
    
    def refund_payment(self, transaction_id: str, amount: Optional[float] = None) -> Dict:
        """
        Refund a payment
        
        Args:
            transaction_id: Transaction ID to refund
            amount: Amount to refund (None = full refund)
        
        Returns:
            Dict with refund status
        """
        raise NotImplementedError("Subclasses must implement refund_payment")


class StripeGateway(PaymentGateway):
    """Stripe payment gateway integration"""
    
    def __init__(self, config: Dict):
        super().__init__(config)
        self.api_key = config.get('api_key')
        if not self.api_key:
            raise ValueError("Stripe API key not configured")
        
        # Import stripe (optional dependency)
        try:
            import stripe
            stripe.api_key = self.api_key
            self.stripe = stripe
        except ImportError:
            raise ImportError(
                "Stripe SDK not installed. Install with: pip install stripe"
            )
    
    def process_payment(self, amount: float, currency: str, invoice_id: int, 
                       user_data: Dict) -> Dict:
        """Process payment via Stripe"""
        try:
            # Create payment intent
            intent = self.stripe.PaymentIntent.create(
                amount=int(amount * 100),  # Convert to cents
                currency=currency.lower(),
                metadata={
                    'invoice_id': invoice_id,
                    'user_email': user_data.get('email', ''),
                }
            )
            
            return {
                'success': True,
                'transaction_id': intent.id,
                'client_secret': intent.client_secret,
                'requires_action': intent.status == 'requires_action'
            }
        except Exception as e:
            return {
                'success': False,
                'error': str(e)
            }
    
    def verify_payment(self, transaction_id: str) -> Dict:
        """Verify Stripe payment"""
        try:
            intent = self.stripe.PaymentIntent.retrieve(transaction_id)
            return {
                'success': intent.status == 'succeeded',
                'status': intent.status,
                'amount': intent.amount / 100,  # Convert from cents
                'currency': intent.currency
            }
        except Exception as e:
            return {
                'success': False,
                'error': str(e)
            }
    
    def refund_payment(self, transaction_id: str, amount: Optional[float] = None) -> Dict:
        """Refund Stripe payment"""
        try:
            if amount:
                refund = self.stripe.Refund.create(
                    payment_intent=transaction_id,
                    amount=int(amount * 100)
                )
            else:
                refund = self.stripe.Refund.create(
                    payment_intent=transaction_id
                )
            
            return {
                'success': refund.status == 'succeeded',
                'refund_id': refund.id,
                'amount': refund.amount / 100
            }
        except Exception as e:
            return {
                'success': False,
                'error': str(e)
            }


class PayPalGateway(PaymentGateway):
    """PayPal payment gateway integration"""
    
    def __init__(self, config: Dict):
        super().__init__(config)
        self.client_id = config.get('client_id')
        self.client_secret = config.get('client_secret')
        self.mode = config.get('mode', 'sandbox')  # sandbox or live
        
        if not self.client_id or not self.client_secret:
            raise ValueError("PayPal client_id and client_secret required")
        
        # Import paypalrestsdk (optional dependency)
        try:
            import paypalrestsdk
            paypalrestsdk.configure({
                'mode': self.mode,
                'client_id': self.client_id,
                'client_secret': self.client_secret
            })
            self.paypal = paypalrestsdk
        except ImportError:
            raise ImportError(
                "PayPal SDK not installed. Install with: pip install paypalrestsdk"
            )
    
    def process_payment(self, amount: float, currency: str, invoice_id: int, 
                       user_data: Dict) -> Dict:
        """Process payment via PayPal"""
        try:
            payment = self.paypal.Payment({
                "intent": "sale",
                "payer": {
                    "payment_method": "paypal"
                },
                "transactions": [{
                    "amount": {
                        "total": f"{amount:.2f}",
                        "currency": currency
                    },
                    "description": f"Invoice #{invoice_id}",
                    "custom": str(invoice_id)
                }],
                "redirect_urls": {
                    "return_url": self.config.get('return_url', ''),
                    "cancel_url": self.config.get('cancel_url', '')
                }
            })
            
            if payment.create():
                return {
                    'success': True,
                    'transaction_id': payment.id,
                    'approval_url': next(
                        link.href for link in payment.links if link.rel == "approval_url"
                    )
                }
            else:
                return {
                    'success': False,
                    'error': payment.error
                }
        except Exception as e:
            return {
                'success': False,
                'error': str(e)
            }
    
    def verify_payment(self, transaction_id: str) -> Dict:
        """Verify PayPal payment"""
        try:
            payment = self.paypal.Payment.find(transaction_id)
            return {
                'success': payment.state == 'approved',
                'status': payment.state,
                'amount': float(payment.transactions[0].amount.total),
                'currency': payment.transactions[0].amount.currency
            }
        except Exception as e:
            return {
                'success': False,
                'error': str(e)
            }
    
    def refund_payment(self, transaction_id: str, amount: Optional[float] = None) -> Dict:
        """Refund PayPal payment"""
        # PayPal refund implementation
        return {
            'success': False,
            'error': 'PayPal refund not yet implemented'
        }


class FIBGateway(PaymentGateway):
    """FIB (simulated) payment gateway"""
    
    def __init__(self, config: Dict):
        super().__init__(config)
        # FIB gateway configuration would go here
        self.api_url = config.get('api_url', '')
        self.api_key = config.get('api_key', '')
    
    def process_payment(self, amount: float, currency: str, invoice_id: int, 
                       user_data: Dict) -> Dict:
        """Process payment via FIB (simulated)"""
        # In production, integrate with actual FIB API
        # For now, simulate successful payment
        try:
            # Simulate API call
            # In production: Make actual HTTP request to FIB API
            transaction_id = f'FIB-{invoice_id}-{int(datetime.now().timestamp())}'
            
            return {
                'success': True,
                'transaction_id': transaction_id
            }
        except Exception as e:
            return {
                'success': False,
                'error': str(e)
            }
    
    def verify_payment(self, transaction_id: str) -> Dict:
        """Verify FIB payment"""
        # In production, verify with FIB API
        return {
            'success': True,
            'status': 'completed'
        }
    
    def refund_payment(self, transaction_id: str, amount: Optional[float] = None) -> Dict:
        """Refund FIB payment"""
        return {
            'success': False,
            'error': 'FIB refund not yet implemented'
        }


class CashOnDeliveryGateway(PaymentGateway):
    """Cash on Delivery payment method"""
    
    def __init__(self, config: Dict):
        super().__init__(config)
    
    def process_payment(self, amount: float, currency: str, invoice_id: int, 
                       user_data: Dict) -> Dict:
        """Process cash on delivery order"""
        # Cash on delivery doesn't require payment processing
        # Payment is collected upon delivery
        return {
            'success': True,
            'transaction_id': f'COD-{invoice_id}',
            'payment_method': 'cash_on_delivery'
        }
    
    def verify_payment(self, transaction_id: str) -> Dict:
        """Verify COD order"""
        return {
            'success': True,
            'status': 'pending_delivery'
        }
    
    def refund_payment(self, transaction_id: str, amount: Optional[float] = None) -> Dict:
        """Cancel COD order"""
        return {
            'success': True,
            'status': 'cancelled'
        }


# Payment gateway registry
PAYMENT_GATEWAYS = {
    'stripe': StripeGateway,
    'paypal': PayPalGateway,
    'fib': FIBGateway,
    'cash_on_delivery': CashOnDeliveryGateway,
}


def get_payment_gateway(gateway_name: str, config: Optional[Dict] = None) -> PaymentGateway:
    """
    Get a payment gateway instance
    
    Args:
        gateway_name: Name of the gateway ('stripe', 'paypal', 'fib', 'cash_on_delivery')
        config: Gateway-specific configuration dictionary
    
    Returns:
        PaymentGateway instance
    """
    if gateway_name not in PAYMENT_GATEWAYS:
        raise ValueError(f"Unknown payment gateway: {gateway_name}")
    
    if config is None:
        config = {}
    
    gateway_class = PAYMENT_GATEWAYS[gateway_name]
    return gateway_class(config)


def get_configured_gateway() -> Optional[PaymentGateway]:
    """
    Get the configured payment gateway from environment variables
    
    Returns:
        PaymentGateway instance or None if not configured
    """
    gateway_name = os.getenv('PAYMENT_GATEWAY', '').lower()
    
    if not gateway_name:
        return None
    
    config = {}
    
    if gateway_name == 'stripe':
        config = {
            'api_key': os.getenv('STRIPE_SECRET_KEY'),
            'publishable_key': os.getenv('STRIPE_PUBLISHABLE_KEY')
        }
    elif gateway_name == 'paypal':
        config = {
            'client_id': os.getenv('PAYPAL_CLIENT_ID'),
            'client_secret': os.getenv('PAYPAL_CLIENT_SECRET'),
            'mode': os.getenv('PAYPAL_MODE', 'sandbox'),
            'return_url': os.getenv('PAYPAL_RETURN_URL', ''),
            'cancel_url': os.getenv('PAYPAL_CANCEL_URL', '')
        }
    elif gateway_name == 'fib':
        config = {
            'api_url': os.getenv('FIB_API_URL', ''),
            'api_key': os.getenv('FIB_API_KEY', '')
        }
    elif gateway_name == 'cash_on_delivery':
        config = {}
    else:
        return None
    
    try:
        return get_payment_gateway(gateway_name, config)
    except (ValueError, ImportError) as e:
        print(f"Warning: Could not initialize payment gateway {gateway_name}: {e}")
        return None

