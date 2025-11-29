// Payments page functionality

// ZUBID FIB Account Number for receiving payments
const ZUBID_FIB_NUMBER = '07715625156';

// Copy FIB number to clipboard
function copyFibNumber() {
    const number = ZUBID_FIB_NUMBER;
    navigator.clipboard.writeText(number).then(() => {
        if (typeof showToast === 'function') {
            showToast('FIB number copied to clipboard!', 'success');
        } else {
            alert('Copied: ' + number);
        }
    }).catch(err => {
        console.error('Failed to copy:', err);
        // Fallback for older browsers
        const textArea = document.createElement('textarea');
        textArea.value = number;
        document.body.appendChild(textArea);
        textArea.select();
        document.execCommand('copy');
        document.body.removeChild(textArea);
        if (typeof showToast === 'function') {
            showToast('FIB number copied to clipboard!', 'success');
        }
    });
}

// Wait for app.js to initialize
document.addEventListener('DOMContentLoaded', async () => {
    // Check authentication
    if (typeof checkAuth === 'function') {
        await checkAuth();
    } else {
        // Fallback: try to get profile directly
        try {
            const profile = await UserAPI.getProfile();
            if (profile) {
                updateNavAuth(true);
            }
        } catch (error) {
            console.log('Not authenticated');
            window.location.href = 'index.html';
        }
    }
    
    // Load payments
    await loadPayments();
});

async function loadPayments() {
    const loadingEl = document.getElementById('paymentsLoading');
    const containerEl = document.getElementById('paymentsContainer');
    const noPaymentsEl = document.getElementById('noPayments');
    
    try {
        if (loadingEl) loadingEl.style.display = 'block';
        if (containerEl) containerEl.style.display = 'none';
        if (noPaymentsEl) noPaymentsEl.style.display = 'none';
        
        const payments = await PaymentAPI.getPayments();
        
        if (loadingEl) loadingEl.style.display = 'none';
        
        if (!payments || payments.length === 0) {
            if (noPaymentsEl) noPaymentsEl.style.display = 'block';
            return;
        }
        
        if (containerEl) {
            containerEl.style.display = 'block';
            renderPayments(payments);
        }
    } catch (error) {
        console.error('Error loading payments:', error);
        if (loadingEl) loadingEl.style.display = 'none';
        if (noPaymentsEl) noPaymentsEl.style.display = 'block';
        
        // Show error message
        if (typeof showToast === 'function') {
            showToast('Failed to load payments: ' + (error.message || 'Unknown error'), 'error');
        } else {
            alert('Failed to load payments: ' + (error.message || 'Unknown error'));
        }
    }
}

function renderPayments(payments) {
    const container = document.getElementById('paymentsContainer');
    if (!container) return;
    
    container.innerHTML = '';
    
    // Store payments globally for access
    window.paymentsData = payments;
    window.allPayments = payments; // Store all payments for filtering
    
    // Update tab counts
    updateTabCounts(payments);
    
    // Render all payments initially
    payments.forEach(payment => {
        const invoiceCard = createInvoiceCard(payment);
        container.appendChild(invoiceCard);
    });
}

function updateTabCounts(payments) {
    const counts = {
        all: payments.length,
        pending: payments.filter(p => p.payment_status === 'pending').length,
        paid: payments.filter(p => p.payment_status === 'paid').length,
        failed: payments.filter(p => p.payment_status === 'failed').length
    };
    
    document.getElementById('countAll').textContent = counts.all;
    document.getElementById('countPending').textContent = counts.pending;
    document.getElementById('countPaid').textContent = counts.paid;
    document.getElementById('countFailed').textContent = counts.failed;
}

function filterPayments(filter) {
    if (!window.allPayments) return;
    
    // Update active tab
    document.querySelectorAll('.payment-tab').forEach(tab => {
        tab.classList.remove('active');
    });
    document.querySelector(`[data-filter="${filter}"]`).classList.add('active');
    
    // Filter payments
    let filteredPayments = window.allPayments;
    if (filter !== 'all') {
        filteredPayments = window.allPayments.filter(p => p.payment_status === filter);
    }
    
    // Re-render filtered payments
    const container = document.getElementById('paymentsContainer');
    if (!container) return;
    
    container.innerHTML = '';
    
    if (filteredPayments.length === 0) {
        container.innerHTML = `
            <div class="empty-state">
                <div class="empty-icon">${filter === 'pending' ? '⏳' : filter === 'paid' ? '✅' : filter === 'failed' ? '❌' : '📋'}</div>
                <h3>No ${filter === 'all' ? '' : filter} payments</h3>
                <p>You don't have any ${filter === 'all' ? '' : filter} payments at this time.</p>
            </div>
        `;
        return;
    }
    
    filteredPayments.forEach(payment => {
        const invoiceCard = createInvoiceCard(payment);
        container.appendChild(invoiceCard);
    });
}

function createInvoiceCard(payment) {
    const card = document.createElement('div');
    card.className = 'invoice-card';
    
    const statusClass = payment.payment_status === 'paid' ? 'paid' : 
                       payment.payment_status === 'pending' ? 'pending' : 'failed';
    
    card.innerHTML = `
        <div class="invoice-header">
            <div class="invoice-item-info">
                ${payment.auction.image_url ? `
                    <img src="${payment.auction.image_url}" alt="${payment.auction.item_name}" class="invoice-item-image">
                ` : ''}
                <div class="invoice-item-details">
                    <h3>${payment.auction.item_name}</h3>
                    <p class="invoice-id">Invoice #${payment.id}</p>
                    <p class="invoice-date">Created: ${new Date(payment.created_at).toLocaleDateString()}</p>
                </div>
            </div>
            <div class="invoice-status">
                <span class="status-badge status-${statusClass}">${getStatusLabel(payment.payment_status)}</span>
            </div>
        </div>
        
        <div class="invoice-body">
            <div class="invoice-breakdown">
                <div class="invoice-row">
                    <span>Item Price:</span>
                    <span>$${payment.item_price.toFixed(2)}</span>
                </div>
                <div class="invoice-row">
                    <span>Bid Fee (1%):</span>
                    <span>$${payment.bid_fee.toFixed(2)}</span>
                </div>
                <div class="invoice-row">
                    <span>Delivery Fee:</span>
                    <span>$${payment.delivery_fee.toFixed(2)}</span>
                </div>
                <div class="invoice-row total">
                    <span>Total Amount:</span>
                    <span>$${payment.total_amount.toFixed(2)}</span>
                </div>
            </div>
            
            ${payment.qr_code_url || payment.auction?.qr_code_url ? `
                <div class="invoice-qr-section">
                    <h4>Item QR Code</h4>
                    <div class="qr-code-container">
                        <img src="${payment.qr_code_url || payment.auction.qr_code_url}" alt="QR Code" class="qr-code-image" />
                        <p class="qr-code-hint">Scan to view auction details</p>
                    </div>
                </div>
            ` : ''}
            
            ${payment.payment_status === 'pending' ? `
                <div class="invoice-actions">
                    <button class="btn btn-primary" onclick='openPaymentModal(${payment.id})'>
                        💳 Pay Now
                    </button>
                </div>
            ` : ''}
            
            ${payment.payment_status === 'paid' ? `
                <div class="invoice-paid-info">
                    <p>✅ Paid on ${payment.paid_at ? new Date(payment.paid_at).toLocaleDateString() : 'N/A'}</p>
                </div>
            ` : ''}
        </div>
    `;
    
    return card;
}

function getStatusLabel(status) {
    const labels = {
        'pending': 'Pending Payment',
        'paid': 'Paid',
        'failed': 'Payment Failed',
        'cancelled': 'Cancelled'
    };
    return labels[status] || status;
}

// Payment Modal State
let currentInvoice = null;
let selectedPaymentMethod = null;

// Payment Methods Configuration
const PAYMENT_METHODS = [
    {
        id: 'cash_on_delivery',
        name: 'Cash on Delivery',
        icon: '🚚',
        description: 'Pay when you receive',
        requiresCard: false,
        requiresFib: false
    },
    {
        id: 'fib',
        name: 'FIB Bank',
        icon: '🏦',
        description: 'Iraq mobile payment',
        requiresCard: false,
        requiresFib: true
    },
    {
        id: 'stripe',
        name: 'Credit/Debit Card',
        icon: '💳',
        description: 'Visa, Mastercard, Amex',
        requiresCard: true,
        requiresFib: false
    },
    {
        id: 'paypal',
        name: 'PayPal',
        icon: '🅿️',
        description: 'Pay with PayPal account',
        requiresCard: false,
        requiresFib: false
    }
];

function openPaymentModal(invoiceId) {
    if (!window.paymentsData) {
        showToast('Payment data not loaded', 'error');
        return;
    }
    
    const invoice = window.paymentsData.find(p => p.id === invoiceId);
    if (!invoice) {
        showToast('Invoice not found', 'error');
        return;
    }
    
    if (invoice.payment_status === 'paid') {
        showToast('This invoice has already been paid', 'info');
        return;
    }
    
    currentInvoice = invoice;
    selectedPaymentMethod = null;
    
    // Populate invoice summary
    populateInvoiceSummary(invoice);
    
    // Populate payment methods
    populatePaymentMethods();
    
    // Reset form
    resetPaymentForm();
    
    // Show modal
    const modal = document.getElementById('paymentModal');
    if (modal) {
        modal.style.display = 'block';
        document.body.style.overflow = 'hidden';
    }
}

function closePaymentModal() {
    const modal = document.getElementById('paymentModal');
    if (modal) {
        modal.style.display = 'none';
        document.body.style.overflow = '';
    }
    currentInvoice = null;
    selectedPaymentMethod = null;
    resetPaymentForm();
}

function populateInvoiceSummary(invoice) {
    const summaryEl = document.getElementById('paymentInvoiceSummary');
    if (!summaryEl) return;
    
    summaryEl.innerHTML = `
        <h4>📋 Invoice Summary</h4>
        <div class="summary-item">
            <span>Item Price:</span>
            <span>$${invoice.item_price.toFixed(2)}</span>
        </div>
        <div class="summary-item">
            <span>Bid Fee (1%):</span>
            <span>$${invoice.bid_fee.toFixed(2)}</span>
        </div>
        <div class="summary-item">
            <span>Delivery Fee:</span>
            <span>$${invoice.delivery_fee.toFixed(2)}</span>
        </div>
        <div class="summary-item">
            <span>Total Amount:</span>
            <span>$${invoice.total_amount.toFixed(2)}</span>
        </div>
    `;
    
    // Update total in footer
    const totalEl = document.getElementById('paymentTotalAmount');
    if (totalEl) {
        totalEl.textContent = `$${invoice.total_amount.toFixed(2)}`;
    }
}

function populatePaymentMethods() {
    const gridEl = document.getElementById('paymentMethodsGrid');
    if (!gridEl) return;
    
    gridEl.innerHTML = PAYMENT_METHODS.map(method => `
        <div class="payment-method-option" onclick="selectPaymentMethod('${method.id}')" data-method="${method.id}">
            <span class="payment-method-icon">${method.icon}</span>
            <div class="payment-method-name">${method.name}</div>
            <div class="payment-method-description">${method.description}</div>
        </div>
    `).join('');
}

function selectPaymentMethod(methodId) {
    selectedPaymentMethod = methodId;

    // Update UI
    document.querySelectorAll('.payment-method-option').forEach(el => {
        el.classList.remove('selected');
    });

    const selectedEl = document.querySelector(`[data-method="${methodId}"]`);
    if (selectedEl) {
        selectedEl.classList.add('selected');
    }

    // Show/hide appropriate sections
    const method = PAYMENT_METHODS.find(m => m.id === methodId);
    const formContainer = document.getElementById('paymentFormContainer');
    const fibFormContainer = document.getElementById('fibFormContainer');
    const codInfo = document.getElementById('cashOnDeliveryInfo');

    // Hide all forms first
    if (formContainer) formContainer.style.display = 'none';
    if (fibFormContainer) fibFormContainer.style.display = 'none';
    if (codInfo) codInfo.style.display = 'none';

    if (method.requiresCard) {
        if (formContainer) formContainer.style.display = 'block';
    } else if (method.requiresFib) {
        if (fibFormContainer) fibFormContainer.style.display = 'block';
    } else if (methodId === 'cash_on_delivery') {
        if (codInfo) codInfo.style.display = 'block';
    }

    // Update submit button text
    const submitBtn = document.getElementById('submitPaymentBtn');
    if (submitBtn) {
        const btnText = submitBtn.querySelector('.btn-text');
        if (btnText) {
            if (methodId === 'cash_on_delivery') {
                btnText.textContent = 'Confirm Order';
            } else if (methodId === 'paypal') {
                btnText.textContent = 'Pay with PayPal';
            } else if (methodId === 'fib') {
                btnText.textContent = 'Pay with FIB';
            } else {
                btnText.textContent = 'Pay Now';
            }
        }
    }
}

function resetPaymentForm() {
    // Clear card form fields
    const cardNumber = document.getElementById('cardNumber');
    const cardExpiry = document.getElementById('cardExpiry');
    const cardCVC = document.getElementById('cardCVC');
    const cardholderName = document.getElementById('cardholderName');
    const billingAddress = document.getElementById('billingAddress');

    if (cardNumber) cardNumber.value = '';
    if (cardExpiry) cardExpiry.value = '';
    if (cardCVC) cardCVC.value = '';
    if (cardholderName) cardholderName.value = '';
    if (billingAddress) billingAddress.value = '';

    // Clear FIB form fields
    const fibName = document.getElementById('fibName');
    const fibPhone = document.getElementById('fibPhone');
    if (fibName) fibName.value = '';
    if (fibPhone) fibPhone.value = '';

    // Clear errors
    clearFormErrors();

    // Hide form sections
    const paymentFormContainer = document.getElementById('paymentFormContainer');
    const fibFormContainer = document.getElementById('fibFormContainer');
    const cashOnDeliveryInfo = document.getElementById('cashOnDeliveryInfo');

    if (paymentFormContainer) paymentFormContainer.style.display = 'none';
    if (fibFormContainer) fibFormContainer.style.display = 'none';
    if (cashOnDeliveryInfo) cashOnDeliveryInfo.style.display = 'none';

    // Reset card brand icon
    const brandIcon = document.getElementById('cardBrandIcon');
    if (brandIcon) {
        brandIcon.className = 'card-brand-icon';
    }
}

function clearFormErrors() {
    document.querySelectorAll('.error-message').forEach(el => {
        el.textContent = '';
    });
    document.querySelectorAll('input').forEach(el => {
        el.style.borderColor = '';
    });
}

// Card number formatting and validation
document.addEventListener('DOMContentLoaded', () => {
    const cardNumberInput = document.getElementById('cardNumber');
    const cardExpiryInput = document.getElementById('cardExpiry');
    const cardCVCInput = document.getElementById('cardCVC');
    const cardBrandIcon = document.getElementById('cardBrandIcon');
    
    if (cardNumberInput) {
        cardNumberInput.addEventListener('input', (e) => {
            let value = e.target.value.replace(/\s/g, '');
            let formatted = value.match(/.{1,4}/g)?.join(' ') || value;
            if (formatted.length <= 19) {
                e.target.value = formatted;
            }
            
            // Detect card brand
            detectCardBrand(value);
            
            // Validate
            validateCardNumber(value);
        });
    }
    
    if (cardExpiryInput) {
        cardExpiryInput.addEventListener('input', (e) => {
            let value = e.target.value.replace(/\D/g, '');
            if (value.length >= 2) {
                value = value.substring(0, 2) + '/' + value.substring(2, 4);
            }
            e.target.value = value;
            validateExpiry(value);
        });
    }
    
    if (cardCVCInput) {
        cardCVCInput.addEventListener('input', (e) => {
            e.target.value = e.target.value.replace(/\D/g, '').substring(0, 4);
            validateCVC(e.target.value);
        });
    }
    
    function detectCardBrand(number) {
        if (!cardBrandIcon) return;
        
        const cleanNumber = number.replace(/\s/g, '');
        let brand = '';
        
        if (/^4/.test(cleanNumber)) {
            brand = 'visa';
        } else if (/^5[1-5]/.test(cleanNumber)) {
            brand = 'mastercard';
        } else if (/^3[47]/.test(cleanNumber)) {
            brand = 'amex';
        }
        
        if (brand && cleanNumber.length > 0) {
            cardBrandIcon.className = `card-brand-icon ${brand} visible`;
        } else {
            cardBrandIcon.className = 'card-brand-icon';
        }
    }
    
    function validateCardNumber(number) {
        const errorEl = document.getElementById('cardNumberError');
        const input = cardNumberInput;
        
        if (!number || number.length < 13) {
            if (errorEl) errorEl.textContent = '';
            if (input) input.style.borderColor = '';
            return false;
        }
        
        // Luhn algorithm
        let sum = 0;
        let isEven = false;
        for (let i = number.length - 1; i >= 0; i--) {
            let digit = parseInt(number[i]);
            if (isEven) {
                digit *= 2;
                if (digit > 9) digit -= 9;
            }
            sum += digit;
            isEven = !isEven;
        }
        
        const isValid = sum % 10 === 0;
        
        if (!isValid && number.length >= 13) {
            if (errorEl) errorEl.textContent = 'Invalid card number';
            if (input) input.style.borderColor = 'var(--error-color)';
            return false;
        } else {
            if (errorEl) errorEl.textContent = '';
            if (input) input.style.borderColor = '';
            return true;
        }
    }
    
    function validateExpiry(value) {
        const errorEl = document.getElementById('cardExpiryError');
        const input = cardExpiryInput;
        
        if (!value || value.length < 5) {
            if (errorEl) errorEl.textContent = '';
            if (input) input.style.borderColor = '';
            return false;
        }
        
        const [month, year] = value.split('/');
        const monthNum = parseInt(month);
        const yearNum = parseInt('20' + year);
        const now = new Date();
        const expiry = new Date(yearNum, monthNum - 1);
        
        if (monthNum < 1 || monthNum > 12) {
            if (errorEl) errorEl.textContent = 'Invalid month';
            if (input) input.style.borderColor = 'var(--error-color)';
            return false;
        }
        
        if (expiry < now) {
            if (errorEl) errorEl.textContent = 'Card has expired';
            if (input) input.style.borderColor = 'var(--error-color)';
            return false;
        }
        
        if (errorEl) errorEl.textContent = '';
        if (input) input.style.borderColor = '';
        return true;
    }
    
    function validateCVC(value) {
        const errorEl = document.getElementById('cardCVCError');
        const input = cardCVCInput;
        
        if (!value || value.length < 3) {
            if (errorEl) errorEl.textContent = '';
            if (input) input.style.borderColor = '';
            return false;
        }
        
        if (value.length < 3) {
            if (errorEl) errorEl.textContent = 'CVV must be 3-4 digits';
            if (input) input.style.borderColor = 'var(--error-color)';
            return false;
        }
        
        if (errorEl) errorEl.textContent = '';
        if (input) input.style.borderColor = '';
        return true;
    }
});

async function submitPayment() {
    if (!currentInvoice) {
        showToast('No invoice selected', 'error');
        return;
    }

    if (!selectedPaymentMethod) {
        showToast('Please select a payment method', 'error');
        return;
    }

    // Validate based on payment method
    const method = PAYMENT_METHODS.find(m => m.id === selectedPaymentMethod);

    // Validate FIB details if required
    if (method.requiresFib) {
        const fibName = document.getElementById('fibName').value.trim();
        const fibPhone = document.getElementById('fibPhone').value.trim();

        if (!fibName) {
            showToast('Please enter your full name', 'error');
            document.getElementById('fibName').focus();
            return;
        }

        if (!fibPhone) {
            showToast('Please enter your Iraqi phone number', 'error');
            document.getElementById('fibPhone').focus();
            return;
        }

        // Validate Iraqi phone number format (07XX XXX XXXX)
        const phoneClean = fibPhone.replace(/\s/g, '');
        if (!/^07[3-9]\d{8}$/.test(phoneClean)) {
            showToast('Please enter a valid Iraqi phone number (07XX XXX XXXX)', 'error');
            document.getElementById('fibPhone').focus();
            return;
        }
    }

    // Validate card details if required
    if (method.requiresCard) {
        const cardNumber = document.getElementById('cardNumber').value.replace(/\s/g, '');
        const cardExpiry = document.getElementById('cardExpiry').value;
        const cardCVC = document.getElementById('cardCVC').value;
        const cardholderName = document.getElementById('cardholderName').value.trim();

        if (!cardNumber || cardNumber.length < 13) {
            showToast('Please enter a valid card number', 'error');
            document.getElementById('cardNumber').focus();
            return;
        }

        if (!cardExpiry || cardExpiry.length < 5) {
            showToast('Please enter card expiry date', 'error');
            document.getElementById('cardExpiry').focus();
            return;
        }

        if (!cardCVC || cardCVC.length < 3) {
            showToast('Please enter card CVV', 'error');
            document.getElementById('cardCVC').focus();
            return;
        }

        if (!cardholderName) {
            showToast('Please enter cardholder name', 'error');
            document.getElementById('cardholderName').focus();
            return;
        }
    }
    
    // Show loading state
    const submitBtn = document.getElementById('submitPaymentBtn');
    const btnText = submitBtn.querySelector('.btn-text');
    const btnLoader = submitBtn.querySelector('.btn-loader');
    
    submitBtn.disabled = true;
    if (btnText) btnText.style.display = 'none';
    if (btnLoader) btnLoader.style.display = 'inline-flex';
    
    try {
        const result = await PaymentAPI.processPayment(currentInvoice.id, selectedPaymentMethod);
        
        if (typeof showToast === 'function') {
            showToast(result.message || 'Payment processed successfully', 'success');
        }
        
        // Close modal
        closePaymentModal();
        
        // Reload payments
        await loadPayments();
    } catch (error) {
        console.error('Payment error:', error);
        if (typeof showToast === 'function') {
            showToast(error.message || 'Payment failed', 'error');
        }
    } finally {
        submitBtn.disabled = false;
        if (btnText) btnText.style.display = 'inline';
        if (btnLoader) btnLoader.style.display = 'none';
    }
}

// Close modal when clicking outside
window.onclick = function(event) {
    const modal = document.getElementById('paymentModal');
    if (event.target === modal) {
        closePaymentModal();
    }
}

// Legacy function for backward compatibility
async function processPaymentDirectly(invoiceId) {
    openPaymentModal(invoiceId);
}

