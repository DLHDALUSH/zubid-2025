// Return Requests page functionality
let returnRequests = [];
let paidInvoices = [];

// Helper function to escape HTML (prevent XSS)
function escapeHtml(text) {
    if (text == null) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

document.addEventListener('DOMContentLoaded', async () => {
    // Wait for app.js to load and check authentication
    // Check if checkAuth exists, if not wait a bit
    let retries = 0;
    while (typeof checkAuth === 'undefined' && retries < 10) {
        await new Promise(resolve => setTimeout(resolve, 100));
        retries++;
    }
    
    if (typeof checkAuth !== 'undefined') {
        await checkAuth();
    } else {
        // Fallback: try to get profile directly
        try {
            const response = await UserAPI.getProfile();
            currentUser = response;
            updateNavAuth(true);
        } catch (error) {
            updateNavAuth(false);
            showToast('Please login to view return requests', 'error');
            setTimeout(() => {
                window.location.href = 'index.html';
            }, 2000);
            return;
        }
    }
    
    // Double-check currentUser is set
    if (!currentUser) {
        try {
            const response = await UserAPI.getProfile();
            currentUser = response;
            updateNavAuth(true);
        } catch (error) {
            showToast('Please login to view return requests', 'error');
            setTimeout(() => {
                window.location.href = 'index.html';
            }, 2000);
            return;
        }
    }
    
    await loadReturnRequests();
    await loadPaidInvoices();
});

// Load return requests
async function loadReturnRequests() {
    const loadingIndicator = document.getElementById('loadingIndicator');
    const container = document.getElementById('returnRequestsContainer');
    const emptyState = document.getElementById('emptyState');
    const requestsList = document.getElementById('returnRequestsList');
    
    try {
        loadingIndicator.style.display = 'block';
        container.style.display = 'none';
        emptyState.style.display = 'none';
        
        returnRequests = await ReturnRequestAPI.getAll();
        
        loadingIndicator.style.display = 'none';
        
        if (returnRequests.length === 0) {
            container.style.display = 'none';
            emptyState.style.display = 'block';
        } else {
            container.style.display = 'block';
            emptyState.style.display = 'none';
            renderReturnRequests(returnRequests);
        }
    } catch (error) {
        loadingIndicator.style.display = 'none';
        console.error('Error loading return requests:', error);
        showToast('Failed to load return requests', 'error');
    }
}

// Render return requests
function renderReturnRequests(requests) {
    const requestsList = document.getElementById('returnRequestsList');
    requestsList.innerHTML = '';
    
    if (requests.length === 0) {
        requestsList.innerHTML = '<p>No return requests found.</p>';
        return;
    }
    
    requests.forEach(request => {
        const requestCard = createReturnRequestCard(request);
        requestsList.appendChild(requestCard);
    });
}

// Create return request card
function createReturnRequestCard(request) {
    const card = document.createElement('div');
    card.className = 'return-request-card';
    card.style.cssText = 'background: var(--glass-bg); border-radius: 16px; padding: 1.5rem; margin-bottom: 1rem; border: 2px solid var(--border-color);';
    
    const statusColors = {
        'pending': '#ff9800',
        'approved': '#4CAF50',
        'rejected': '#f44336',
        'processing': '#2196F3',
        'completed': '#4CAF50',
        'cancelled': '#9e9e9e'
    };
    
    const statusLabels = {
        'pending': 'Pending Review',
        'approved': 'Approved',
        'rejected': 'Rejected',
        'processing': 'Processing',
        'completed': 'Completed',
        'cancelled': 'Cancelled'
    };
    
	    const statusColor = statusColors[request.status] || '#666';
	    const statusLabelRaw = statusLabels[request.status] || request.status || '';
	    const statusLabel = escapeHtml(statusLabelRaw);
    
    const createdDate = new Date(request.created_at).toLocaleDateString();
    const createdTime = new Date(request.created_at).toLocaleTimeString();
    
    card.innerHTML = `
        <div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 1rem;">
            <div>
                <h3 style="margin: 0 0 0.5rem 0; font-size: 1.25rem;">${escapeHtml(request.auction_name || 'Unknown Item')}</h3>
                <p style="color: var(--text-secondary); margin: 0; font-size: 0.9rem;">
                    Invoice #${request.invoice_id} • Created: ${createdDate} at ${createdTime}
                </p>
            </div>
	            <span class="status-badge" style="background: ${statusColor}; color: white; padding: 0.5rem 1rem; border-radius: 8px; font-weight: 600; font-size: 0.875rem;">
	                ${statusLabel}
	            </span>
        </div>
        
        <div style="margin-bottom: 1rem;">
            <strong>Reason:</strong>
            <p style="margin: 0.5rem 0; color: var(--text-primary);">${escapeHtml(request.reason)}</p>
        </div>
        
        ${request.description ? `
        <div style="margin-bottom: 1rem;">
            <strong>Details:</strong>
            <p style="margin: 0.5rem 0; color: var(--text-secondary); white-space: pre-wrap;">${escapeHtml(request.description)}</p>
        </div>
        ` : ''}
        
        ${request.admin_notes ? `
        <div style="margin-bottom: 1rem; padding: 1rem; background: rgba(255, 152, 0, 0.1); border-radius: 8px; border-left: 4px solid #ff9800;">
            <strong>Admin Response:</strong>
            <p style="margin: 0.5rem 0; color: var(--text-primary); white-space: pre-wrap;">${escapeHtml(request.admin_notes)}</p>
        </div>
        ` : ''}
        
        <div style="display: flex; gap: 0.75rem; margin-top: 1rem;">
            ${request.status === 'pending' ? `
            <button class="btn btn-outline" onclick="cancelReturnRequest(${request.id})" style="flex: 1;">
                Cancel Request
            </button>
            ` : ''}
            <button class="btn btn-primary" onclick="viewReturnRequest(${request.id})" style="flex: 1;">
                View Details
            </button>
        </div>
    `;
    
    return card;
}

// Load paid invoices for return request creation
async function loadPaidInvoices() {
    try {
        const payments = await PaymentAPI.getPayments();
        paidInvoices = payments.filter(p => p.payment_status === 'paid');
        
        const invoiceSelect = document.getElementById('returnInvoice');
        if (invoiceSelect) {
            invoiceSelect.innerHTML = '<option value="">Select an invoice...</option>';
            
            paidInvoices.forEach(invoice => {
                const option = document.createElement('option');
                option.value = invoice.id;
                option.textContent = `${invoice.item_name} - Invoice #${invoice.id} ($${invoice.total_amount.toFixed(2)})`;
                invoiceSelect.appendChild(option);
            });
        }
    } catch (error) {
        console.error('Error loading paid invoices:', error);
    }
}

// Show create return modal
function showCreateReturnModal() {
    if (!currentUser) {
        showToast('Please login to create a return request', 'error');
        showLogin();
        return;
    }
    
    // Check if user has any paid invoices
    if (paidInvoices.length === 0) {
        showToast('You need to have paid invoices to create a return request', 'error');
        return;
    }
    
    const modal = document.getElementById('createReturnModal');
    modal.style.display = 'block';
    loadPaidInvoices();
}

// Close create return modal
function closeCreateReturnModal() {
    const modal = document.getElementById('createReturnModal');
    modal.style.display = 'none';
    document.getElementById('createReturnForm').reset();
    document.getElementById('returnFormError').textContent = '';
    document.getElementById('customReasonGroup').style.display = 'none';
}

// Toggle custom reason field
function toggleCustomReason() {
    const reasonSelect = document.getElementById('returnReason');
    const customReasonGroup = document.getElementById('customReasonGroup');
    
    if (reasonSelect.value === 'other') {
        customReasonGroup.style.display = 'block';
        document.getElementById('customReason').required = true;
    } else {
        customReasonGroup.style.display = 'none';
        document.getElementById('customReason').required = false;
        document.getElementById('customReason').value = '';
    }
}

// Handle create return request
async function handleCreateReturn(event) {
    event.preventDefault();
    
    const formError = document.getElementById('returnFormError');
    formError.textContent = '';
    
    const invoiceId = document.getElementById('returnInvoice').value;
    const reasonSelect = document.getElementById('returnReason').value;
    const customReason = document.getElementById('customReason').value;
    const description = document.getElementById('returnDescription').value;
    
    if (!invoiceId) {
        formError.textContent = 'Please select an invoice';
        return;
    }
    
    if (!reasonSelect) {
        formError.textContent = 'Please select a return reason';
        return;
    }
    
    let reason = reasonSelect;
    if (reasonSelect === 'other') {
        if (!customReason.trim()) {
            formError.textContent = 'Please provide a custom reason';
            return;
        }
        reason = customReason.trim();
    }
    
    try {
        const returnData = {
            invoice_id: parseInt(invoiceId),
            reason: reason,
            description: description || null
        };
        
        await ReturnRequestAPI.create(returnData);
        showToast('Return request created successfully!', 'success');
        closeCreateReturnModal();
        await loadReturnRequests();
    } catch (error) {
        console.error('Error creating return request:', error);
        formError.textContent = error.message || 'Failed to create return request';
        showToast(error.message || 'Failed to create return request', 'error');
    }
}

// Cancel return request
async function cancelReturnRequest(requestId) {
    if (!confirm('Are you sure you want to cancel this return request?')) {
        return;
    }
    
    try {
        await ReturnRequestAPI.cancel(requestId);
        showToast('Return request cancelled successfully', 'success');
        await loadReturnRequests();
    } catch (error) {
        console.error('Error cancelling return request:', error);
        showToast(error.message || 'Failed to cancel return request', 'error');
    }
}

// View return request details
async function viewReturnRequest(requestId) {
    try {
        const request = await ReturnRequestAPI.getById(requestId);
        
        // Create a modal to show details
        const modal = document.createElement('div');
        modal.className = 'modal';
        modal.style.display = 'block';
        modal.innerHTML = `
            <div class="modal-content" style="max-width: 600px;">
                <span class="close" onclick="this.closest('.modal').remove()">&times;</span>
                <h2>Return Request Details</h2>
                <div style="margin-top: 1.5rem;">
                    <div style="margin-bottom: 1rem;">
                        <strong>Item:</strong>
                        <p>${escapeHtml(request.auction_name || 'Unknown')}</p>
                    </div>
                    <div style="margin-bottom: 1rem;">
                        <strong>Invoice ID:</strong>
                        <p>#${request.invoice_id}</p>
                    </div>
                    <div style="margin-bottom: 1rem;">
                        <strong>Reason:</strong>
                        <p>${escapeHtml(request.reason)}</p>
                    </div>
                    ${request.description ? `
                    <div style="margin-bottom: 1rem;">
                        <strong>Description:</strong>
                        <p style="white-space: pre-wrap;">${escapeHtml(request.description)}</p>
                    </div>
                    ` : ''}
                    <div style="margin-bottom: 1rem;">
                        <strong>Status:</strong>
                        <p>${request.status}</p>
                    </div>
                    ${request.admin_notes ? `
                    <div style="margin-bottom: 1rem; padding: 1rem; background: rgba(255, 152, 0, 0.1); border-radius: 8px;">
                        <strong>Admin Notes:</strong>
                        <p style="white-space: pre-wrap; margin-top: 0.5rem;">${escapeHtml(request.admin_notes)}</p>
                    </div>
                    ` : ''}
                    <div style="margin-bottom: 1rem;">
                        <strong>Created:</strong>
                        <p>${new Date(request.created_at).toLocaleString()}</p>
                    </div>
                    ${request.processed_at ? `
                    <div style="margin-bottom: 1rem;">
                        <strong>Processed:</strong>
                        <p>${new Date(request.processed_at).toLocaleString()}</p>
                    </div>
                    ` : ''}
                </div>
                <div style="margin-top: 1.5rem;">
                    <button class="btn btn-primary" onclick="this.closest('.modal').remove()">Close</button>
                </div>
            </div>
        `;
        document.body.appendChild(modal);
        
        // Close on outside click
        modal.onclick = function(e) {
            if (e.target === modal) {
                modal.remove();
            }
        };
    } catch (error) {
        console.error('Error loading return request:', error);
        showToast('Failed to load return request details', 'error');
    }
}

// Close modal when clicking outside
window.onclick = function(event) {
    const createModal = document.getElementById('createReturnModal');
    if (event.target === createModal) {
        closeCreateReturnModal();
    }
}

