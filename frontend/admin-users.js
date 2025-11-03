// Admin Users Management
let currentPage = 1;
let currentSearch = '';

document.addEventListener('DOMContentLoaded', async () => {
    await checkAdminAuth();
    await loadUsers();
});

async function loadUsers(page = 1) {
    currentPage = page;
    currentSearch = document.getElementById('userSearch').value;
    
    const tbody = document.getElementById('usersTableBody');
    tbody.innerHTML = '<tr><td colspan="9" class="loading">Loading users...</td></tr>';
    
    try {
        const data = await AdminAPI.getUsers(page, currentSearch);
        
        if (data.users && data.users.length > 0) {
            tbody.innerHTML = data.users.map(user => `
                <tr>
                    <td>${user.id}</td>
                    <td>${user.username}</td>
                    <td>${user.email}</td>
                    <td><span class="status-badge ${user.role}">${user.role}</span></td>
                    <td>
                        ${user.has_biometric 
                            ? `<span class="status-badge success" title="${user.biometric_type || 'Verified'}">✓ Verified</span>` 
                            : '<span class="status-badge error">Not Verified</span>'}
                    </td>
                    <td>${user.auction_count}</td>
                    <td>${user.bid_count}</td>
                    <td>${new Date(user.created_at).toLocaleDateString()}</td>
                    <td class="actions">
                        <button class="btn btn-small btn-primary" onclick="editUser(${user.id})">Edit</button>
                        ${user.has_biometric ? `<button class="btn btn-small btn-info" onclick="viewBiometric(${user.id})">View Biometric</button>` : ''}
                        ${user.role !== 'admin' ? `<button class="btn btn-small btn-danger" onclick="deleteUser(${user.id})">Delete</button>` : ''}
                    </td>
                </tr>
            `).join('');
            
            renderPagination(data, 'userPagination');
        } else {
            tbody.innerHTML = '<tr><td colspan="9">No users found</td></tr>';
        }
    } catch (error) {
        console.error('Error loading users:', error);
        tbody.innerHTML = `<tr><td colspan="9">Error: ${error.message}</td></tr>`;
        showToast('Error loading users', 'error');
    }
}

function resetUserSearch() {
    document.getElementById('userSearch').value = '';
    loadUsers(1);
}

async function editUser(userId) {
    try {
        const data = await AdminAPI.getUsers(1, '');
        const user = data.users.find(u => u.id === userId);
        
        if (!user) {
            showToast('User not found', 'error');
            return;
        }
        
        document.getElementById('editUserId').value = user.id;
        document.getElementById('editUsername').value = user.username;
        document.getElementById('editEmail').value = user.email;
        document.getElementById('editRole').value = user.role;
        
        document.getElementById('editUserModal').style.display = 'block';
    } catch (error) {
        showToast('Error loading user details', 'error');
    }
}

async function handleUpdateUser(event) {
    event.preventDefault();
    
    const userId = document.getElementById('editUserId').value;
    const data = {
        email: document.getElementById('editEmail').value,
        role: document.getElementById('editRole').value
    };
    
    try {
        await AdminAPI.updateUser(userId, data);
        showToast('User updated successfully', 'success');
        closeModal('editUserModal');
        await loadUsers(currentPage);
    } catch (error) {
        showToast(error.message || 'Failed to update user', 'error');
    }
}

let pendingDeleteUserId = null;

async function deleteUser(userId) {
    // Store the user ID to delete
    pendingDeleteUserId = userId;
    
    // Show confirmation modal
    const modal = document.getElementById('deleteConfirmModal');
    if (modal) {
        modal.style.display = 'block';
    } else {
        // Fallback to default confirm if modal doesn't exist
        if (confirm('Are you sure you want to delete this account? This action cannot be undone.')) {
            await confirmDeleteUser();
        }
    }
}

function closeDeleteConfirmModal() {
    const modal = document.getElementById('deleteConfirmModal');
    if (modal) {
        modal.style.display = 'none';
    }
    pendingDeleteUserId = null;
}

async function confirmDeleteUser() {
    if (!pendingDeleteUserId) {
        return;
    }
    
    const userId = pendingDeleteUserId;
    pendingDeleteUserId = null;
    
    // Close the modal
    closeDeleteConfirmModal();
    
    try {
        await AdminAPI.deleteUser(userId);
        showToast('User deleted successfully', 'success');
        await loadUsers(currentPage);
    } catch (error) {
        showToast(error.message || 'Failed to delete user', 'error');
    }
}

async function viewBiometric(userId) {
    const contentDiv = document.getElementById('biometricContent');
    const modal = document.getElementById('biometricModal');
    
    contentDiv.innerHTML = '<div class="loading">Loading biometric information...</div>';
    modal.style.display = 'block';
    
    try {
        const userDetails = await AdminAPI.getUserDetails(userId);
        const biometric = userDetails.biometric_data;
        
        if (!biometric || !biometric.has_biometric) {
            contentDiv.innerHTML = `
                <div style="text-align: center; padding: 2rem;">
                    <p style="color: #a0a0c0; font-size: 1.1rem;">No biometric information available for this user.</p>
                </div>
            `;
            return;
        }
        
        let html = `
            <div style="margin-bottom: 1.5rem;">
                <h3 style="color: var(--primary-color); margin-bottom: 0.5rem;">User Information</h3>
                <p><strong>Username:</strong> ${userDetails.username}</p>
                <p><strong>Email:</strong> ${userDetails.email}</p>
                <p><strong>ID Number:</strong> ${userDetails.id_number}</p>
            </div>
            
            <div style="margin-bottom: 1.5rem;">
                <h3 style="color: var(--primary-color); margin-bottom: 0.5rem;">Biometric Verification Status</h3>
                <p><strong>Type:</strong> ${biometric.type || 'Unknown'}</p>
                ${biometric.timestamp ? `<p><strong>Captured:</strong> ${new Date(biometric.timestamp).toLocaleString()}</p>` : ''}
                ${biometric.device ? `<p><strong>Device:</strong> ${biometric.device}</p>` : ''}
            </div>
        `;
        
        // Display images if available
        if (biometric.id_card_front_image || biometric.id_card_image) {
            html += `
                <div style="margin-bottom: 1.5rem;">
                    <h3 style="color: var(--primary-color); margin-bottom: 0.5rem;">ID Card Front</h3>
                    <img src="${biometric.id_card_front_image || biometric.id_card_image}" 
                         alt="ID Card Front" 
                         style="max-width: 100%; border-radius: 8px; border: 2px solid var(--primary-color); cursor: pointer;"
                         onclick="window.open(this.src, '_blank')"
                         onerror="this.parentElement.innerHTML='<p style=color:#e74c3c;>Image failed to load</p>'">
                </div>
            `;
        }
        
        if (biometric.id_card_back_image) {
            html += `
                <div style="margin-bottom: 1.5rem;">
                    <h3 style="color: var(--primary-color); margin-bottom: 0.5rem;">ID Card Back</h3>
                    <img src="${biometric.id_card_back_image}" 
                         alt="ID Card Back" 
                         style="max-width: 100%; border-radius: 8px; border: 2px solid var(--primary-color); cursor: pointer;"
                         onclick="window.open(this.src, '_blank')"
                         onerror="this.parentElement.innerHTML='<p style=color:#e74c3c;>Image failed to load</p>'">
                </div>
            `;
        }
        
        if (biometric.selfie_image) {
            html += `
                <div style="margin-bottom: 1.5rem;">
                    <h3 style="color: var(--primary-color); margin-bottom: 0.5rem;">Selfie</h3>
                    <img src="${biometric.selfie_image}" 
                         alt="Selfie" 
                         style="max-width: 100%; border-radius: 8px; border: 2px solid var(--primary-color); cursor: pointer;"
                         onclick="window.open(this.src, '_blank')"
                         onerror="this.parentElement.innerHTML='<p style=color:#e74c3c;>Image failed to load</p>'">
                </div>
            `;
        }
        
        // Summary
        html += `
            <div style="margin-top: 1.5rem; padding: 1rem; background: var(--bg-secondary); border-radius: 8px;">
                <h4 style="color: var(--primary-color); margin-bottom: 0.5rem;">Verification Summary</h4>
                <p><strong>ID Card Front:</strong> ${biometric.has_id_front ? '✓ Captured' : '✗ Not captured'}</p>
                <p><strong>ID Card Back:</strong> ${biometric.has_id_back ? '✓ Captured' : '✗ Not captured'}</p>
                <p><strong>Selfie:</strong> ${biometric.has_selfie ? '✓ Captured' : '✗ Not captured'}</p>
            </div>
        `;
        
        contentDiv.innerHTML = html;
    } catch (error) {
        console.error('Error loading biometric information:', error);
        contentDiv.innerHTML = `
            <div style="text-align: center; padding: 2rem;">
                <p style="color: #e74c3c; font-size: 1.1rem;">Error loading biometric information: ${error.message}</p>
            </div>
        `;
        showToast('Failed to load biometric information', 'error');
    }
}

function renderPagination(data, containerId) {
    const container = document.getElementById(containerId);
    if (!container) return;
    
    if (data.pages <= 1) {
        container.innerHTML = '';
        return;
    }
    
    let html = '<div class="pagination-controls">';
    
    if (data.page > 1) {
        html += `<button class="btn btn-outline" onclick="loadUsers(${data.page - 1})">Previous</button>`;
    }
    
    for (let i = 1; i <= data.pages; i++) {
        if (i === data.page) {
            html += `<button class="btn btn-primary">${i}</button>`;
        } else if (i === 1 || i === data.pages || (i >= data.page - 2 && i <= data.page + 2)) {
            html += `<button class="btn btn-outline" onclick="loadUsers(${i})">${i}</button>`;
        } else if (i === data.page - 3 || i === data.page + 3) {
            html += `<span>...</span>`;
        }
    }
    
    if (data.page < data.pages) {
        html += `<button class="btn btn-outline" onclick="loadUsers(${data.page + 1})">Next</button>`;
    }
    
    html += '</div>';
    container.innerHTML = html;
}

function closeModal(modalId) {
    document.getElementById(modalId).style.display = 'none';
}

// Close modal when clicking outside
window.onclick = function(event) {
    const modals = document.querySelectorAll('.modal');
    modals.forEach(modal => {
        if (event.target === modal) {
            if (modal.id === 'deleteConfirmModal') {
                closeDeleteConfirmModal();
            } else {
                modal.style.display = 'none';
            }
        }
    });
};

