// Payments page functionality
let currentInvoice = null;

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
    
    payments.forEach(payment => {
        const invoiceCard = createInvoiceCard(payment);
        container.appendChild(invoiceCard);
    });
}

function openPaymentModalFromCard(invoiceId) {
    // Find payment data from stored payments
    if (!window.paymentsData) {
        console.error('Payments data not available');
        if (typeof showToast === 'function') {
            showToast('Payment data not available. Please refresh the page.', 'error');
        }
        return;
    }
    
    const paymentData = window.paymentsData.find(p => p.id === invoiceId);
    if (!paymentData) {
        console.error('Payment data not found for invoice:', invoiceId);
        if (typeof showToast === 'function') {
            showToast('Payment data not found', 'error');
        }
        return;
    }
    
    openPaymentModal(invoiceId, paymentData);
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
            
            ${payment.payment_method ? `
                <div class="invoice-payment-method">
                    <strong>Payment Method:</strong> ${getPaymentMethodLabel(payment.payment_method)}
                </div>
            ` : ''}
            
            ${payment.payment_status === 'pending' && !payment.payment_method ? `
                <div class="invoice-actions">
                    <button class="btn btn-primary" onclick='openPaymentModalFromCard(${payment.id})'>
                        Pay Now
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

function getPaymentMethodLabel(method) {
    const labels = {
        'cash_on_delivery': 'Cash on Delivery',
        'fib': 'FIB Payment'
    };
    return labels[method] || method;
}

function openPaymentModal(invoiceId, paymentData) {
    try {
        // Handle both direct object and JSON string
        if (typeof paymentData === 'string') {
            paymentData = JSON.parse(paymentData.replace(/&quot;/g, '"'));
        }
        
        if (!paymentData || typeof paymentData.item_price === 'undefined') {
            console.error('Invalid payment data:', paymentData);
            if (typeof showToast === 'function') {
                showToast('Invalid payment data', 'error');
            }
            return;
        }
        
        currentInvoice = { id: invoiceId, ...paymentData };
        
        // Update invoice summary
        const summaryItemPrice = document.getElementById('summaryItemPrice');
        const summaryBidFee = document.getElementById('summaryBidFee');
        const summaryDeliveryFee = document.getElementById('summaryDeliveryFee');
        const summaryTotal = document.getElementById('summaryTotal');
        const paymentInvoiceDetails = document.getElementById('paymentInvoiceDetails');
        const paymentModal = document.getElementById('paymentModal');
        
        if (summaryItemPrice) summaryItemPrice.textContent = `$${paymentData.item_price.toFixed(2)}`;
        if (summaryBidFee) summaryBidFee.textContent = `$${paymentData.bid_fee.toFixed(2)}`;
        if (summaryDeliveryFee) summaryDeliveryFee.textContent = `$${paymentData.delivery_fee.toFixed(2)}`;
        if (summaryTotal) summaryTotal.textContent = `$${paymentData.total_amount.toFixed(2)}`;
        if (paymentInvoiceDetails) paymentInvoiceDetails.style.display = 'block';
        if (paymentModal) paymentModal.style.display = 'block';
    } catch (error) {
        console.error('Error opening payment modal:', error);
        if (typeof showToast === 'function') {
            showToast('Failed to open payment modal', 'error');
        } else {
            alert('Failed to open payment modal');
        }
    }
}

function selectPaymentMethod(method) {
    if (!currentInvoice) return;
    
    processPayment(currentInvoice.id, method);
}

async function processPayment(invoiceId, paymentMethod) {
    try {
        if (!invoiceId || !paymentMethod) {
            throw new Error('Invalid payment data');
        }
        
        const result = await PaymentAPI.processPayment(invoiceId, paymentMethod);
        
        closeModal('paymentModal');
        
        if (typeof showToast === 'function') {
            showToast(result.message || 'Payment processed successfully', 'success');
        } else {
            alert(result.message || 'Payment processed successfully');
        }
        
        // Reload payments
        await loadPayments();
        
        currentInvoice = null;
    } catch (error) {
        console.error('Payment error:', error);
        if (typeof showToast === 'function') {
            showToast(error.message || 'Payment failed', 'error');
        } else {
            alert('Payment failed: ' + (error.message || 'Unknown error'));
        }
    }
}

function closeModal(modalId) {
    document.getElementById(modalId).style.display = 'none';
    currentInvoice = null;
}

// Close modal when clicking outside
window.onclick = function(event) {
    const modal = document.getElementById('paymentModal');
    if (event.target === modal) {
        closeModal('paymentModal');
    }
}

