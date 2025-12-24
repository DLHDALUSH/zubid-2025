// Payments page functionality

// ZUBID FIB Account Number for receiving payments
const ZUBID_FIB_NUMBER = '07715625156';

// USD to IQD exchange rate
const USD_TO_IQD_RATE = 1410;

// Format currency - supports USD and IQD
function formatCurrency(amount, currency = 'USD') {
    if (currency === 'IQD') {
        const iqd = Math.round(amount * USD_TO_IQD_RATE);
        return iqd.toLocaleString('en-US') + ' IQD';
    }
    return '$' + parseFloat(amount).toFixed(2);
}

// Convert USD to IQD
function convertToIQD(usdAmount) {
    return Math.round(usdAmount * USD_TO_IQD_RATE);
}

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

// Basic HTML escaping helper for safely displaying auction titles, etc.
function escapeHtml(text) {
	if (text === null || text === undefined) return '';
	const div = document.createElement('div');
	div.textContent = String(text);
	return div.innerHTML;
}

function createInvoiceCard(payment) {
	const card = document.createElement('div');
	card.className = 'premium-invoice-card';
	card.id = `invoice-${payment.id}`;

    const statusClass = payment.payment_status === 'paid' ? 'paid' :
                       payment.payment_status === 'pending' ? 'pending' : 'failed';

    const createdDate = new Date(payment.created_at);
    const formattedDate = createdDate.toLocaleDateString('en-US', {
        year: 'numeric', month: 'short', day: 'numeric'
    });

    // Helper function to construct full URL for relative paths
    const getFullUrl = (url) => {
        if (!url) return null;
        if (url.startsWith('http') || url.startsWith('data:')) return url;
        // Prepend base URL for relative paths
        let baseUrl = 'http://localhost:5000';
        if (typeof API_BASE_URL !== 'undefined' && API_BASE_URL) {
            baseUrl = API_BASE_URL.replace('/api', '').replace(/\/$/, '');
        } else if (window.API_BASE_URL) {
            baseUrl = window.API_BASE_URL.replace('/api', '').replace(/\/$/, '');
        }
        return baseUrl + url;
    };

    // Get QR code URL
    let qrCodeUrl = getFullUrl(payment.qr_code_url || payment.auction?.qr_code_url);

	// Get Product Image URL - Fixed!
	let productImageUrl = getFullUrl(payment.auction?.image_url);

	const rawItemName = payment.auction?.item_name || '';
	const safeItemName = escapeHtml(rawItemName);
	const shortItemName = rawItemName.length > 30
	    ? `${rawItemName.substring(0, 27)}...`
	    : rawItemName;

    card.innerHTML = `
        <!-- Premium Invoice Header -->
        <div class="premium-invoice-header">
            <div class="invoice-brand">
                <div class="brand-icon">💎</div>
                <div class="brand-info">
                    <span class="brand-name">ZUBID</span>
                    <span class="brand-tag">Premium Auction</span>
                </div>
            </div>
            <div class="invoice-badge">
                <span class="badge-icon">📋</span>
                <span class="badge-text">INV-${String(payment.id).padStart(6, '0')}</span>
            </div>
        </div>

        <!-- Product Showcase Section -->
        <div class="product-showcase">
	            <div class="product-image-wrapper">
	                ${productImageUrl ? `
	                    <img src="${productImageUrl}" alt="${escapeHtml(shortItemName)}" class="product-image" onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';" />
                    <div class="product-image-fallback" style="display:none;">
                        <span class="fallback-icon">📦</span>
                    </div>
                ` : `
                    <div class="product-image-fallback">
                        <span class="fallback-icon">📦</span>
                    </div>
                `}
                <div class="image-overlay">
                    <a href="auction-detail.html?id=${payment.auction.id}" class="view-auction-btn">
                        <span>👁️</span> View Auction
                    </a>
                </div>
            </div>
	            <div class="product-details">
	                <h3 class="product-name" title="${safeItemName}">${escapeHtml(shortItemName)}</h3>
                <div class="product-meta">
                    <span class="meta-item">
                        <span class="meta-icon">📅</span>
                        <span>${formattedDate}</span>
                    </span>
                    <span class="meta-item">
                        <span class="meta-icon">🏷️</span>
                        <span>Auction #${payment.auction.id}</span>
                    </span>
                </div>
                <div class="status-row">
                    <span class="premium-status-badge status-${statusClass}">
                        <span class="status-dot"></span>
                        ${getStatusLabel(payment.payment_status)}
                    </span>
                    ${payment.payment_method ? `
                        <span class="payment-method-tag">
                            ${getPaymentMethodIcon(payment.payment_method)} ${getPaymentMethodLabel(payment.payment_method)}
                        </span>
                    ` : ''}
                </div>
            </div>
        </div>

        <!-- Premium Price Section -->
        <div class="premium-price-section">
            <div class="price-breakdown-card">
                <div class="breakdown-header">
                    <span class="header-icon">💰</span>
                    <h4>Price Breakdown</h4>
                </div>
                <div class="breakdown-items">
                    <div class="breakdown-row">
                        <span class="row-label">
                            <span class="row-icon">🏆</span>
                            Winning Bid
                        </span>
                        <span class="row-value">$${payment.item_price.toFixed(2)}</span>
                    </div>
                    <div class="breakdown-row">
                        <span class="row-label">
                            <span class="row-icon">📊</span>
                            Platform Fee (1%)
                        </span>
                        <span class="row-value">$${payment.bid_fee.toFixed(2)}</span>
                    </div>
                    <div class="breakdown-row">
                        <span class="row-label">
                            <span class="row-icon">🚚</span>
                            Delivery Fee
                        </span>
                        <span class="row-value">$${payment.delivery_fee.toFixed(2)}</span>
                    </div>
                    ${payment.cashback_amount > 0 ? `
                    <div class="breakdown-row cashback-row">
                        <span class="row-label">
                            <span class="row-icon">🎁</span>
                            Cashback Applied
                        </span>
                        <span class="row-value cashback-value">-$${payment.cashback_amount.toFixed(2)}</span>
                    </div>
                    ` : ''}
                    ${payment.pending_cashback > 0 ? `
                    <div class="breakdown-row pending-row" onclick="applyCashback(${payment.id}, ${payment.auction.id})">
                        <span class="row-label">
                            <span class="row-icon">💵</span>
                            Available Cashback
                        </span>
                        <span class="row-value pending-value">
                            -$${payment.pending_cashback.toFixed(2)}
                            <button class="apply-btn">Apply</button>
                        </span>
                    </div>
                    ` : ''}
                </div>
                <div class="breakdown-total">
                    <span class="total-label">Total Amount</span>
                    <span class="total-value">$${payment.total_amount.toFixed(2)}</span>
                </div>
            </div>

            <!-- QR Code Card -->
            <div class="qr-code-card">
                <div class="qr-header">
                    <span class="qr-icon">📱</span>
                    <span class="qr-title">Product QR</span>
                </div>
                ${qrCodeUrl ? `
                    <div class="qr-image-container">
                        <img src="${qrCodeUrl}" alt="QR Code" class="qr-image" onerror="this.parentElement.innerHTML='<div class=qr-fallback><span>📱</span><small>QR unavailable</small></div>';" />
                    </div>
                    <p class="qr-hint">Scan to verify authenticity</p>
                ` : `
                    <div class="qr-generating">
                        <span class="generating-icon">⏳</span>
                        <small>Generating...</small>
                    </div>
                `}
            </div>
        </div>

        <!-- Premium Actions Bar -->
        <div class="premium-actions-bar">
            <div class="action-buttons">
                ${payment.payment_status === 'pending' ? `
                    <button class="action-btn pay-btn" onclick='openPaymentModal(${payment.id})'>
                        <span class="btn-icon">💳</span>
                        <span class="btn-text">Pay Now</span>
                    </button>
                ` : ''}
                <button class="action-btn print-btn" onclick="printInvoice(${payment.id})">
                    <span class="btn-icon">🖨️</span>
                    <span class="btn-text">Print</span>
                </button>
                <button class="action-btn download-btn" onclick="downloadInvoice(${payment.id})">
                    <span class="btn-icon">📥</span>
                    <span class="btn-text">PDF</span>
                </button>
            </div>
            ${payment.payment_status === 'paid' ? `
                <div class="paid-badge">
                    <span class="paid-icon">✅</span>
                    <span class="paid-text">Paid ${payment.paid_at ? new Date(payment.paid_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }) : ''}</span>
                </div>
            ` : ''}
        </div>

        <!-- Premium Footer -->
        <div class="premium-invoice-footer">
            <div class="footer-security">
                <span class="security-icon">🔒</span>
                <span>Secure Transaction</span>
            </div>
            <div class="footer-brand">
                <span class="brand-text">ZUBID</span>
                <span class="year">© ${new Date().getFullYear()}</span>
            </div>
        </div>
    `;

    return card;
}

// Get payment method icon
function getPaymentMethodIcon(method) {
    const icons = {
        'cash_on_delivery': '💵',
        'fib': '🏦',
        'card': '💳',
        'fastpay': '⚡'
    };
    return icons[method] || '💰';
}

// Get payment method label
function getPaymentMethodLabel(method) {
    const labels = {
        'cash_on_delivery': 'Cash on Delivery',
        'fib': 'FIB Bank',
        'card': 'Credit Card',
        'fastpay': 'FastPay'
    };
    return labels[method] || method;
}

// Print Invoice Function - Optimized for Half A4 Paper
function printInvoice(invoiceId) {
    const invoiceCard = document.getElementById(`invoice-${invoiceId}`);
    if (!invoiceCard) {
        showToast('Invoice not found', 'error');
        return;
    }

    // Create print window
    const printWindow = window.open('', '_blank');

    // Get the styles
    const styles = Array.from(document.styleSheets)
        .map(sheet => {
            try {
                return Array.from(sheet.cssRules).map(rule => rule.cssText).join('');
            } catch (e) {
                return '';
            }
        })
        .join('');

    // Create print content optimized for half A4
    printWindow.document.write(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>Invoice #${invoiceId} - ZUBID</title>
            <style>
                ${styles}
                * { box-sizing: border-box; }
                body {
                    margin: 0;
                    padding: 5mm;
                    background: white;
                    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                }
                .invoice-card {
                    width: 148mm !important;
                    max-width: 148mm !important;
                    margin: 0 auto;
                    box-shadow: none !important;
                    border: 1px solid #e2e8f0 !important;
                }
                .invoice-actions-bar {
                    display: none !important;
                }
                @media print {
                    @page {
                        size: A5 portrait;
                        margin: 5mm;
                    }
                    body {
                        margin: 0;
                        padding: 0;
                        -webkit-print-color-adjust: exact;
                        print-color-adjust: exact;
                    }
                    .invoice-card {
                        border: 1px solid #cbd5e1 !important;
                        width: 100% !important;
                        max-width: 100% !important;
                    }
                    .invoice-brand-header,
                    .invoice-qr-section,
                    .status-badge,
                    .invoice-breakdown,
                    .qr-code-wrapper {
                        -webkit-print-color-adjust: exact;
                        print-color-adjust: exact;
                    }
                    .qr-code-image {
                        width: 100px !important;
                        height: 100px !important;
                    }
                    .qr-product-info {
                        background: #f8fafc !important;
                    }
                    .qr-auction-id {
                        color: #4f46e5 !important;
                    }
                }
            </style>
        </head>
        <body>
            ${invoiceCard.outerHTML}
            <script>
                window.onload = function() {
                    setTimeout(function() {
                        window.print();
                        window.close();
                    }, 500);
                };
            </script>
        </body>
        </html>
    `);

    printWindow.document.close();
}

// Download Invoice as PDF
function downloadInvoice(invoiceId) {
    showToast('📥 Opening print dialog - select "Save as PDF"', 'info');
    setTimeout(() => printInvoice(invoiceId), 300);
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

// Payment Methods Configuration - Premium Iraq-focused options
const PAYMENT_METHODS = [
    {
        id: 'cash_on_delivery',
        name: 'Cash on Delivery',
        icon: '💵',
        description: 'Pay cash when your item arrives',
        features: ['No upfront payment', 'Verify before paying', 'Secure delivery'],
        requiresCard: false,
        requiresFib: false,
        popular: true
    },
    {
        id: 'fib',
        name: 'FIB Bank Transfer',
        icon: '🏦',
        description: 'Fast & secure Iraqi banking',
        features: ['Instant confirmation', 'FIB mobile app', 'Bank-level security'],
        requiresCard: false,
        requiresFib: true,
        popular: false
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
        <div class="premium-payment-card ${method.popular ? 'popular' : ''}" onclick="selectPaymentMethod('${method.id}')" data-method="${method.id}">
            ${method.popular ? '<div class="popular-badge">⭐ Most Popular</div>' : ''}
            <div class="payment-card-header">
                <div class="payment-method-icon-wrapper">
                    <span class="payment-method-icon">${method.icon}</span>
                </div>
                <div class="payment-method-info">
                    <div class="payment-method-name">${method.name}</div>
                    <div class="payment-method-description">${method.description}</div>
                </div>
                <div class="payment-check-circle">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3">
                        <polyline points="20 6 9 17 4 12"></polyline>
                    </svg>
                </div>
            </div>
            <div class="payment-features">
                ${method.features.map(f => `<span class="feature-tag">✓ ${f}</span>`).join('')}
            </div>
        </div>
    `).join('');
}

function selectPaymentMethod(methodId) {
    selectedPaymentMethod = methodId;

    // Update UI - support both old and new premium card classes
    document.querySelectorAll('.payment-method-option, .premium-payment-card').forEach(el => {
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
                btnText.textContent = '✓ Confirm Order';
            } else if (methodId === 'fib') {
                btnText.textContent = '🏦 Pay with FIB';
            } else {
                btnText.textContent = 'Complete Payment';
            }
        }
    }

    // Update total amount display based on payment method (IQD for FIB)
    if (currentInvoice) {
        const totalEl = document.getElementById('paymentTotalAmount');
        const currencyEl = document.querySelector('.currency-symbol');

        if (methodId === 'fib') {
            // Show in IQD for FIB
            const iqd = convertToIQD(currentInvoice.total_amount);
            if (totalEl) totalEl.textContent = iqd.toLocaleString('en-US');
            if (currencyEl) currencyEl.textContent = 'IQD';
        } else {
            // Show in USD for other methods
            if (totalEl) totalEl.textContent = currentInvoice.total_amount.toFixed(2);
            if (currencyEl) currencyEl.textContent = '$';
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
        let result;

        // If FIB method, include name and phone for money request
        if (selectedPaymentMethod === 'fib') {
            const fibName = document.getElementById('fibName').value.trim();
            const fibPhone = document.getElementById('fibPhone').value.trim().replace(/\s/g, '');

            result = await PaymentAPI.processPayment(currentInvoice.id, selectedPaymentMethod, {
                fib_name: fibName,
                fib_phone: fibPhone
            });

            // Show special message for FIB money request
            if (typeof showToast === 'function') {
                showToast('💰 Money request sent! Check your FIB app to approve.', 'success');
            }

            // Show additional info modal
            showFibRequestSentModal(result);
        } else {
            result = await PaymentAPI.processPayment(currentInvoice.id, selectedPaymentMethod);

            if (typeof showToast === 'function') {
                showToast(result.message || 'Payment processed successfully', 'success');
            }
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

// Show FIB money request sent confirmation
function showFibRequestSentModal(result) {
    // Create modal if it doesn't exist
    let modal = document.getElementById('fibRequestModal');
    if (!modal) {
        modal = document.createElement('div');
        modal.id = 'fibRequestModal';
        modal.className = 'modal';
        modal.innerHTML = `
            <div class="modal-content fib-request-modal">
                <div class="fib-request-icon">📲</div>
                <h2>Money Request Sent!</h2>
                <p class="fib-request-message">A payment request has been sent to your FIB mobile app.</p>
                <div class="fib-request-details">
                    <div class="fib-detail-row">
                        <span class="label">Amount:</span>
                        <span class="value" id="fibRequestAmount"></span>
                    </div>
                    <div class="fib-detail-row">
                        <span class="label">Phone:</span>
                        <span class="value" id="fibRequestPhone"></span>
                    </div>
                    <div class="fib-detail-row">
                        <span class="label">Request ID:</span>
                        <span class="value" id="fibRequestId"></span>
                    </div>
                </div>
                <div class="fib-request-instructions">
                    <p>📱 Open your <strong>FIB app</strong></p>
                    <p>✅ Go to <strong>Notifications</strong> or <strong>Pending Requests</strong></p>
                    <p>💳 <strong>Approve</strong> the payment request</p>
                </div>
                <button class="btn btn-primary" onclick="closeFibRequestModal()">Got it!</button>
            </div>
        `;
        document.body.appendChild(modal);
    }

    // Update details - Always show IQD for FIB payments
    const amountEl = document.getElementById('fibRequestAmount');
    const phoneEl = document.getElementById('fibRequestPhone');
    const requestIdEl = document.getElementById('fibRequestId');

    const amount = result.amount || currentInvoice?.total_amount || 0;
    if (amountEl) amountEl.textContent = formatCurrency(amount, 'IQD');
    if (phoneEl) phoneEl.textContent = result.fib_phone || '';
    if (requestIdEl) requestIdEl.textContent = result.request_id || '';

    modal.style.display = 'flex';
}

function closeFibRequestModal() {
    const modal = document.getElementById('fibRequestModal');
    if (modal) {
        modal.style.display = 'none';
    }
}

// Apply pending cashback to invoice
async function applyCashback(invoiceId, auctionId) {
    try {
        // First get the pending cashback for this auction
        const cashbackResponse = await fetch(`${window.API_BASE_URL || 'http://localhost:5000/api'}/user/cashback?auction_id=${auctionId}`, {
            credentials: 'include'
        });

        if (!cashbackResponse.ok) {
            throw new Error('Failed to get cashback info');
        }

        const cashbackData = await cashbackResponse.json();
        const pendingCashback = cashbackData.cashbacks.find(c => c.status === 'pending' && c.auction_id === auctionId);

        if (!pendingCashback) {
            showToast('No pending cashback found', 'error');
            return;
        }

        // Process the cashback
        const processResponse = await fetch(`${window.API_BASE_URL || 'http://localhost:5000/api'}/user/cashback/${pendingCashback.id}/process`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            credentials: 'include'
        });

        if (processResponse.ok) {
            showToast('🎉 $5 Cashback applied to your invoice!', 'success');
            // Refresh the payments list
            loadPayments();
        } else {
            const error = await processResponse.json();
            showToast(error.error || 'Failed to apply cashback', 'error');
        }
    } catch (error) {
        console.error('Error applying cashback:', error);
        showToast('Error applying cashback. Please try again.', 'error');
    }
}
