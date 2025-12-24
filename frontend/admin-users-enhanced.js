// Enhanced User Management JavaScript
let usersData = [];
let selectedUsers = new Set();
let currentFilters = {};

// Initialize enhanced user management
document.addEventListener('DOMContentLoaded', async () => {
    await checkAdminAuth();
    await loadUserAnalytics();
    await loadUsers();
    
    // Auto-refresh user data every 60 seconds
    setInterval(loadUserAnalytics, 60000);
});

// Load user analytics
async function loadUserAnalytics() {
    try {
        // Mock analytics data - replace with actual API call
        const analytics = {
            totalUsers: 1250,
            activeUsers: 1180,
            suspendedUsers: 15,
            monthlyRegistrations: 45,
            weeklyRegistrations: 12,
            dailyRegistrations: 3,
            dailyActivePercent: 75,
            weeklyActivePercent: 85,
            pendingVerifications: 8,
            reportedUsers: 3,
            suspendedAccounts: 15
        };

        // Update analytics display
        document.getElementById('totalUsers').textContent = analytics.totalUsers.toLocaleString();
        document.getElementById('activeUsers').textContent = analytics.activeUsers.toLocaleString();
        document.getElementById('suspendedUsers').textContent = analytics.suspendedUsers;
        document.getElementById('monthlyRegistrations').textContent = `+${analytics.monthlyRegistrations}`;
        document.getElementById('weeklyRegistrations').textContent = `+${analytics.weeklyRegistrations}`;
        document.getElementById('dailyRegistrations').textContent = analytics.dailyRegistrations;
        document.getElementById('dailyActivePercent').textContent = `${analytics.dailyActivePercent}%`;
        document.getElementById('weeklyActivePercent').textContent = `${analytics.weeklyActivePercent}%`;
        document.getElementById('pendingVerifications').textContent = analytics.pendingVerifications;
        document.getElementById('reportedUsers').textContent = analytics.reportedUsers;
        document.getElementById('suspendedAccounts').textContent = analytics.suspendedAccounts;

        // Update progress bars
        document.getElementById('dailyActiveBar').style.width = `${analytics.dailyActivePercent}%`;
        document.getElementById('weeklyActiveBar').style.width = `${analytics.weeklyActivePercent}%`;

        console.log('User analytics loaded successfully');
    } catch (error) {
        console.error('Error loading user analytics:', error);
        showToast('Failed to load user analytics', 'error');
    }
}

// Load users with enhanced data
async function loadUsers() {
    try {
        // Mock enhanced user data - replace with actual API call
        const users = [
            {
                id: 1,
                username: 'john_doe',
                email: 'john@example.com',
                fullName: 'John Doe',
                avatar: 'J',
                status: 'active',
                role: 'user',
                emailVerified: true,
                phoneVerified: true,
                biometricEnabled: true,
                totalAuctions: 15,
                totalBids: 45,
                lastLogin: '2024-12-19 09:30:00',
                createdAt: '2024-01-15',
                activityScore: 85
            },
            {
                id: 2,
                username: 'mary_smith',
                email: 'mary@example.com',
                fullName: 'Mary Smith',
                avatar: 'M',
                status: 'active',
                role: 'premium',
                emailVerified: true,
                phoneVerified: false,
                biometricEnabled: false,
                totalAuctions: 8,
                totalBids: 23,
                lastLogin: '2024-12-18 15:45:00',
                createdAt: '2024-02-20',
                activityScore: 72
            },
            {
                id: 3,
                username: 'bob_wilson',
                email: 'bob@example.com',
                fullName: 'Bob Wilson',
                avatar: 'B',
                status: 'suspended',
                role: 'user',
                emailVerified: true,
                phoneVerified: true,
                biometricEnabled: false,
                totalAuctions: 3,
                totalBids: 12,
                lastLogin: '2024-12-10 11:20:00',
                createdAt: '2024-03-10',
                activityScore: 45
            }
        ];

        usersData = users;
        renderUsersTable(users);
        updateBulkOperationsState();

        console.log('Users loaded successfully');
    } catch (error) {
        console.error('Error loading users:', error);
        showToast('Failed to load users', 'error');
    }
}

// Render users table with enhanced data
function renderUsersTable(users) {
    const tableBody = document.getElementById('usersTableBody');
    if (!tableBody) return;

    if (users.length === 0) {
        tableBody.innerHTML = `
            <tr>
                <td colspan="12" style="text-align: center; padding: 2rem; color: var(--admin-text-muted);">
                    No users found matching the current filters.
                </td>
            </tr>
        `;
        return;
    }

    tableBody.innerHTML = users.map(user => `
        <tr class="user-row ${selectedUsers.has(user.id) ? 'selected' : ''}">
            <td>
                <input type="checkbox" class="user-checkbox" value="${user.id}" 
                       onchange="toggleUserSelection(${user.id})" 
                       ${selectedUsers.has(user.id) ? 'checked' : ''}>
            </td>
            <td class="user-id">#${user.id}</td>
            <td class="user-info">
                <div class="user-avatar">${user.avatar}</div>
                <div class="user-details">
                    <div class="user-name">${user.fullName}</div>
                    <div class="user-email">${user.email}</div>
                    <div class="user-username">@${user.username}</div>
                </div>
            </td>
            <td>
                <span class="status-badge ${user.status}">${user.status.charAt(0).toUpperCase() + user.status.slice(1)}</span>
            </td>
            <td>
                <span class="role-badge ${user.role}">${user.role.charAt(0).toUpperCase() + user.role.slice(1)}</span>
            </td>
            <td class="verification-status">
                <div class="verification-badges">
                    <span class="verification-badge ${user.emailVerified ? 'verified' : 'unverified'}" title="Email">
                        📧 ${user.emailVerified ? '✓' : '✗'}
                    </span>
                    <span class="verification-badge ${user.phoneVerified ? 'verified' : 'unverified'}" title="Phone">
                        📱 ${user.phoneVerified ? '✓' : '✗'}
                    </span>
                    <span class="verification-badge ${user.biometricEnabled ? 'verified' : 'unverified'}" title="Biometric">
                        👆 ${user.biometricEnabled ? '✓' : '✗'}
                    </span>
                </div>
            </td>
            <td class="activity-score">
                <div class="activity-indicator">
                    <div class="activity-bar">
                        <div class="activity-fill" style="width: ${user.activityScore}%"></div>
                    </div>
                    <span class="activity-percent">${user.activityScore}%</span>
                </div>
            </td>
            <td class="user-auctions">${user.totalAuctions}</td>
            <td class="user-bids">${user.totalBids}</td>
            <td class="last-login">${formatDateTime(user.lastLogin)}</td>
            <td class="created-date">${formatDate(user.createdAt)}</td>
            <td class="user-actions">
                <div class="action-buttons">
                    <button class="admin-btn-sm admin-btn-primary" onclick="viewUserDetails(${user.id})" title="View Details">
                        👁️
                    </button>
                    <button class="admin-btn-sm admin-btn-secondary" onclick="editUser(${user.id})" title="Edit User">
                        ✏️
                    </button>
                    ${user.status === 'active' ? 
                        `<button class="admin-btn-sm admin-btn-warning" onclick="suspendUser(${user.id})" title="Suspend">🚫</button>` :
                        `<button class="admin-btn-sm admin-btn-success" onclick="activateUser(${user.id})" title="Activate">✅</button>`
                    }
                    <button class="admin-btn-sm admin-btn-danger" onclick="deleteUser(${user.id})" title="Delete">
                        🗑️
                    </button>
                </div>
            </td>
        </tr>
    `).join('');
}

// User selection management
function toggleUserSelection(userId) {
    if (selectedUsers.has(userId)) {
        selectedUsers.delete(userId);
    } else {
        selectedUsers.add(userId);
    }
    updateBulkOperationsState();
    updateSelectedUserRow(userId);
}

function toggleSelectAll() {
    const selectAllCheckbox = document.getElementById('selectAllCheckbox');
    const userCheckboxes = document.querySelectorAll('.user-checkbox');

    if (selectAllCheckbox.checked) {
        userCheckboxes.forEach(checkbox => {
            const userId = parseInt(checkbox.value);
            selectedUsers.add(userId);
            checkbox.checked = true;
        });
    } else {
        selectedUsers.clear();
        userCheckboxes.forEach(checkbox => {
            checkbox.checked = false;
        });
    }

    updateBulkOperationsState();
    updateAllSelectedRows();
}

function selectAllUsers() {
    usersData.forEach(user => selectedUsers.add(user.id));
    updateBulkOperationsState();
    updateAllSelectedRows();
    document.getElementById('selectAllCheckbox').checked = true;
    document.querySelectorAll('.user-checkbox').forEach(cb => cb.checked = true);
}

function clearSelection() {
    selectedUsers.clear();
    updateBulkOperationsState();
    updateAllSelectedRows();
    document.getElementById('selectAllCheckbox').checked = false;
    document.querySelectorAll('.user-checkbox').forEach(cb => cb.checked = false);
}

function updateSelectedUserRow(userId) {
    const row = document.querySelector(`tr:has(.user-checkbox[value="${userId}"])`);
    if (row) {
        if (selectedUsers.has(userId)) {
            row.classList.add('selected');
        } else {
            row.classList.remove('selected');
        }
    }
}

function updateAllSelectedRows() {
    document.querySelectorAll('.user-row').forEach(row => {
        const checkbox = row.querySelector('.user-checkbox');
        if (checkbox) {
            const userId = parseInt(checkbox.value);
            if (selectedUsers.has(userId)) {
                row.classList.add('selected');
            } else {
                row.classList.remove('selected');
            }
        }
    });
}

function updateBulkOperationsState() {
    const selectedCount = selectedUsers.size;
    document.getElementById('selectedCount').textContent = selectedCount;

    const bulkButtons = [
        'bulkSuspendBtn', 'bulkActivateBtn', 'bulkVerifyBtn',
        'bulkExportBtn', 'bulkDeleteBtn'
    ];

    bulkButtons.forEach(buttonId => {
        const button = document.getElementById(buttonId);
        if (button) {
            button.disabled = selectedCount === 0;
        }
    });
}

// Filter operations
function applyUserFilters() {
    const filters = {
        search: document.getElementById('userSearch').value.toLowerCase(),
        status: document.getElementById('userStatusFilter').value,
        role: document.getElementById('userRoleFilter').value,
        sortBy: document.getElementById('userSortBy').value
    };

    currentFilters = filters;

    let filteredUsers = [...usersData];

    // Apply search filter
    if (filters.search) {
        filteredUsers = filteredUsers.filter(user =>
            user.fullName.toLowerCase().includes(filters.search) ||
            user.email.toLowerCase().includes(filters.search) ||
            user.username.toLowerCase().includes(filters.search) ||
            user.id.toString().includes(filters.search)
        );
    }

    // Apply status filter
    if (filters.status !== 'all') {
        filteredUsers = filteredUsers.filter(user => user.status === filters.status);
    }

    // Apply role filter
    if (filters.role !== 'all') {
        filteredUsers = filteredUsers.filter(user => user.role === filters.role);
    }

    // Apply sorting
    filteredUsers.sort((a, b) => {
        switch (filters.sortBy) {
            case 'created_desc':
                return new Date(b.createdAt) - new Date(a.createdAt);
            case 'created_asc':
                return new Date(a.createdAt) - new Date(b.createdAt);
            case 'name_asc':
                return a.fullName.localeCompare(b.fullName);
            case 'name_desc':
                return b.fullName.localeCompare(a.fullName);
            case 'activity_desc':
                return b.activityScore - a.activityScore;
            default:
                return 0;
        }
    });

    renderUsersTable(filteredUsers);
    showToast(`Found ${filteredUsers.length} users matching filters`, 'success');
}

function resetUserFilters() {
    document.getElementById('userSearch').value = '';
    document.getElementById('userStatusFilter').value = 'all';
    document.getElementById('userRoleFilter').value = 'all';
    document.getElementById('userSortBy').value = 'created_desc';

    currentFilters = {};
    renderUsersTable(usersData);
    showToast('Filters reset', 'success');
}

function toggleAdvancedFilters() {
    const panel = document.getElementById('advancedFilterPanel');
    if (panel.style.display === 'none') {
        panel.style.display = 'block';
        showToast('Advanced filters opened', 'info');
    } else {
        panel.style.display = 'none';
        showToast('Advanced filters closed', 'info');
    }
}

// Bulk operations
function bulkSuspendUsers() {
    if (selectedUsers.size === 0) return;

    if (confirm(`Are you sure you want to suspend ${selectedUsers.size} selected users?`)) {
        showToast(`Suspending ${selectedUsers.size} users...`, 'warning');
        setTimeout(() => {
            showToast('Users suspended successfully', 'success');
            clearSelection();
            loadUsers();
        }, 2000);
    }
}

function bulkActivateUsers() {
    if (selectedUsers.size === 0) return;

    if (confirm(`Are you sure you want to activate ${selectedUsers.size} selected users?`)) {
        showToast(`Activating ${selectedUsers.size} users...`, 'info');
        setTimeout(() => {
            showToast('Users activated successfully', 'success');
            clearSelection();
            loadUsers();
        }, 2000);
    }
}

function bulkVerifyUsers() {
    if (selectedUsers.size === 0) return;

    if (confirm(`Are you sure you want to verify ${selectedUsers.size} selected users?`)) {
        showToast(`Verifying ${selectedUsers.size} users...`, 'info');
        setTimeout(() => {
            showToast('Users verified successfully', 'success');
            clearSelection();
            loadUsers();
        }, 2000);
    }
}

function bulkExportUsers() {
    if (selectedUsers.size === 0) return;

    showToast(`Exporting ${selectedUsers.size} selected users...`, 'info');
    setTimeout(() => {
        showToast('User data exported successfully', 'success');
    }, 1500);
}

function bulkDeleteUsers() {
    if (selectedUsers.size === 0) return;

    if (confirm(`⚠️ WARNING: Are you sure you want to DELETE ${selectedUsers.size} selected users? This action cannot be undone!`)) {
        showToast(`Deleting ${selectedUsers.size} users...`, 'danger');
        setTimeout(() => {
            showToast('Users deleted successfully', 'success');
            clearSelection();
            loadUsers();
        }, 2000);
    }
}

// Individual user operations
function viewUserDetails(userId) {
    const user = usersData.find(u => u.id === userId);
    if (!user) return;

    showToast(`Loading details for ${user.fullName}...`, 'info');
    setTimeout(() => {
        alert(`User Details:\n\nName: ${user.fullName}\nEmail: ${user.email}\nUsername: ${user.username}\nStatus: ${user.status}\nRole: ${user.role}\nAuctions: ${user.totalAuctions}\nBids: ${user.totalBids}\nActivity Score: ${user.activityScore}%\nLast Login: ${user.lastLogin}\nCreated: ${user.createdAt}`);
    }, 1000);
}

function editUser(userId) {
    const user = usersData.find(u => u.id === userId);
    if (!user) return;

    showToast(`Opening edit form for ${user.fullName}...`, 'info');
    // This would typically open a modal or navigate to edit page
}

function suspendUser(userId) {
    const user = usersData.find(u => u.id === userId);
    if (!user) return;

    if (confirm(`Are you sure you want to suspend ${user.fullName}?`)) {
        showToast(`Suspending ${user.fullName}...`, 'warning');
        setTimeout(() => {
            showToast('User suspended successfully', 'success');
            loadUsers();
        }, 1500);
    }
}

function activateUser(userId) {
    const user = usersData.find(u => u.id === userId);
    if (!user) return;

    if (confirm(`Are you sure you want to activate ${user.fullName}?`)) {
        showToast(`Activating ${user.fullName}...`, 'info');
        setTimeout(() => {
            showToast('User activated successfully', 'success');
            loadUsers();
        }, 1500);
    }
}

function deleteUser(userId) {
    const user = usersData.find(u => u.id === userId);
    if (!user) return;

    if (confirm(`⚠️ WARNING: Are you sure you want to DELETE ${user.fullName}? This action cannot be undone!`)) {
        showToast(`Deleting ${user.fullName}...`, 'danger');
        setTimeout(() => {
            showToast('User deleted successfully', 'success');
            loadUsers();
        }, 1500);
    }
}

// Export and analytics operations
function exportUsers() {
    showToast('Exporting all user data...', 'info');
    setTimeout(() => {
        showToast('User data exported successfully', 'success');
    }, 2000);
}

function refreshUserAnalytics() {
    loadUserAnalytics();
    showToast('User analytics refreshed', 'success');
}

// Utility functions
function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
    });
}

function formatDateTime(dateTimeString) {
    const date = new Date(dateTimeString);
    return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
}

function getActivityLevel(score) {
    if (score >= 80) return 'high';
    if (score >= 60) return 'medium';
    return 'low';
}
