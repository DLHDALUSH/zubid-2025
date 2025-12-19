// Security & Monitoring JavaScript
let securityData = null;

// Initialize security monitoring page
document.addEventListener('DOMContentLoaded', async () => {
    await checkAdminAuth();
    await loadSecurityData();
    await loadBlockedIPs();
    await loadSecurityIncidents();
    await loadAuditLogs();
    
    // Auto-refresh security data every 30 seconds
    setInterval(loadSecurityData, 30000);
});

// Load security data
async function loadSecurityData() {
    try {
        // Mock security data - replace with actual API call
        const data = {
            threatsBlocked: Math.floor(Math.random() * 3),
            suspiciousActivities: Math.floor(Math.random() * 5) + 1,
            failedLogins: Math.floor(Math.random() * 10) + 3,
            activeSessions: Math.floor(Math.random() * 20) + 15,
            adminSessions: Math.floor(Math.random() * 5) + 1,
            blockedIPs: Math.floor(Math.random() * 10) + 5,
            flaggedTransactions: Math.floor(Math.random() * 5),
            suspiciousBids: Math.floor(Math.random() * 3),
            riskScore: ['Low', 'Medium', 'High'][Math.floor(Math.random() * 3)]
        };

        securityData = data;

        // Update security metrics
        document.getElementById('threatsBlocked').textContent = data.threatsBlocked;
        document.getElementById('suspiciousActivities').textContent = data.suspiciousActivities;
        document.getElementById('failedLogins').textContent = data.failedLogins;
        document.getElementById('activeSessions').textContent = data.activeSessions;
        document.getElementById('adminSessions').textContent = data.adminSessions;
        document.getElementById('blockedIPs').textContent = data.blockedIPs;
        document.getElementById('flaggedTransactions').textContent = data.flaggedTransactions;
        document.getElementById('suspiciousBids').textContent = data.suspiciousBids;
        document.getElementById('riskScore').textContent = data.riskScore;

        // Update security status
        updateSecurityStatus(data);

        console.log('Security data loaded successfully');
    } catch (error) {
        console.error('Error loading security data:', error);
        showToast('Failed to load security data', 'error');
    }
}

// Update security status indicator
function updateSecurityStatus(data) {
    const statusIndicator = document.getElementById('securityStatusIndicator');
    if (statusIndicator) {
        const statusDot = statusIndicator.querySelector('.security-dot');
        const statusText = statusIndicator.querySelector('span:last-child');
        
        const threatLevel = data.threatsBlocked + data.suspiciousActivities + data.failedLogins;
        
        if (threatLevel < 5 && data.riskScore === 'Low') {
            statusDot.className = 'security-dot secure';
            statusText.textContent = 'System Secure';
        } else if (threatLevel < 15 && data.riskScore !== 'High') {
            statusDot.className = 'security-dot warning';
            statusText.textContent = 'Minor Threats Detected';
        } else {
            statusDot.className = 'security-dot danger';
            statusText.textContent = 'Security Alert';
        }
    }
}

// Load blocked IPs
async function loadBlockedIPs() {
    try {
        // Mock blocked IPs data - replace with actual API call
        const blockedIPs = [
            {
                ip: '192.168.1.100',
                location: { country: '🇺🇸 United States', city: 'New York, NY' },
                reason: 'Brute Force Attack',
                blockedDate: 'Dec 19, 2024',
                attempts: 25,
                status: 'Blocked'
            },
            {
                ip: '203.0.113.45',
                location: { country: '🇨🇳 China', city: 'Beijing' },
                reason: 'Suspicious Activity',
                blockedDate: 'Dec 18, 2024',
                attempts: 12,
                status: 'Blocked'
            }
        ];

        const tableBody = document.getElementById('blockedIPsTableBody');
        if (tableBody) {
            tableBody.innerHTML = blockedIPs.map(ip => `
                <tr>
                    <td class="ip-address">${ip.ip}</td>
                    <td>
                        <div class="location-info">
                            <div class="country">${ip.location.country}</div>
                            <div class="city">${ip.location.city}</div>
                        </div>
                    </td>
                    <td>
                        <span class="reason-badge ${ip.reason.toLowerCase().replace(/\s+/g, '-')}">${ip.reason}</span>
                    </td>
                    <td>${ip.blockedDate}</td>
                    <td class="attempts">${ip.attempts}</td>
                    <td><span class="status-badge ${ip.status.toLowerCase()}">${ip.status}</span></td>
                    <td>
                        <div class="action-buttons">
                            <button class="admin-btn-sm admin-btn-success" onclick="unblockIP('${ip.ip}')">
                                Unblock
                            </button>
                            <button class="admin-btn-sm admin-btn-secondary" onclick="viewIPDetails('${ip.ip}')">
                                Details
                            </button>
                        </div>
                    </td>
                </tr>
            `).join('');
        }

        console.log('Blocked IPs loaded successfully');
    } catch (error) {
        console.error('Error loading blocked IPs:', error);
    }
}

// Load security incidents
async function loadSecurityIncidents() {
    try {
        // Mock incidents data - replace with actual API call
        const incidents = [
            {
                id: 'INC-001',
                priority: 'high',
                title: 'Multiple Failed Login Attempts',
                description: 'Detected 15 failed login attempts from IP 192.168.1.100 within 5 minutes',
                time: '2 minutes ago'
            },
            {
                id: 'INC-002',
                priority: 'medium',
                title: 'Suspicious Bid Pattern',
                description: 'User ID 1234 placed 10 consecutive bids on auction #5678 within 2 minutes',
                time: '15 minutes ago'
            },
            {
                id: 'INC-003',
                priority: 'low',
                title: 'Unusual Payment Method',
                description: 'New payment method added from different country than user profile',
                time: '1 hour ago'
            }
        ];

        const incidentsList = document.getElementById('incidentsList');
        if (incidentsList) {
            incidentsList.innerHTML = incidents.map(incident => `
                <div class="incident-item ${incident.priority}">
                    <div class="incident-header">
                        <div class="incident-title">
                            <span class="incident-priority ${incident.priority}">${incident.priority.toUpperCase()}</span>
                            <span class="incident-name">${incident.title}</span>
                        </div>
                        <div class="incident-time">${incident.time}</div>
                    </div>
                    <div class="incident-description">${incident.description}</div>
                    <div class="incident-actions">
                        <button class="admin-btn-sm admin-btn-primary" onclick="investigateIncident('${incident.id}')">
                            Investigate
                        </button>
                        <button class="admin-btn-sm admin-btn-success" onclick="resolveIncident('${incident.id}')">
                            Resolve
                        </button>
                    </div>
                </div>
            `).join('');
        }

        console.log('Security incidents loaded successfully');
    } catch (error) {
        console.error('Error loading security incidents:', error);
    }
}

// Load audit logs
async function loadAuditLogs() {
    try {
        // Mock audit logs data - replace with actual API call
        const auditLogs = [
            {
                timestamp: '2024-12-19 10:30:15',
                user: { avatar: 'A', name: 'Admin User' },
                action: { type: 'admin', description: 'Created new auction category: Electronics' },
                ip: '192.168.1.50'
            },
            {
                timestamp: '2024-12-19 10:25:42',
                user: { avatar: 'J', name: 'John Doe' },
                action: { type: 'financial', description: 'Completed payment for auction #1234 - $250.00' },
                ip: '203.0.113.45'
            },
            {
                timestamp: '2024-12-19 10:20:18',
                user: { avatar: 'M', name: 'Mary Smith' },
                action: { type: 'auction', description: 'Created new auction: Vintage Watch' },
                ip: '198.51.100.23'
            }
        ];

        const auditContainer = document.getElementById('auditLogsContainer');
        if (auditContainer) {
            auditContainer.innerHTML = auditLogs.map(log => `
                <div class="audit-log-entry">
                    <div class="audit-timestamp">${log.timestamp}</div>
                    <div class="audit-user">
                        <div class="user-avatar">${log.user.avatar}</div>
                        <div class="user-name">${log.user.name}</div>
                    </div>
                    <div class="audit-action">
                        <span class="action-type ${log.action.type}">${log.action.type.toUpperCase()}</span>
                        <span class="action-description">${log.action.description}</span>
                    </div>
                    <div class="audit-ip">${log.ip}</div>
                </div>
            `).join('');
        }

        console.log('Audit logs loaded successfully');
    } catch (error) {
        console.error('Error loading audit logs:', error);
    }
}

// Security operations
function refreshSecurityData() {
    loadSecurityData();
    showToast('Security data refreshed', 'success');
}

function runSecurityScan() {
    showToast('Running comprehensive security scan...', 'info');
    setTimeout(() => {
        showToast('Security scan completed - System secure', 'success');
        loadSecurityData();
    }, 5000);
}

// IP management operations
function blockIP() {
    const ipInput = document.getElementById('ipAddressInput');
    const ipAddress = ipInput.value.trim();

    if (!ipAddress) {
        showToast('Please enter an IP address', 'error');
        return;
    }

    if (!isValidIP(ipAddress)) {
        showToast('Please enter a valid IP address', 'error');
        return;
    }

    showToast(`Blocking IP address: ${ipAddress}...`, 'info');
    setTimeout(() => {
        showToast(`IP address ${ipAddress} has been blocked`, 'success');
        ipInput.value = '';
        loadBlockedIPs();
    }, 1500);
}

function unblockIP(ipAddress) {
    if (confirm(`Are you sure you want to unblock IP address: ${ipAddress}?`)) {
        showToast(`Unblocking IP address: ${ipAddress}...`, 'info');
        setTimeout(() => {
            showToast(`IP address ${ipAddress} has been unblocked`, 'success');
            loadBlockedIPs();
        }, 1500);
    }
}

function viewIPDetails(ipAddress) {
    showToast(`Loading details for IP: ${ipAddress}...`, 'info');
    // Mock IP details view
    setTimeout(() => {
        alert(`IP Details for ${ipAddress}:\n\nLocation: New York, NY, USA\nISP: Example ISP\nThreat Level: High\nFirst Seen: Dec 15, 2024\nLast Activity: Dec 19, 2024\nTotal Attempts: 25`);
    }, 1000);
}

function refreshIPList() {
    loadBlockedIPs();
    showToast('IP list refreshed', 'success');
}

// Incident management
function investigateIncident(incidentId) {
    showToast(`Opening investigation for incident: ${incidentId}...`, 'info');
    setTimeout(() => {
        showToast('Investigation details loaded', 'success');
    }, 1500);
}

function resolveIncident(incidentId) {
    if (confirm(`Are you sure you want to resolve incident: ${incidentId}?`)) {
        showToast(`Resolving incident: ${incidentId}...`, 'info');
        setTimeout(() => {
            showToast('Incident resolved successfully', 'success');
            loadSecurityIncidents();
        }, 1500);
    }
}

function refreshIncidents() {
    loadSecurityIncidents();
    showToast('Security incidents refreshed', 'success');
}

// Audit log operations
function refreshAuditLogs() {
    const logType = document.getElementById('auditLogType').value;
    showToast(`Refreshing ${logType} audit logs...`, 'info');
    loadAuditLogs();
}

function exportAuditLogs() {
    const logType = document.getElementById('auditLogType').value;
    showToast(`Exporting ${logType} audit logs...`, 'info');
    setTimeout(() => {
        showToast('Audit logs exported successfully', 'success');
    }, 2000);
}

// Utility functions
function isValidIP(ip) {
    const ipRegex = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/;
    return ipRegex.test(ip);
}

function formatThreatLevel(level) {
    const levels = {
        'low': { color: 'success', text: 'Low Risk' },
        'medium': { color: 'warning', text: 'Medium Risk' },
        'high': { color: 'danger', text: 'High Risk' }
    };
    return levels[level.toLowerCase()] || levels['low'];
}
