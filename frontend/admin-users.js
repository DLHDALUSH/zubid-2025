// Admin Users Management
let currentPage = 1;
let currentSearch = '';

// Basic HTML escaping helper for safely displaying user data
function escapeHtml(text) {
	if (text === null || text === undefined) return '';
	const div = document.createElement('div');
	div.textContent = String(text);
	return div.innerHTML;
}

document.addEventListener('DOMContentLoaded', async () => {
    await checkAdminAuth();
    await loadUsers();
});

async function loadUsers(page = 1) {
    currentPage = page;
    currentSearch = document.getElementById('userSearch').value;
    
    const tbody = document.getElementById('usersTableBody');
    tbody.innerHTML = '<tr><td colspan="8" class="loading">Loading users...</td></tr>';
    
	    try {
	        const data = await AdminAPI.getUsers(page, currentSearch);
	        
	        if (data.users && data.users.length > 0) {
	            tbody.innerHTML = data.users.map(user => {
	                const safeUsername = escapeHtml(user.username || '');
	                const safeEmail = escapeHtml(user.email || '');
	                const allowedRoles = ['admin', 'user', 'moderator'];
	                const roleClass = allowedRoles.includes(user.role) ? user.role : 'other';
	                const roleLabel = escapeHtml(user.role || 'user');
	                const safeUserId = Number(user.id) || 0;
	                const createdAt = user.created_at ? new Date(user.created_at).toLocaleDateString() : '';
	                return `
	                <tr>
	                    <td>${safeUserId}</td>
	                    <td>${safeUsername}</td>
	                    <td>${safeEmail}</td>
	                    <td><span class="status-badge ${roleClass}">${roleLabel}</span></td>
	                    <td>${user.auction_count}</td>
	                    <td>${user.bid_count}</td>
	                    <td>${createdAt}</td>
	                    <td class="actions">
	                        <button class="btn btn-small btn-primary" onclick="editUser(${safeUserId})">Edit</button>
	                        ${user.role !== 'admin' ? `<button class="btn btn-small btn-danger" onclick="deleteUser(${safeUserId})">Delete</button>` : ''}
	                    </td>
	                </tr>
	            `; }).join('');
            
            renderPagination(data, 'userPagination');
        } else {
            tbody.innerHTML = '<tr><td colspan="8">No users found</td></tr>';
        }
    } catch (error) {
        if (window.utils) window.utils.debugError('Error loading users:', error);
        const errorMsg = error.message || 'Unknown error';
        const escapeHtml = (text) => {
            if (text == null) return '';
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        };
        tbody.innerHTML = `<tr><td colspan="8">Error: ${escapeHtml(errorMsg)}</td></tr>`;
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

        const modal = document.getElementById('editUserModal');
        modal.classList.add('active');
        modal.style.display = 'flex';
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
        modal.classList.add('active');
        modal.style.display = 'flex';
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
        modal.classList.remove('active');
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

// Removed viewBiometric function - biometric functionality has been removed

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
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.remove('active');
        modal.style.display = 'none';
    }
}

// Close modal when clicking outside
window.onclick = function(event) {
    const modals = document.querySelectorAll('.admin-modal, .modal');
    modals.forEach(modal => {
        if (event.target === modal) {
            if (modal.id === 'deleteConfirmModal') {
                closeDeleteConfirmModal();
            } else {
                modal.classList.remove('active');
                modal.style.display = 'none';
            }
        }
    });
};

