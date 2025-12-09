package com.zubid.app.data.model

data class Notification(
    val id: String,
    val title: String,
    val message: String,
    val timestamp: Long,
    val type: String, // "outbid", "ending", "won", "new"
    val isRead: Boolean = false
) {
    fun getTimeAgo(): String {
        val now = System.currentTimeMillis()
        val diff = now - timestamp
        
        val minutes = diff / (1000 * 60)
        val hours = diff / (1000 * 60 * 60)
        val days = diff / (1000 * 60 * 60 * 24)
        
        return when {
            minutes < 1 -> "Just now"
            minutes < 60 -> "${minutes}m ago"
            hours < 24 -> "${hours}h ago"
            days < 7 -> "${days}d ago"
            else -> "${days / 7}w ago"
        }
    }
}

