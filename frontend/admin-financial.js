// Financial Management JavaScript
let currentFinancialData = null;

// Initialize financial management page
document.addEventListener('DOMContentLoaded', async () => {
    await checkAdminAuth();
    await loadFinancialData();
    await loadPaymentMethodsData();
    await loadPendingPayouts();
});

// Load financial data
async function loadFinancialData() {
    try {
        // Mock financial data - replace with actual API call
        const financialData = {
            totalRevenue: 125000,
            totalCommission: 12500,
            averageSale: 850,
            pendingPayouts: 3200,
            monthlyGrowth: 15.2,
            commissionGrowth: 12.8,
            averageGrowth: 2.1
        };

        currentFinancialData = financialData;

        // Update financial display
        document.getElementById('totalRevenue').textContent = `$${financialData.totalRevenue.toLocaleString()}`;
        document.getElementById('totalCommission').textContent = `$${financialData.totalCommission.toLocaleString()}`;
        document.getElementById('averageSale').textContent = `$${financialData.averageSale.toLocaleString()}`;
        document.getElementById('pendingPayouts').textContent = `$${financialData.pendingPayouts.toLocaleString()}`;

        console.log('Financial data loaded successfully');
    } catch (error) {
        console.error('Error loading financial data:', error);
        showToast('Failed to load financial data', 'error');
    }
}

// Load payment methods data
async function loadPaymentMethodsData() {
    try {
        // Mock payment data - replace with actual API call
        const paymentData = {
            creditCard: { transactions: 1250, volume: 85000, successRate: 98.5 },
            googlePay: { transactions: 320, volume: 22000, successRate: 99.2 },
            fib: { transactions: 180, volume: 15000, successRate: 97.8 },
            zainCash: { transactions: 95, volume: 8500, successRate: 96.5 }
        };

        // Update credit card stats
        document.getElementById('creditCardTransactions').textContent = paymentData.creditCard.transactions.toLocaleString();
        document.getElementById('creditCardVolume').textContent = `$${paymentData.creditCard.volume.toLocaleString()}`;
        document.getElementById('creditCardSuccess').textContent = `${paymentData.creditCard.successRate}%`;

        // Update Google Pay stats
        document.getElementById('googlePayTransactions').textContent = paymentData.googlePay.transactions.toLocaleString();
        document.getElementById('googlePayVolume').textContent = `$${paymentData.googlePay.volume.toLocaleString()}`;
        document.getElementById('googlePaySuccess').textContent = `${paymentData.googlePay.successRate}%`;

        // Update FIB stats
        document.getElementById('fibTransactions').textContent = paymentData.fib.transactions.toLocaleString();
        document.getElementById('fibVolume').textContent = `$${paymentData.fib.volume.toLocaleString()}`;
        document.getElementById('fibSuccess').textContent = `${paymentData.fib.successRate}%`;

        // Update ZainCash stats
        document.getElementById('zainCashTransactions').textContent = paymentData.zainCash.transactions.toLocaleString();
        document.getElementById('zainCashVolume').textContent = `$${paymentData.zainCash.volume.toLocaleString()}`;
        document.getElementById('zainCashSuccess').textContent = `${paymentData.zainCash.successRate}%`;

        console.log('Payment methods data loaded successfully');
    } catch (error) {
        console.error('Error loading payment methods data:', error);
        showToast('Failed to load payment data', 'error');
    }
}

// Load pending payouts
async function loadPendingPayouts() {
    try {
        // Mock payout data - replace with actual API call
        const payouts = [
            {
                id: 12345,
                user: { name: 'John Doe', email: 'john@example.com', avatar: 'J' },
                auction: { title: 'Vintage Watch', id: '#12345' },
                amount: 1250.00,
                commission: 125.00,
                netPayout: 1125.00,
                date: 'Dec 19, 2024',
                status: 'pending'
            },
            {
                id: 12346,
                user: { name: 'Jane Smith', email: 'jane@example.com', avatar: 'J' },
                auction: { title: 'Antique Vase', id: '#12346' },
                amount: 850.00,
                commission: 85.00,
                netPayout: 765.00,
                date: 'Dec 18, 2024',
                status: 'pending'
            }
        ];

        const tbody = document.getElementById('payoutsTableBody');
        if (tbody) {
            tbody.innerHTML = payouts.map(payout => `
                <tr>
                    <td>
                        <div class="user-info">
                            <div class="user-avatar">${payout.user.avatar}</div>
                            <div class="user-details">
                                <div class="user-name">${payout.user.name}</div>
                                <div class="user-email">${payout.user.email}</div>
                            </div>
                        </div>
                    </td>
                    <td>
                        <div class="auction-info">
                            <div class="auction-title">${payout.auction.title}</div>
                            <div class="auction-id">${payout.auction.id}</div>
                        </div>
                    </td>
                    <td class="amount">$${payout.amount.toFixed(2)}</td>
                    <td class="commission">$${payout.commission.toFixed(2)}</td>
                    <td class="net-payout">$${payout.netPayout.toFixed(2)}</td>
                    <td>${payout.date}</td>
                    <td><span class="status-badge ${payout.status}">${payout.status.charAt(0).toUpperCase() + payout.status.slice(1)}</span></td>
                    <td>
                        <div class="action-buttons">
                            <button class="admin-btn-sm admin-btn-success" onclick="approvePayout(${payout.id})">
                                Approve
                            </button>
                            <button class="admin-btn-sm admin-btn-danger" onclick="rejectPayout(${payout.id})">
                                Reject
                            </button>
                        </div>
                    </td>
                </tr>
            `).join('');
        }

        console.log('Pending payouts loaded successfully');
    } catch (error) {
        console.error('Error loading pending payouts:', error);
        showToast('Failed to load pending payouts', 'error');
    }
}

// Refresh financial data
function refreshFinancialData() {
    loadFinancialData();
    showToast('Financial data refreshed', 'success');
}

// Refresh payment data
function refreshPaymentData() {
    loadPaymentMethodsData();
    showToast('Payment data refreshed', 'success');
}

// Refresh payouts
function refreshPayouts() {
    loadPendingPayouts();
    showToast('Payouts refreshed', 'success');
}

// Export financial report
function exportFinancialReport() {
    showToast('Generating financial report...', 'info');
    // Mock export functionality
    setTimeout(() => {
        showToast('Financial report exported successfully', 'success');
    }, 2000);
}

// Process all payouts
function processAllPayouts() {
    if (confirm('Are you sure you want to process all pending payouts?')) {
        showToast('Processing all payouts...', 'info');
        // Mock processing
        setTimeout(() => {
            showToast('All payouts processed successfully', 'success');
            loadPendingPayouts();
        }, 3000);
    }
}

// Approve payout
function approvePayout(payoutId) {
    if (confirm(`Are you sure you want to approve payout #${payoutId}?`)) {
        showToast(`Payout #${payoutId} approved`, 'success');
        loadPendingPayouts();
    }
}

// Reject payout
function rejectPayout(payoutId) {
    const reason = prompt('Please provide a reason for rejection:');
    if (reason) {
        showToast(`Payout #${payoutId} rejected`, 'warning');
        loadPendingPayouts();
    }
}

// Generate report
function generateReport() {
    const reportType = document.getElementById('reportType').value;
    showToast(`Generating ${reportType} report...`, 'info');
    
    // Mock report generation
    setTimeout(() => {
        showToast(`${reportType.charAt(0).toUpperCase() + reportType.slice(1)} report generated successfully`, 'success');
    }, 2000);
}
