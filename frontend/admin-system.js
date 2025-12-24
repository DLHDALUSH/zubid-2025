// System Administration JavaScript
let systemData = null;

// Initialize system administration page
document.addEventListener('DOMContentLoaded', async () => {
    await checkAdminAuth();
    await loadSystemData();
    await loadDatabaseStats();
    await loadSystemLogs();
    
    // Auto-refresh system data every 30 seconds
    setInterval(loadSystemData, 30000);
});

// Load system data
async function loadSystemData() {
    try {
        // Mock system data - replace with actual API call
        const data = {
            cpu: Math.floor(Math.random() * 40) + 20,
            memory: Math.floor(Math.random() * 30) + 50,
            disk: Math.floor(Math.random() * 20) + 35,
            uptime: 99.9,
            totalRecords: 15420,
            databaseSize: 245,
            lastBackup: '2 hours ago',
            connectionPool: '8/20',
            failedLogins: Math.floor(Math.random() * 5),
            blockedIPs: Math.floor(Math.random() * 3),
            sslStatus: 'Valid (90 days)',
            securityScore: 'A+'
        };

        systemData = data;

        // Update performance metrics
        updateMetricBar('cpuUsage', 'cpuPercent', data.cpu);
        updateMetricBar('memoryUsage', 'memoryPercent', data.memory);
        updateMetricBar('diskUsage', 'diskPercent', data.disk);

        // Update system info
        document.getElementById('totalRecords').textContent = data.totalRecords.toLocaleString();
        document.getElementById('databaseSize').textContent = `${data.databaseSize} MB`;
        document.getElementById('lastBackup').textContent = data.lastBackup;
        document.getElementById('connectionPool').textContent = data.connectionPool;
        document.getElementById('failedLogins').textContent = data.failedLogins;
        document.getElementById('blockedIPs').textContent = data.blockedIPs;
        document.getElementById('sslStatus').textContent = data.sslStatus;
        document.getElementById('securityScore').textContent = data.securityScore;

        // Update system status
        updateSystemStatus(data);

        console.log('System data loaded successfully');
    } catch (error) {
        console.error('Error loading system data:', error);
        showToast('Failed to load system data', 'error');
    }
}

// Update metric bar
function updateMetricBar(barId, percentId, value) {
    const bar = document.getElementById(barId);
    const percent = document.getElementById(percentId);
    
    if (bar && percent) {
        bar.style.width = `${value}%`;
        percent.textContent = `${value}%`;
        
        // Update color based on value
        if (value > 80) {
            bar.style.background = 'var(--admin-danger)';
        } else if (value > 60) {
            bar.style.background = 'var(--admin-warning)';
        } else {
            bar.style.background = 'var(--admin-success)';
        }
    }
}

// Update system status
function updateSystemStatus(data) {
    const statusIndicator = document.getElementById('systemStatusIndicator');
    if (statusIndicator) {
        const statusDot = statusIndicator.querySelector('.status-dot');
        const statusText = statusIndicator.querySelector('span:last-child');
        
        const avgUsage = (data.cpu + data.memory + data.disk) / 3;
        
        if (avgUsage < 60 && data.failedLogins < 5) {
            statusDot.className = 'status-dot online';
            statusText.textContent = 'All Systems Operational';
        } else if (avgUsage < 80 && data.failedLogins < 10) {
            statusDot.className = 'status-dot warning';
            statusText.textContent = 'Minor Issues Detected';
        } else {
            statusDot.className = 'status-dot offline';
            statusText.textContent = 'System Issues';
        }
    }
}

// Load database statistics
async function loadDatabaseStats() {
    try {
        // Mock database stats - replace with actual API call
        const stats = {
            users: 1250,
            auctions: 3420,
            bids: 8750,
            categories: 25
        };

        document.getElementById('usersTableSize').textContent = `${stats.users.toLocaleString()} records`;
        document.getElementById('auctionsTableSize').textContent = `${stats.auctions.toLocaleString()} records`;
        document.getElementById('bidsTableSize').textContent = `${stats.bids.toLocaleString()} records`;
        document.getElementById('categoriesTableSize').textContent = `${stats.categories} records`;

        console.log('Database stats loaded successfully');
    } catch (error) {
        console.error('Error loading database stats:', error);
    }
}

// Load system logs
async function loadSystemLogs() {
    try {
        // Mock log data - replace with actual API call
        const logs = [
            { time: '2024-12-19 10:30:15', level: 'info', message: 'User authentication successful for user ID: 1234' },
            { time: '2024-12-19 10:28:42', level: 'warning', message: 'High CPU usage detected: 85%' },
            { time: '2024-12-19 10:25:33', level: 'error', message: 'Database connection timeout after 30 seconds' },
            { time: '2024-12-19 10:20:18', level: 'info', message: 'New auction created: ID 5678' },
            { time: '2024-12-19 10:15:45', level: 'info', message: 'Backup completed successfully' }
        ];

        const logsViewer = document.getElementById('logsViewer');
        if (logsViewer) {
            logsViewer.innerHTML = logs.map(log => `
                <div class="log-entry ${log.level}">
                    <span class="log-time">${log.time}</span>
                    <span class="log-level ${log.level}">${log.level.toUpperCase()}</span>
                    <span class="log-message">${log.message}</span>
                </div>
            `).join('');
        }

        console.log('System logs loaded successfully');
    } catch (error) {
        console.error('Error loading system logs:', error);
    }
}

// Refresh system data
function refreshSystemData() {
    loadSystemData();
    showToast('System data refreshed', 'success');
}

// Emergency shutdown
function emergencyShutdown() {
    if (confirm('⚠️ WARNING: This will shut down the system immediately. Are you sure?')) {
        showToast('Emergency shutdown initiated...', 'warning');
        // Mock emergency shutdown
        setTimeout(() => {
            showToast('System shutdown cancelled - Demo mode', 'info');
        }, 3000);
    }
}

// Database operations
function backupDatabase() {
    showToast('Creating database backup...', 'info');
    setTimeout(() => {
        showToast('Database backup completed successfully', 'success');
        loadDatabaseStats();
    }, 2000);
}

function optimizeDatabase() {
    showToast('Optimizing database...', 'info');
    setTimeout(() => {
        showToast('Database optimization completed', 'success');
    }, 3000);
}

function createBackup() {
    const backupName = prompt('Enter backup name (optional):') || 'Manual Backup';
    showToast(`Creating backup: ${backupName}...`, 'info');
    setTimeout(() => {
        showToast('Backup created successfully', 'success');
    }, 2000);
}

function viewBackups() {
    showToast('Loading backup history...', 'info');
}

function restoreBackup(backupId) {
    if (confirm(`Are you sure you want to restore backup: ${backupId}? This will overwrite current data.`)) {
        showToast(`Restoring backup: ${backupId}...`, 'warning');
        setTimeout(() => {
            showToast('Backup restored successfully', 'success');
        }, 5000);
    }
}

function downloadBackup(backupId) {
    showToast(`Downloading backup: ${backupId}...`, 'info');
    setTimeout(() => {
        showToast('Backup download started', 'success');
    }, 1000);
}

// Security operations
function viewSecurityLogs() {
    showToast('Loading security logs...', 'info');
    document.getElementById('logType').value = 'security';
    refreshLogs();
}

function runSecurityScan() {
    showToast('Running security scan...', 'info');
    setTimeout(() => {
        showToast('Security scan completed - No threats detected', 'success');
    }, 5000);
}

// Log operations
function refreshLogs() {
    const logType = document.getElementById('logType').value;
    showToast(`Refreshing ${logType} logs...`, 'info');
    loadSystemLogs();
}

function exportLogs() {
    const logType = document.getElementById('logType').value;
    showToast(`Exporting ${logType} logs...`, 'info');
    setTimeout(() => {
        showToast('Logs exported successfully', 'success');
    }, 2000);
}

// Settings operations
function saveSettings() {
    const settings = {
        siteName: document.getElementById('siteName').value,
        siteDescription: document.getElementById('siteDescription').value,
        maintenanceMode: document.getElementById('maintenanceMode').checked,
        defaultCommission: document.getElementById('defaultCommission').value,
        minBidIncrement: document.getElementById('minBidIncrement').value,
        maxAuctionDuration: document.getElementById('maxAuctionDuration').value
    };

    showToast('Saving system settings...', 'info');

    // Mock save operation
    setTimeout(() => {
        showToast('System settings saved successfully', 'success');
        console.log('Settings saved:', settings);
    }, 1500);
}

// Utility functions
function formatBytes(bytes) {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

function formatUptime(seconds) {
    const days = Math.floor(seconds / 86400);
    const hours = Math.floor((seconds % 86400) / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    return `${days}d ${hours}h ${minutes}m`;
}
